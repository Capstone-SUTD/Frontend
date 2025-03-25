import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_stepper_widget.dart';
import '../web_common/download_msra_widget.dart';
import '../web_common/approval_list_widget.dart';
import 'onsite_checklist_screen.dart';
import 'project_screen.dart';

class MSRAGenerationScreen extends StatefulWidget {
  final dynamic project; // ideally use a Project type if available
  const MSRAGenerationScreen({Key? key, required this.project}) : super(key: key);

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
    _callApprovalStatusApi(); 
  }

  Future<void> _callApprovalStatusApi() async {
  final url = Uri.parse('http://localhost:5000/app/approval-rejection-status');

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
        'projectid': int.tryParse(_project?.projectId?.toString() ?? "0") ?? 0, // Ensure int
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
        _approvalStage = data['Approvals'] ?? 0; // Set approvalStage from API response
        _rejectionList = rejectionList; // Set rejectionList
        _msVersions = msVersions; // Set MSVersions
        _raVersions = raVersions; // Set RAVersions
      });
    } else {
      throw Exception("Failed to load approval status: ${response.statusCode}");
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

  void _onTabSelected(int index) {
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnsiteChecklistScreen(project: _project)),
      );
    }
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProjectScreen(projectId: _project?.projectId))
      );

    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MS/RA Generation")),
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
                // Optional logic when a step is tapped
              },
              onStageUpdated: (newStage) {
                setState(() {
                  // Only update the local _currentStage variable
                  _currentStage = newStage;
                });
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            if (_project?.msra == true) ...[
              DownloadMSRAWidget(
                projectId: _project?.projectId ?? "",
                msVersion: _msVersions,
                raVersion: _raVersions,
              ),
              const SizedBox(height: 20),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildApprovalTab("Pending", 0),
                  _buildApprovalTab("Approved", 1),
                  _buildApprovalTab("Denied", 2),
                  _buildApprovalTab("Reupload", 3)
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ApprovalListWidget(
                  selectedTab: _selectedApprovalTab,
                  approvalStage: _approvalStage,
                  stakeholders: _project.stakeholders,
                  projectid: int.parse(_project.projectId.toString()),
                  rejectionList: _rejectionList,
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
              color: isSelected ? Colors.orange : Colors.grey,
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






