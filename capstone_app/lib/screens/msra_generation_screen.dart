import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';
import '../common/approval_list_widget.dart';
import '../common/download_msra_widget.dart';
import '../common/feedback_close_widget.dart';
import '../common/project_stepper_widget.dart';
import '../common/project_tab_widget.dart';
import 'onsite_checklist_screen.dart';
import 'project_screen.dart';

class MSRAGenerationScreen extends StatefulWidget {
  final dynamic project; // ideally use a Project type if available
  const MSRAGenerationScreen({Key? key, required this.project})
      : super(key: key);

  @override
  _MSRAGenerationScreenState createState() => _MSRAGenerationScreenState();
}

class _MSRAGenerationScreenState extends State<MSRAGenerationScreen> {
  int _selectedApprovalTab = 0;
  int _currentStep = 0;
  int _approvalStage = 0;
  late dynamic _project;
  late String _currentStage; // Local variable to hold the current stage
  List<Map<String, dynamic>> _rejectionList = []; // To store rejection details
  int _msVersions = 0; // To store MSVersions
  int _raVersions = 0; // To store RAVersions

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _currentStage = widget.project.stage;
    _callApprovalStatusApi();
  }

  Future<void> _callApprovalStatusApi() async {
    final url =
        Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/app/approval-rejection-status');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid': int.tryParse(_project?.projectId?.toString() ?? "0") ??
              0, // Ensure int
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Map rejection details
        List<Map<String, dynamic>> rejectionList = [];
        if (data['RejectionDetails'] != null) {
          for (var rejection in data['RejectionDetails']) {
            String? role = rejection['role'];
            String? comments = rejection['comments'];

            // Find the stakeholder name based on the role
            String? name;
            if (role != null) {
              for (var stakeholder in _project.stakeholders) {
                if (stakeholder.role == role) {
                  name = stakeholder.name;
                  break;
                }
              }
            }

            // Add the rejection details to the rejectionList
            rejectionList.add({
              'role': role,
              'comments': comments,
              'name': name,
            });
          }
        }

        print(rejectionList);

        // Store the MS and RA versions
        int msVersions = data['MSVersions'] ?? 0;
        int raVersions = data['RAVersions'] ?? 0;

        // Set state with the updated rejection list, MS and RA versions
        setState(() {
          _approvalStage =
              data['Approvals'] ?? 0; // Set approvalStage from API response
          _rejectionList = rejectionList; // Set rejectionList
          _msVersions = msVersions; // Set MSVersions
          _raVersions = raVersions; // Set RAVersions
        });
      } else {
        throw Exception(
            "Failed to load approval status: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  void _onApprovalTabSelected(int index) {
    setState(() {
      _selectedApprovalTab = index;
    });
  }

  void _handleVersionIncrease(String fileType) {
    setState(() {
      if (fileType == "MS") {
        _msVersions++;
      } else if (fileType == "RA") {
        _raVersions++;
      }
    });
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:(_, __, ___) => ProjectScreen(
            projectId: _project?.projectId,
            selectedTab: 0, 
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => OnsiteChecklistScreen(project: _project),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateApprovalStage(int newStage) {
    setState(() {
      _approvalStage = newStage;
    });
  }

  void _updateProjectStage(String newStage) {
    setState(() {
      _currentStage = newStage; // Update the current stage
    });
    print("3, Stage Updated: $newStage");
  }

  void _closeProject() {}

  Future<List<Stakeholder>> _fetchUpdatedStakeholders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/stakeholder-comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid':
              int.tryParse(_project?.projectId?.toString() ?? "0") ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(data);

        _project.stakeholders =
            data.map((s) => Stakeholder.fromJson(s)).toList();

        return _project.stakeholders;
      } else {
        throw Exception("Failed to load stakeholders");
      }
    } catch (e) {
      print("Error API Call: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF167D86),
        title: Text(
          _project.projectName ?? "Project",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Project Tab Widget (Switch Between Tabs)**
            ProjectTabWidget(
              selectedTabIndex: 1,
              onTabSelected: _onTabSelected,
            ),
            const SizedBox(height: 20),

            // **Stepper Widget**
            ProjectStepperWidget(
              currentStage: _currentStage,
              projectId: _project.projectId,
              onStepTapped: (newIndex) {
                // Optional logic when a step is tappedr
              },
            ),
            const Divider(),
            const SizedBox(height: 10),
            if (_msVersions > 0 || _raVersions > 0) ...[
              DownloadMSRAWidget(
                projectId: _project?.projectId ?? "",
                projectName: _project?.projectName ?? "",
                msVersion: _msVersions,
                raVersion: _raVersions,
              ),
              const SizedBox(height: 10),
              const Divider(),
              if (_approvalStage !=
                  3) // Only render the Row if approvalStage is not 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildApprovalTab("Pending", 0),
                    _buildApprovalTab("Approved", 1),
                    _buildApprovalTab("Denied", 2),
                    _buildApprovalTab("Re-Upload", 3),
                  ],
                ),
              const SizedBox(height: 15),
              Expanded(
                child: _approvalStage == 3
                    ? FeedbackAndClose(
                        stakeholders: _project.stakeholders,
                        onClose: _closeProject,
                        projectStage: _currentStage,
                        fetchUpdatedStakeholders: _fetchUpdatedStakeholders,
                        projectId: _project?.projectId ?? "",
                        onStageUpdated: _updateProjectStage
                      )
                    : ApprovalListWidget(
                        selectedTab: _selectedApprovalTab,
                        approvalStage: _approvalStage,
                        stakeholders: _project.stakeholders,
                        projectid: int.parse(_project.projectId.toString()),
                        rejectionList: _rejectionList,
                        onApprovalStageChange: _updateApprovalStage,
                        onVersionIncrease: _handleVersionIncrease,
                        onStageUpdated: _updateProjectStage
                      ),
              ),
            ] else ...[
              const Center(
                child: Text("No MS/RA files have been generated yet."),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTab(String label, int index) {
    bool isSelected = _selectedApprovalTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedApprovalTab = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Color(0xFF167D86) : Colors.grey,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
