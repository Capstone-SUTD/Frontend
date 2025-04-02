import 'package:flutter/material.dart';
import '../common/sidebar_widget.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(selectedPage: '/dashboard'),

          // Main Dashboard Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    "Welcome, user!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "HSE Officer, ID: 123456",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 20),

                  // Top Row: Summary Cards
                  Row(
                    children: [
                      _buildSummaryCard(
                          title: "Current Projects", count: 3, icon: Icons.work),
                      SizedBox(width: 20),
                      _buildSummaryCard(
                          title: "Current Tasks", count: 5, icon: Icons.task),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Main Content: Project Directory + Task List
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Project Directory
                        Expanded(flex: 2, child: _buildProjectDirectory()),

                        SizedBox(width: 20),

                        // Task List
                        Expanded(flex: 3, child: _buildTaskList()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Summary Card (Current Projects & Tasks)
  Widget _buildSummaryCard(
      {required String title, required int count, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.orange),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Project Directory Widget
  Widget _buildProjectDirectory() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Project Directory",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildProjectItem("Project 1", isActive: true),
          _buildProjectItem("Project 2"),
          _buildProjectItem("Project 5"),
          _buildProjectItem("Project 4", isOnHold: true),
        ],
      ),
    );
  }

  // 🔹 Individual Project Item
  Widget _buildProjectItem(String projectName,
      {bool isActive = false, bool isOnHold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.device_hub, color: Colors.grey.shade700),
          SizedBox(width: 10),
          Expanded(child: Text(projectName, style: TextStyle(fontSize: 16))),
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text("Currently Working",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          if (isOnHold)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text("On Hold",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // 🔹 Task List Widget
  Widget _buildTaskList() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Task List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildTaskItem("Project 2 - Onsite Checklist",
              "Ensure All Safety Protocols Are In Place"),
          _buildTaskItem("Project 1 - Approvals", "Re-Upload Of MSRA"),
          _buildTaskItem("Project 1 - Approvals", "Approval Of MSRA"),
          _buildTaskItem("Project 1 - Approvals", "Approval Of MSRA"),
        ],
      ),
    );
  }

  // 🔹 Task Item Widget
  Widget _buildTaskItem(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    Expanded(child: Text(subtitle)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

