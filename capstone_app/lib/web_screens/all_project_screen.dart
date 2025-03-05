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
      MaterialPageRoute(builder: (context) => const ProjectScreen(projectId: null)), // Null indicates new project
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Sidebar
          Sidebar(selectedPage: '/projects'),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Project Table
                  const Expanded(child: ProjectTableWidget()),

                  const SizedBox(height: 16),

                  // Equipment Recommendation & New Project Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _openEquipmentRecommendation(context),
                        child: const Text("Equipment Recommendation"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _createNewProject(context),
                        icon: const Icon(Icons.add),
                        label: const Text("New Project"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("All Projects"),
      backgroundColor: Colors.white,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Add filter functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Add additional options
          },
        ),
      ],
    );
  }
}






