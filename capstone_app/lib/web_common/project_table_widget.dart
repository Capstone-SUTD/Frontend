import 'package:flutter/material.dart';

import '../models/project_model.dart';
import '../web_screens/project_screen.dart';

class ProjectTableWidget extends StatefulWidget {
  final List<Project> projects;

  const ProjectTableWidget({super.key, required this.projects});

  @override
  _ProjectTableWidgetState createState() => _ProjectTableWidgetState();
}

class _ProjectTableWidgetState extends State<ProjectTableWidget> {
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  void _navigateToProject(BuildContext context, String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProjectScreen(projectId: projectId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = widget.projects.isEmpty
        ? 1
        : (widget.projects.length / _rowsPerPage).ceil();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: DataTable(
                columnSpacing: 20,
                headingRowHeight: 40,
                dataRowHeight: 50,
                columns: const [
                  DataColumn(label: Text("Project Name")),
                  DataColumn(label: Text("Start Destination")),
                  DataColumn(label: Text("End Destination")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Date")),
                ],
                rows: widget.projects
                    .skip(_currentPage * _rowsPerPage)
                    .take(_rowsPerPage)
                    .map((project) => DataRow(
                          cells: [
                            DataCell(
                              Text(project.projectName),
                              onTap: () => _navigateToProject(
                                  context, project.projectId),
                            ),
                            DataCell(Text(project.startDestination)),
                            DataCell(Text(project.endDestination)),
                            DataCell(_buildStatusBadge(project.projectStatus)),
                            DataCell(Text(_formatDate(project.startDate))),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Page ${_currentPage + 1} out of $totalPages"),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 0 && widget.projects.isNotEmpty
                      ? () => setState(() => _currentPage--)
                      : null,
                  child: const Text("Previous"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _currentPage < totalPages - 1 &&
                          widget.projects.isNotEmpty
                      ? () => setState(() => _currentPage++)
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status) {
      case "In Progress":
        badgeColor = Colors.blue;
        break;
      case "Completed":
        badgeColor = Colors.green;
        break;
      case "On Hold":
        badgeColor = Colors.orange;
        break;
      case "Unstarted":
        badgeColor = Colors.grey;
        break;
      default:
        badgeColor = Colors.black;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
