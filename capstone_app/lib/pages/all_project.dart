import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/project_table.dart'; // Import the table widget

class AllProjectsPage extends StatelessWidget {
  const AllProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(), // Sidebar Widget
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: const Text('All Projects'),
                  backgroundColor: Colors.white,
                  elevation: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10), // Spacing above the table
                        ProjectsTable(), // Table widget
                        const SizedBox(height: 16), // Spacing below the table

                        // Buttons below the table
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showRecommendationDialog(context),
                              child: const Text("Equipment Recommendation"),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => _navigateToNewProject(context),
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
          ),
        ],
      ),
    );
  }

  // Function to show Equipment Recommendation popup
  void _showRecommendationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Equipment Recommendation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cargo Details"),
              TextField(decoration: const InputDecoration(labelText: "Length")),
              TextField(decoration: const InputDecoration(labelText: "Width")),
              TextField(decoration: const InputDecoration(labelText: "Height")),
              TextField(decoration: const InputDecoration(labelText: "Weight")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Send request to backend
                Navigator.pop(context);
              },
              child: const Text("Run"),
            ),
          ],
        );
      },
    );
  }

  // Function to navigate to the new project page
  void _navigateToNewProject(BuildContext context) {
    Navigator.pushNamed(context, '/new_project');
  }
}



