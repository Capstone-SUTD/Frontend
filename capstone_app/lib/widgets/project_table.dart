import 'package:flutter/material.dart';

class ProjectsTable extends StatelessWidget {
  final List<Map<String, String>> projects = [
    {
      "name": "Project 1",
      "type": "Normal",
      "start": "Qingdao",
      "end": "Singapore",
      "task": "Offsite",
      "status": "In Progress",
      "date": "15/08/2024"
    },
    {
      "name": "Project 2",
      "type": "OOG",
      "start": "Jakarta",
      "end": "Singapore",
      "task": "Onsite",
      "status": "In Progress",
      "date": "22/09/2024"
    },
    {
      "name": "Project 3",
      "type": "Normal",
      "start": "Hong Kong",
      "end": "Singapore",
      "task": "Onsite",
      "status": "In Progress",
      "date": "03/10/2024"
    },
    {
      "name": "Project 4",
      "type": "Normal",
      "start": "Tokyo",
      "end": "Singapore",
      "task": "Offsite",
      "status": "On Hold",
      "date": "21/07/2024"
    },
    {
      "name": "Project 5",
      "type": "Normal",
      "start": "Hong Kong",
      "end": "Singapore",
      "task": "Onsite",
      "status": "On Hold",
      "date": "01/09/2024"
    },
    {
      "name": "Project 6",
      "type": "Normal",
      "start": "Shang Hai",
      "end": "Singapore",
      "task": "Onsite",
      "status": "Unstarted",
      "date": "08/10/2024"
    },
    {
      "name": "Project 7",
      "type": "Normal",
      "start": "Bangkok",
      "end": "Singapore",
      "task": "Onsite",
      "status": "Unstarted",
      "date": "01/11/2024"
    },
    {
      "name": "Project 8",
      "type": "OOG",
      "start": "Taiwan",
      "end": "Singapore",
      "task": "Onsite",
      "status": "Completed",
      "date": "06/07/2024"
    },
    {
      "name": "Project 9",
      "type": "Normal",
      "start": "Seoul",
      "end": "Singapore",
      "task": "Onsite",
      "status": "Completed",
      "date": "19/05/2024"
    },
    {
      "name": "Project 10",
      "type": "Normal",
      "start": "Osaka",
      "end": "Singapore",
      "task": "Onsite",
      "status": "Completed",
      "date": "15/03/2024"
    },
  ];

  ProjectsTable({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case "In Progress":
        return Colors.blue;
      case "On Hold":
        return Colors.orange;
      case "Unstarted":
        return Colors.grey;
      case "Completed":
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Adds spacing
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // Make table fill the width
            child: DataTable(
              columnSpacing: 20.0, // More spacing between columns
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text("Project Name", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Project Type", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Start Destination", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("End Destination", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Task Status", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: projects.map((project) {
                return DataRow(
                  cells: [
                    DataCell(Text(project["name"]!)),
                    DataCell(Text(project["type"]!)),
                    DataCell(Text(project["start"]!)),
                    DataCell(Text(project["end"]!)),
                    DataCell(Text(project["task"]!)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(project["status"]!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          project["status"]!,
                          style: TextStyle(color: _getStatusColor(project["status"]!), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataCell(Text(project["date"]!)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
