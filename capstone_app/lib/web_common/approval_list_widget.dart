import 'package:flutter/material.dart';

class ApprovalListWidget extends StatefulWidget {
  final int selectedTab;

  const ApprovalListWidget({super.key, required this.selectedTab});

  @override
  _ApprovalListWidgetState createState() => _ApprovalListWidgetState();
}

class _ApprovalListWidgetState extends State<ApprovalListWidget> {
  final List<Map<String, dynamic>> _pendingApprovals = [
    {"role": "HSE Officer", "approved": false, "rejected": false},
    {"role": "Product Manager", "approved": false, "rejected": false},
    {"role": "Operation Manager", "approved": false, "rejected": false},
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.selectedTab == 0) {
      // Pending Approvals
      return ListView.builder(
        itemCount: _pendingApprovals.length,
        itemBuilder: (context, index) {
          var approval = _pendingApprovals[index];
          return Card(
            child: ListTile(
              title: Text("MSRA Approval by ${approval["role"]}"),
              subtitle: const Text("Action required by [Name]"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        approval["approved"] = true;
                        _pendingApprovals.removeAt(index);
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Approve"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        approval["rejected"] = true;
                        _pendingApprovals.removeAt(index);
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Reject"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const Center(child: Text("No approvals available"));
  }
}
