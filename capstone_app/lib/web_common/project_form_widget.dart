import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project_model.dart';

class ProjectFormWidget extends StatefulWidget {
  final Project? project;
  final bool isNewProject;

  const ProjectFormWidget({
    Key? key,
    this.project,
    required this.isNewProject,
  }) : super(key: key);

  @override
  ProjectFormWidgetState createState() => ProjectFormWidgetState();
}

class ProjectFormWidgetState extends State<ProjectFormWidget> {
  late TextEditingController _nameController;
  late TextEditingController _clientController;
  late TextEditingController _emailController;
  late TextEditingController _startDateController;

  List<Map<String, String>> selectedStakeholders = [];
  List<Map<String, String>> stakeholdersList = []; 
  Set<String> selectedRoles = {};

  final List<String> _roleOptions = ["HSEOfficer", "Operations", "ProjectManager", "Additional"];

  @override
  void initState() {
    super.initState();

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _nameController = TextEditingController(text: widget.project?.projectName ?? "");
    _clientController = TextEditingController(text: widget.project?.client ?? "");
    _emailController = TextEditingController(text: widget.project?.emailsubjectheader ?? "");
    _startDateController = TextEditingController(
      text: widget.isNewProject ? formattedDate : widget.project?.startDate.toString() ?? "",
    );

    _fetchStakeholders();

    // Ensure at least one row exists
    if (selectedStakeholders.isEmpty) {
      selectedStakeholders.add({"userId": "", "role": ""});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _emailController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  // Fetch Stakeholders from API
  Future<void> _fetchStakeholders() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      Uri.parse('http://localhost:5000/project/stakeholders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // optional but recommended
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        stakeholdersList = data.map((s) => {
          "userId": s["userid"].toString(),
          "name": s["username"].toString(),
        }).toList();
      });
    } else {
      throw Exception("Failed to load stakeholders");
    }
  } catch (e) {
    print("Error fetching stakeholders: $e");
  }
  }

  // Check if a Role is Already Assigned
  bool _isRoleSelectedElsewhere(String role, int currentIndex) {
    return selectedStakeholders.any((s) =>
        s["role"] == role && role != "Additional" && selectedStakeholders.indexOf(s) != currentIndex);
  }

  // Add a New Stakeholder Row
  void _addStakeholder() {
    setState(() {
      selectedStakeholders.add({"userId": "", "role": ""});
    });
  }

  // Remove a Stakeholder Row
  void _removeStakeholder(int index) {
    setState(() {
      selectedStakeholders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Ensure padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Name", _nameController),
          const SizedBox(height: 16),
          _buildTextField("Client", _clientController),
          const SizedBox(height: 16),

          // Stakeholder Section
          Column(
            children: List.generate(selectedStakeholders.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    // Stakeholder Dropdown (Searchable)
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Select Stakeholder",
                          border: OutlineInputBorder(),
                        ),
                        items: stakeholdersList.map((s) {
                          return DropdownMenuItem(value: s["userId"], child: Text(s["name"]!));
                        }).toList(),
                        value: selectedStakeholders[index]["userId"]!.isNotEmpty
                            ? selectedStakeholders[index]["userId"]
                            : null,
                        onChanged: (value) {
                          setState(() {
                            selectedStakeholders[index]["userId"] = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Role Dropdown
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Role",
                          border: OutlineInputBorder(),
                        ),
                        items: _roleOptions.map((role) {
                          bool isDisabled = _isRoleSelectedElsewhere(role, index);
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role,
                              style: TextStyle(
                                color: isDisabled ? Colors.grey : Colors.black,
                              ),
                            ),
                            enabled: !isDisabled || role == "Additional",
                          );
                        }).toList(),
                        value: selectedStakeholders[index]["role"]!.isNotEmpty
                            ? selectedStakeholders[index]["role"]
                            : null,
                        onChanged: (value) {
                          if (!_isRoleSelectedElsewhere(value!, index) || value == "Additional") {
                            setState(() {
                              selectedStakeholders[index]["role"] = value;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 10),

                    // Remove Button (only for rows other than the first)
                    if (index > 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeStakeholder(index),
                      ),

                    // Add Button (only in first row)
                    if (index == 0)
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        onPressed: _addStakeholder,
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          _buildTextField("Email Subject Header", _emailController),
          const SizedBox(height: 16),

          // Auto-Generated Start Date Field (Read-Only)
          _buildTextField("Start Date", _startDateController, readOnly: true),
        ],
      ),
    );
  }

  /// **Reusable TextField Builder**
  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Expose values to parent using GlobalKey
  // List<Map<String, String>> getSelectedStakeholders() => selectedStakeholders;
  List<Map<String, dynamic>> getSelectedStakeholders() {
    return selectedStakeholders.map((s) {
      final rawUserId = s["userId"];
      final parsedUserId = int.tryParse(rawUserId ?? '') ?? -1;

      print("Final userId to send: $parsedUserId, type: ${parsedUserId.runtimeType}");

      return {
        "userId": parsedUserId,
        "role": s["role"] ?? "",
      };
    }).toList();
  }
  String getProjectName() => _nameController.text;
  String getClient() => _clientController.text;
  String getEmailSubjectHeader() => _emailController.text;
}






