import 'package:flutter/material.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_stepper_widget.dart';
import '../web_common/download_msra_widget.dart';
import '../web_common/approval_list_widget.dart';
import 'onsite_checklist_screen.dart';

class MSRAGenerationScreen extends StatefulWidget {
  final dynamic project; // ideally use a Project type if available
  const MSRAGenerationScreen({Key? key, required this.project}) : super(key: key);

  @override
  _MSRAGenerationScreenState createState() => _MSRAGenerationScreenState();
}

class _MSRAGenerationScreenState extends State<MSRAGenerationScreen> {
  int _selectedApprovalTab = 0;
  late dynamic _project;
  late String _currentStage; // Local variable to hold the current stage

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _currentStage = _project.stage; // Initialize the stage from the project
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnsiteChecklistScreen(project: _project)),
      );
    }
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
            // Project Tab widget (for switching between screens)
            ProjectTabWidget(
              selectedTabIndex: 1,
              onTabSelected: _onTabSelected,
            ),
            const SizedBox(height: 20),

            // Project Stepper widget with local stage variable
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

            // Download MS/RA section
            DownloadMSRAWidget(
              projectId: _project?.projectId ?? "",
              createdDateTime: _project?.startDate ?? DateTime.now(),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Approval Tabs section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildApprovalTab("Pending (4)", 0),
                _buildApprovalTab("Approved (0)", 1),
                _buildApprovalTab("Denied (0)", 2),
              ],
            ),
            const SizedBox(height: 10),

            // Approval List Section
            Expanded(
              child: ApprovalListWidget(selectedTab: _selectedApprovalTab),
            ),
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







