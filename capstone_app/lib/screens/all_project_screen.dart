import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project_model.dart';
import '../common/equipment_recommendation_widget.dart';
import '../common/project_table_widget.dart';
import '../common/sidebar_widget.dart';
import 'project_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AllProjectsScreen extends StatefulWidget {
  const AllProjectsScreen({super.key});

  @override
  _AllProjectsScreenState createState() => _AllProjectsScreenState();
}

class _AllProjectsScreenState extends State<AllProjectsScreen>
    with AutomaticKeepAliveClientMixin, RouteAware {
  List<Project> projectsList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  bool get wantKeepAlive =>
      true; // Keep alive and rebuild widget when it's visible

  @override
  void initState() {
    super.initState();
    getProjects(); // Initial API call on screen load
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // Called when this screen is popped back into view
    getProjects(); // Make API call again when navigating back to the screen
  }

  Future<void> getProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("Decoded response: $decoded");

        List<dynamic>? rawProjects;

        if (decoded is List) {
          // Format: [ {...}, {...} ]
          rawProjects = decoded;
        } else if (decoded is Map && decoded['projects'] is List) {
          // Format: { "projects": [ {...}, {...} ] }
          rawProjects = decoded['projects'];
        }

        if (rawProjects != null) {
          List<Project> projects = List<Project>.from(
            rawProjects.map((item) => Project.fromJson(item)),
          );

          setState(() {
            projectsList = projects;
            isLoading = false;
            errorMessage = null;
          });
        } else {
          setState(() {
            projectsList = [];
            errorMessage = 'Unexpected response format.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load projects: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching data: $error';
        isLoading = false;
      });
    }
  }

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
      MaterialPageRoute(
          builder: (context) => ProjectScreen(
                projectId: null,
                onPopCallback: getProjects,
              )), // Null indicates new project
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is required to rebuild the widget properly.
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          Sidebar(selectedPage: '/projects'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.redAccent, size: 48),
                                    const SizedBox(height: 12),
                                    Text(
                                      errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: getProjects,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text("Try Again"),
                                    ),
                                  ],
                                ),
                              )
                            : projectsList.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No projects found.",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ProjectTableWidget(projects: projectsList),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("OOG Navigator"),
      backgroundColor: Colors.white,
      elevation: 1,
    );
  }
}
