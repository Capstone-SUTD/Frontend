import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/data_service.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_form_widget.dart';
import '../web_common/cargo_details_table_widget.dart';
import '../web_common/work_scope_widget.dart';
import '../web_common/offsite_checklist_widget.dart';
import '../web_common/msra_file_upload_widget.dart';
import 'msra_generation_screen.dart';
import 'onsite_checklist_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProjectScreen extends StatefulWidget {
  final String? projectId;
  const ProjectScreen({super.key, this.projectId});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Project? _project;
  bool isNewProject = true;
  bool isOOG = false;
  bool isLoading = true;
  bool hasRun = false;
  bool isSaved = false;
  bool showChecklist = false;
  bool isGenerateMSRAEnabled = false;
  int selectedTabIndex = 0;

  final GlobalKey<ProjectFormWidgetState> _formKey = GlobalKey<ProjectFormWidgetState>();
  final GlobalKey<CargoDetailsTableWidgetState> _cargoKey = GlobalKey<CargoDetailsTableWidgetState>();
  final GlobalKey<WorkScopeWidgetState> _workScopeKey = GlobalKey<WorkScopeWidgetState>();
  final GlobalKey<FileUploadWidgetState> _fileUploadKey = GlobalKey<FileUploadWidgetState>();

  @override
  void initState() {
    super.initState();
    _loadProjectData();
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
          startDate: DateTime.now(),
          stakeholders: [],
          cargo: [],
          scope: [],
        ),
      );

      if (foundProject.projectId.isNotEmpty) {
        setState(() {
          _project = foundProject;
          isNewProject = false;
          isOOG = foundProject.projectType == "OOG";
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

      String? oogResult = responseData['cargo']?[0]?['oog'];

      setState(() {
        isOOG = oogResult == "Yes";
        hasRun = true;
        _project = Project(
          client: _formKey.currentState?.getClient() ?? '',
          projectId: responseData["projectid"]?.toString() ?? '',
          projectName: _formKey.currentState?.getProjectName() ?? '',
          projectType: oogResult == "Yes" ? "OOG" : "Normal",
          startDestination: '',
          endDestination: '',
          projectStatus: '',
          emailsubjectheader: '',
          startDate: DateTime.now(),
          stakeholders: [],
          cargo: [], 
          scope: [],
        );
      });
    } else {
      print("Failed to classify OOG. Status: ${response.statusCode}");
    }
  }

  void onSavePressed() async {
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

    if (vendorMS == null || vendorRA == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please ensure both MS and RA files are uploaded.")),
      );
      return;
    }

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
      formData.appendBlob('VendorMS', vendorMS, vendorMS.name);
      formData.appendBlob('VendorRA', vendorRA, vendorRA.name);
      formData.append('projectid', projectId);
      formData.append('scope', jsonEncode(scopeList));

      final request = html.HttpRequest();
      request
        ..open('POST', 'http://localhost:5000/project/save')
        ..setRequestHeader('Authorization', 'Bearer $token')
        ..onLoadEnd.listen((event) async {
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
              print("❌ Checklist generation failed: ${generateChecklistResponse.body}");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Checklist generation failed")),
              );
            }

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${request.status} - ${request.responseText}")),
            );
          }
        })
        ..onError.listen((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving project: $e")),
          );
        })
        ..send(formData);
    } catch (e) {
      print("Error saving project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving project: $e")),
      );
    }
  }

  void onTabSelected(int index) {
    setState(() {
      selectedTabIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MSRAGenerationScreen(project: _project),
          ),
        );
        break;
      case 2:
        Navigator.push(
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
          onPressed: () => Navigator.pop(context),
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
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProjectFormWidget(
                            key: _formKey,
                            project: _project,
                            isNewProject: isNewProject,
                          ),
                          const SizedBox(height: 20),
                          CargoDetailsTableWidget(
                            key: _cargoKey,
                            cargoList: _project!.cargo,
                            isNewProject: isNewProject,
                            isEditable: isNewProject,
                            hasRun: hasRun,
                            onRunPressed: _onRunPressed,
                            projectType: _project!.projectType,
                          ),
                          const SizedBox(height: 20),
                          if (isOOG) ...[
                            WorkScopeWidget(
                              key: _workScopeKey,
                              isNewProject: isNewProject,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 400,
                              child: FileUploadWidget(
                                key: _fileUploadKey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: onSavePressed,
                                  child: const Text("Save"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: isGenerateMSRAEnabled
                                      ? () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          final token = prefs.getString('auth_token');

                                          // Handle null or unexpected project ID
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
                                            return;
                                          }

                                          try {
                                            final response = await http.post(
                                              Uri.parse('http://localhost:5000/project/generate-docs'),
                                              headers: {
                                                'Authorization': 'Bearer $token',
                                                'Content-Type': 'application/json',
                                              },
                                              body: jsonEncode({
                                                'projectid': projectId,
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("MS/RA generated successfully")),
                                              );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => MSRAGenerationScreen(project: _project),
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
                                              SnackBar(
                                                content: Text("An error occurred while generating MS/RA"),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  child: const Text("Generate MS/RA"),
                                ),

                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isOOG && isSaved)
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










