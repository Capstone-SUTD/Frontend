import 'package:flutter/material.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_stepper_widget.dart';
import '../web_common/download_msra_widget.dart';
import '../web_common/approval_list_widget.dart';
import 'onsite_checklist_screen.dart';

class MSRAGenerationScreen extends StatefulWidget {
  final dynamic project;
  const MSRAGenerationScreen({Key? key, required this.project}) : super(key: key);

  @override
  _MSRAGenerationScreenState createState() => _MSRAGenerationScreenState();
}

class _MSRAGenerationScreenState extends State<MSRAGenerationScreen> {
  int _selectedApprovalTab = 0;
  int _currentStep = 0;
  late dynamic _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
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
              currentStep: _currentStep,
              projectId: _project?.projectId ?? "",
              onStepTapped: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
            ),

            const SizedBox(height: 20),
            const Divider(),

            // **Download MS/RA Section**
            DownloadMSRAWidget(
              projectId: _project?.projectId ?? "",
              createdDateTime: _project?.startDate ?? DateTime.now(),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // **Approval Tabs**
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildApprovalTab("Pending (4)", 0),
                _buildApprovalTab("Approved (0)", 1),
                _buildApprovalTab("Denied (0)", 2),
              ],
            ),

            const SizedBox(height: 10),

            // **Approval List Section**
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
      onTap: () => _onApprovalTabSelected(index),
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






