import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/data_service.dart';
import '../models/project_model.dart';
import '../web_common/cargo_details_table_widget.dart';
import '../web_common/msra_file_upload_widget.dart';
import '../web_common/offsite_checklist_widget.dart';
import '../web_common/project_form_widget.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/step_label.dart';
import '../web_common/work_scope_widget.dart';
import 'msra_generation_screen.dart';
import 'onsite_checklist_screen.dart';

class ProjectScreen extends StatefulWidget {
  final String? projectId;
  final VoidCallback? onPopCallback;
  final int selectedTab;

  const ProjectScreen({
    Key? key,
    this.projectId,
    this.onPopCallback,
    this.selectedTab = 0, // default to Offsite
  }) : super(key: key);

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late int selectedTabIndex;

  Project? _project;
  bool isNewProject = true;
  bool isOOG = false;
  bool isLoading = true;
  bool hasRun = false;
  bool isSaving = false;
  bool isSaved = false;
  bool enableSaveButton = false;
  bool showChecklist = false;
  bool isGenerateMSRAEnabled = false;
  bool isGeneratingMSRA = false;
  bool hasGenerateMSRA = false;
  bool enableRunButton = false;
  int currentStep = 0;
  List<String> resultsOOG = [];

  final GlobalKey<ProjectFormWidgetState> _formKey =
      GlobalKey<ProjectFormWidgetState>();
  final GlobalKey<CargoDetailsTableWidgetState> _cargoKey =
      GlobalKey<CargoDetailsTableWidgetState>();
  final GlobalKey<WorkScopeWidgetState> _workScopeKey =
      GlobalKey<WorkScopeWidgetState>();
  final GlobalKey<FileUploadWidgetState> _fileUploadKey =
      GlobalKey<FileUploadWidgetState>();

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.selectedTab;
    _loadProjectData();
  }

  bool _canRun() {
    final formState = _formKey.currentState;
    final cargoState = _cargoKey.currentState;

    final projectName = formState?.getProjectName() ?? '';
    final client = formState?.getClient() ?? '';
    final emailSubject = formState?.getEmailSubjectHeader() ?? '';
    final stakeholders = formState?.getSelectedStakeholders() ?? [];
    final cargo = cargoState?.getCargoList() ?? [];

    return projectName.isNotEmpty &&
        client.isNotEmpty &&
        emailSubject.isNotEmpty &&
        stakeholders.isNotEmpty &&
        cargo.isNotEmpty;
  }

  void _evaluateRunButton() {
    final formState = _formKey.currentState;
    final cargoState = _cargoKey.currentState;

    final projectName = formState?.getProjectName() ?? '';
    final client = formState?.getClient() ?? '';
    final emailSubject = formState?.getEmailSubjectHeader() ?? '';
    final stakeholders = formState?.getSelectedStakeholders() ?? [];
    final cargo = cargoState?.getCargoList() ?? [];

    final hasAtLeastOneRow = cargo.isNotEmpty;

    final allRowsAreComplete = cargo.every((c) =>
        (c["cargoname"]?.trim().isNotEmpty ?? false) &&
        (c["length"]?.trim().isNotEmpty ?? false) &&
        (c["breadth"]?.trim().isNotEmpty ?? false) &&
        (c["height"]?.trim().isNotEmpty ?? false) &&
        (c["weight"]?.trim().isNotEmpty ?? false) &&
        (c["quantity"]?.trim().isNotEmpty ?? false));

    final hasAtLeastOneCompleteRow = cargo.any((c) =>
        (c["cargoname"]?.trim().isNotEmpty ?? false) &&
        (c["length"]?.trim().isNotEmpty ?? false) &&
        (c["breadth"]?.trim().isNotEmpty ?? false) &&
        (c["height"]?.trim().isNotEmpty ?? false) &&
        (c["weight"]?.trim().isNotEmpty ?? false) &&
        (c["quantity"]?.trim().isNotEmpty ?? false));

    final cargoIsValid =
        hasAtLeastOneRow && allRowsAreComplete && hasAtLeastOneCompleteRow;

    final canRun = projectName.isNotEmpty &&
        client.isNotEmpty &&
        emailSubject.isNotEmpty &&
        stakeholders.isNotEmpty &&
        cargoIsValid;

    setState(() {
      enableRunButton = canRun;
    });
  }

  void _loadProjectData() async {
    if (widget.projectId != null) {
      List<Project> projects = await DataService.getProjects();
      Project? foundProject = projects.firstWhere(
        (p) => p.projectId == widget.projectId,
        orElse: () => Project(
          client: '',
          projectId: '',
          projectName: '',
          projectType: '',
          startDestination: '',
          endDestination: '',
          projectStatus: '',
          emailsubjectheader: '',
          stage: '',
          startDate: DateTime.now(),
          stakeholders: [],
          cargo: [],
          scope: [],
        ),
      );

      if (foundProject.projectId.isNotEmpty) {
        setState(() {
          _project = foundProject;
          if (_project!.stage != null && _project!.stage!.isNotEmpty) {
            final stageLabel = _project!.stage!.toLowerCase();
            final index = kStepLabels
                .indexWhere((label) => label.toLowerCase() == stageLabel);
            currentStep = index >= 0 ? index : 0;
          }
          isNewProject = false;
          isOOG = true;
          hasRun = isOOG;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        _project = Project(
          client: '',
          projectId: '',
          projectName: '',
          projectType: '',
          startDestination: '',
          endDestination: '',
          projectStatus: '',
          emailsubjectheader: '',
          stage: '',
          startDate: DateTime.now(),
          stakeholders: [],
          cargo: [],
          scope: [],
        );
        isNewProject = true;
        isLoading = false;
      });
    }
  }

  Future<void> _onRunPressed() async {
    final stakeholders = _formKey.currentState?.getSelectedStakeholders() ?? [];
    print("Sending stakeholders: $stakeholders");
    final cargo = _cargoKey.currentState?.getCargoList() ?? [];

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final body = jsonEncode({
      "projectname": _formKey.currentState?.getProjectName(),
      "client": _formKey.currentState?.getClient(),
      "emailsubjectheader": _formKey.currentState?.getEmailSubjectHeader(),
      "stakeholders": stakeholders,
      "cargo": cargo,
    });

    final response = await http.post(
      Uri.parse('http://localhost:5000/project/new'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      bool setOOG = false;
      List<String> resultList = [];
      if (responseData['cargo'] != null) {
        for (int i = 0; i < responseData['cargo'].length; i++) {
          String? oogResult = responseData['cargo'][i]['oog'];
          String result = oogResult == "Yes" ? "OOG" : "Normal";

          // Create a new Cargo object and add it to the updatedCargo list
          resultList.add(result);

          if (oogResult == "Yes") {
            setOOG = true;
          }
        }
      }

      setState(() {
        hasRun = true;
        isOOG = setOOG;
        String projectType = isOOG ? "OOG" : "Normal";
        resultsOOG = resultList;

        _project = Project(
          client: _formKey.currentState?.getClient() ?? '',
          projectId: responseData["projectid"]?.toString() ?? '',
          projectName: _formKey.currentState?.getProjectName() ?? '',
          projectType: projectType,
          startDestination: '',
          endDestination: '',
          projectStatus: '',
          emailsubjectheader: '',
          stage: '',
          startDate: DateTime.now(),
          stakeholders: stakeholders,
          cargo: [],
          scope: [],
        );
      });
    } else {
      print("Failed to classify OOG. Status: ${response.statusCode}");
    }
  }

  void _evaluateSaveButton() {
    final scopeList = _workScopeKey.currentState?.getWorkScopeData() ?? [];
    final isComplete = scopeList.every((row) =>
      row["startDestination"]?.trim().isNotEmpty == true &&
      row["endDestination"]?.trim().isNotEmpty == true &&
      row["scope"]?.trim().isNotEmpty == true &&
      row["equipmentList"]?.trim().isNotEmpty == true
    );

    setState(() {
      enableSaveButton = isComplete;
    });
  }

  void onSavePressed() async {
    setState(() {
      isSaving = true;
    });

    final projectId = _project?.projectId ?? "";
    final rawScopeList = _workScopeKey.currentState?.getWorkScopeData() ?? [];
    final uploadedFiles = _fileUploadKey.currentState?.getUploadedFiles() ?? [];

    html.File? vendorMS;
    html.File? vendorRA;

    for (final file in uploadedFiles) {
      final name = file.name.toLowerCase();
      if (vendorMS == null && name.contains('ms')) {
        vendorMS = file;
      } else if (vendorRA == null && name.contains('ra')) {
        vendorRA = file;
      }
    }

    // If neither file is uploaded, set them to null so nothing is appended
    vendorMS ??= null;
    vendorRA ??= null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Missing token");

      final scopeList = rawScopeList.map((row) {
        return {
          "start": row["startDestination"] ?? "",
          "end": row["endDestination"] ?? "",
          "work": row["scope"] ?? "",
          "equipment": row["equipmentList"] ?? "",
        };
      }).toList();

      final formData = html.FormData();

      // Append the files only if they exist
      if (vendorMS != null) {
        formData.appendBlob('VendorMS', vendorMS, vendorMS.name);
      } else {
        // If no MS file, append an empty field or pass null
        formData.append('VendorMS', '');
      }

      if (vendorRA != null) {
        formData.appendBlob('VendorRA', vendorRA, vendorRA.name);
      } else {
        // If no RA file, append an empty field or pass null
        formData.append('VendorRA', '');
      }

      formData.append('projectid', projectId);
      formData.append('scope', jsonEncode(scopeList));

      final request = html.HttpRequest();
      request
        ..open('POST', 'http://localhost:5000/project/save')
        ..setRequestHeader('Authorization', 'Bearer $token')
        ..onLoadEnd.listen((event) async {
          setState(() {
            isSaving = false;
          });

          if (request.status == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Project saved successfully.")),
            );

            // ✅ Generate Checklist (AFTER project is saved)
            final generateChecklistResponse = await http.post(
              Uri.parse('http://localhost:5000/project/generate-checklist'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'projectid': int.tryParse(projectId)}),
            );

            if (generateChecklistResponse.statusCode == 200) {
              print("✅ Checklist generated successfully.");
              setState(() {
                isSaved = true;
                showChecklist = true;
                isGenerateMSRAEnabled = true;
              });
            } else {
              print(
                  "❌ Checklist generation failed: ${generateChecklistResponse.body}");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Checklist generation failed")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Error: ${request.status} - ${request.responseText}")),
            );
          }
        })
        ..onError.listen((e) {
          setState(() {
            isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving project: $e")),
          );
        })
        ..send(formData);
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      print("Error saving project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving project: $e")),
      );
    }
  }

  Future<Project?> fetchProjectById(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://localhost:5000/project/list'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final projectJson = data.firstWhere(
          (p) => p['projectid'].toString() == projectId,
          orElse: () => null);
      return projectJson != null ? Project.fromJson(projectJson) : null;
    }
    return null;
  }

  void onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectScreen(projectId: _project?.projectId),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MSRAGenerationScreen(project: _project),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnsiteChecklistScreen(project: _project),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewProject ? "New Project" : _project!.projectName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onPopCallback != null) {
              widget.onPopCallback!();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isNewProject && isOOG)
            ProjectTabWidget(
              selectedTabIndex: selectedTabIndex,
              onTabSelected: onTabSelected,
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProjectFormWidget(
                              key: _formKey,
                              project: _project,
                              isNewProject: isNewProject,
                              onChanged: _evaluateRunButton,
                            ),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth - 48),
                                  child: CargoDetailsTableWidget(
                                    key: _cargoKey,
                                    cargoList: _project!.cargo,
                                    isNewProject: isNewProject,
                                    isEditable: isNewProject,
                                    hasRun: hasRun,
                                    onRunPressed: _onRunPressed,
                                    resultList: resultsOOG,
                                    enableRunButton: enableRunButton,
                                    onCargoChanged: _evaluateRunButton,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            if (isOOG) ...[
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: constraints.maxWidth - 48),
                                    child: WorkScopeWidget(
                                      key: _workScopeKey,
                                      isNewProject: isNewProject,
                                      workScopeList: isNewProject ? null : _project!.scope,
                                      onWorkScopeChanged: _evaluateSaveButton,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              if (isNewProject || (_project!.scope?.isEmpty ?? true)) ...[
                                Container(
                                  width: 400,
                                  child: FileUploadWidget(
                                    key: _fileUploadKey,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (!isSaved)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: (isSaving || !enableSaveButton) ? null : onSavePressed,
                                        child: isSaving
                                            ? const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    height: 16,
                                                    width: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text("Saving..."),
                                                ],
                                              )
                                            : const Text("Save"),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                              ],
                              const SizedBox(height: 20),
                              if ((isOOG && isSaved) ||
                                  (isOOG &&
                                      _project?.msra != true &&
                                      !(_project!.scope?.isEmpty ?? true))) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: (hasGenerateMSRA || isGeneratingMSRA)
                                          ? null
                                          : () async {
                                            setState(() {
                                              isGeneratingMSRA = true;
                                            });

                                              final prefs = await SharedPreferences.getInstance();
                                              final token = prefs.getString('auth_token');
                                              final rawProjectId = _project?.projectId;

                                              print('Type of projectId: ${rawProjectId.runtimeType}');
                                              print('Value of projectId: $rawProjectId');

                                              int? projectId;
                                              if (rawProjectId is Set) {
                                                final firstValue = (rawProjectId as Set).first;
                                                projectId = int.tryParse(firstValue.toString());
                                              } else {
                                                projectId = int.tryParse(rawProjectId.toString());
                                              }

                                              if (projectId == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Invalid project ID.")),
                                                );
                                                setState(() {
                                                  isGeneratingMSRA = false;
                                                });
                                                return;
                                              }

                                              try {
                                                final response = await http.post(
                                                  Uri.parse('http://localhost:5000/project/generate-docs'),
                                                  headers: {
                                                    'Authorization': 'Bearer $token',
                                                    'Content-Type': 'application/json',
                                                  },
                                                  body: jsonEncode({'projectid': projectId}),
                                                );

                                                if (response.statusCode == 200) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("MS/RA generated successfully")),
                                                  );

                                                  setState(() {
                                                    hasGenerateMSRA = true;
                                                  });

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MSRAGenerationScreen(project: _project),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("Generation failed: ${response.body}")),
                                                  );
                                                }
                                              } catch (e) {
                                                print("Error triggering MS/RA generation: $e");
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                      content: Text("An error occurred while generating MS/RA")),
                                                );
                                              }
                                            },
                                      child: isGeneratingMSRA
                                      ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text("Generating..."),
                                        ],
                                      )
                                      : const Text("Generate MS/RA"),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if ((isOOG && isSaved) || (isOOG && !(_project!.scope?.isEmpty ?? true)))
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: OffsiteChecklistWidget(
                        projectId: int.tryParse(_project?.projectId.toString() ?? '0') ?? 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
