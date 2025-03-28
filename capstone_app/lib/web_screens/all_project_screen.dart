import 'project_screen.dart';
import 'package:flutter/material.dart';
import '../web_common/sidebar_widget.dart';
import '../web_common/project_table_widget.dart';
import '../web_common/equipment_recommendation_widget.dart';

class AllProjectsScreen extends StatelessWidget {
  const AllProjectsScreen({super.key});

  void _openEquipmentRecommendation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const EquipmentRecommendationDialog();
      },
    );
  }

  void _createNewProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProjectScreen(projectId: null)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 768;
          
          return Row(
            children: [
              // Sidebar - hidden on mobile in drawer
              if (!isMobile) Sidebar(selectedPage: '/projects/list'),

              // Main Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  child: Column(
                    children: [
                      // Project Table
                      Expanded(child: ProjectTableWidget()),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Equipment Recommendation & New Project Buttons
                      isMobile
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRecommendationButton(context, isMobile),
                                SizedBox(height: 8),
                                _buildNewProjectButton(context, isMobile),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildRecommendationButton(context, isMobile),
                                SizedBox(width: isMobile ? 8 : 16),
                                _buildNewProjectButton(context, isMobile),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Mobile drawer for sidebar
      drawer: Drawer(
        child: Sidebar(selectedPage: '/projects'),
      ),
    );
  }

  // Custom AppBar with responsive adjustments
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AppBar(
      title: const Text("All Projects"),
      backgroundColor: Colors.white,
      elevation: 1,
      leading: isMobile
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Add filter functionality
          },
        ),
        if (!isMobile)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Add additional options
            },
          ),
      ],
    );
  }

  // Reusable button for equipment recommendation
  Widget _buildRecommendationButton(BuildContext context, bool isMobile) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(isMobile ? double.infinity : 0, 48),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      onPressed: () => _openEquipmentRecommendation(context),
      child: Text(
        "Equipment Recommendation",
        style: TextStyle(fontSize: isMobile ? 14 : 16),
      ),
    );
  }

  // Reusable button for new project
  Widget _buildNewProjectButton(BuildContext context, bool isMobile) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(isMobile ? double.infinity : 0, 48),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      onPressed: () => _createNewProject(context),
      icon: const Icon(Icons.add),
      label: Text(
        "New Project",
        style: TextStyle(fontSize: isMobile ? 14 : 16),
      ),
    );
  }
}