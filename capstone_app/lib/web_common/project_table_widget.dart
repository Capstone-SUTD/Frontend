// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../models/data_service.dart';
import '../web_screens/project_screen.dart';

class ProjectTableWidget extends StatefulWidget {
  const ProjectTableWidget({super.key});

  @override
  _ProjectTableWidgetState createState() => _ProjectTableWidgetState();
}

class _ProjectTableWidgetState extends State<ProjectTableWidget> {
  late Future<List<Project>> _projectsFuture;
  int _currentPage = 0;
  final int _rowsPerPage = 10;
  String _searchQuery = '';
  String? _sortColumn;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _refreshProjects();
  }

  void _refreshProjects() {
    setState(() {
      _projectsFuture = DataService.getProjects();
    });
  }

  void _navigateToProject(String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectScreen(projectId: projectId),
        fullscreenDialog: true,
      ),
    ).then((_) => _refreshProjects());
  }

  List<Project> _filterAndSortProjects(List<Project> projects) {
    // Filter projects based on search query
    var filtered = projects.where((project) {
      return project.projectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.startDestination.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.endDestination.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          project.projectStatus.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort projects if sort column is selected
    if (_sortColumn != null) {
      filtered.sort((a, b) {
        int compareResult;
        switch (_sortColumn) {
          case 'Project Name':
            compareResult = a.projectName.compareTo(b.projectName);
            break;
          case 'Start Destination':
            compareResult = a.startDestination.compareTo(b.startDestination);
            break;
          case 'End Destination':
            compareResult = a.endDestination.compareTo(b.endDestination);
            break;
          case 'Status':
            compareResult = a.projectStatus.compareTo(b.projectStatus);
            break;
          case 'Date':
            compareResult = a.startDate.compareTo(b.startDate);
            break;
          default:
            compareResult = 0;
        }
        return _sortAscending ? compareResult : -compareResult;
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Projects',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() {
              _searchQuery = value;
              _currentPage = 0;
            }),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Project>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading projects",
                        //style: theme.textTheme.headline6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshProjects,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              final projects = _filterAndSortProjects(snapshot.data ?? []);
              final totalPages = (projects.length / _rowsPerPage).ceil();

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowHeight: 40,
                          dataRowHeight: 50,
                          sortColumnIndex: _sortColumn != null
                              ? const [
                                  'Project Name',
                                  'Start Destination',
                                  'End Destination',
                                  'Status',
                                  'Date'
                                ].indexOf(_sortColumn!)
                              : null,
                          sortAscending: _sortAscending,
                          columns: [
                            _buildDataColumn('Project Name', theme),
                            _buildDataColumn('Start Destination', theme),
                            _buildDataColumn('End Destination', theme),
                            _buildDataColumn('Status', theme),
                            _buildDataColumn('Date', theme),
                          ],
                          rows: projects
                              .skip(_currentPage * _rowsPerPage)
                              .take(_rowsPerPage)
                              .map((project) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          project.projectName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () => _navigateToProject(project.projectId),
                                      ),
                                      DataCell(Text(
                                        project.startDestination,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      DataCell(Text(
                                        project.endDestination,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      DataCell(_buildStatusBadge(project.projectStatus)),
                                      DataCell(Text(_formatDate(project.startDate))),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Showing ${_currentPage * _rowsPerPage + 1}-${(_currentPage + 1) * _rowsPerPage > projects.length ? projects.length : (_currentPage + 1) * _rowsPerPage} of ${projects.length} projects",
                          // style: theme.textTheme.caption,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              tooltip: 'Previous page',
                            ),
                            Text(
                              'Page ${_currentPage + 1} of $totalPages',
                             
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              tooltip: 'Next page',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  DataColumn _buildDataColumn(String label, ThemeData theme) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = label;
          _sortAscending = ascending;
        });
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> statusColors = {
      'In Progress': Colors.blue,
      'Completed': Colors.green,
      'On Hold': Colors.orange,
      'Unstarted': Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColors[status] ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}