import 'dart:async';

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
  List<Map<String, dynamic>> stakeholdersList = []; 
  Set<String> selectedRoles = {};
  bool _isLoadingStakeholders = false;
  String? _stakeholderError;

  final List<String> _roleOptions = ["HSEOfficer", "Operations", "ProjectManager", "Additional"];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchStakeholders();
  }

  void _initializeControllers() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _nameController = TextEditingController(text: widget.project?.projectName ?? "");
    _clientController = TextEditingController(text: widget.project?.client ?? "");
    _emailController = TextEditingController(text: widget.project?.emailsubjectheader ?? "");
    _startDateController = TextEditingController(
      text: widget.isNewProject ? formattedDate : widget.project?.startDate.toString() ?? "",
    );

    if (selectedStakeholders.isEmpty) {
      selectedStakeholders.add({"userId": "", "role": "", "name": ""});
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

  Future<void> _fetchStakeholders() async {
    if (!widget.isNewProject) return;

    setState(() {
      _isLoadingStakeholders = true;
      _stakeholderError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Authentication token not found");
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/project/stakeholders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          stakeholdersList = data.map((s) => {
            "userId": s["userid"].toString(),
            "name": s["username"].toString(),
            "email": s["email"]?.toString() ?? "",
          }).toList();
        });
      } else {
        throw Exception("Failed to load stakeholders: ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      setState(() => _stakeholderError = "Network error: ${e.message}");
    } on TimeoutException {
      setState(() => _stakeholderError = "Request timed out");
    } catch (e) {
      setState(() => _stakeholderError = "Error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoadingStakeholders = false);
      }
    }
  }

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        stakeholdersList = data.map((s) => {
          "userId": s["userid"].toString(),
          "name": s["username"].toString(),
        }).toList();
        
        // Ensure the list isn't empty before trying to populate it
        if (selectedStakeholders.isEmpty) {
          selectedStakeholders.add({"userId": "", "role": "", "name": ""});
        }
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

  void _addStakeholder() {
    setState(() {
      selectedStakeholders.add({"userId": "", "role": "", "name": ""});
    });
  }

  void _removeStakeholder(int index) {
    setState(() {
      selectedStakeholders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Project Project Name", _nameController),
          const SizedBox(height: 16),
          _buildTextField("Client", _clientController),
          const SizedBox(height: 16),
          _buildStakeholderSection(),
          const SizedBox(height: 16),
          _buildTextField("Email Subject Header", _emailController),
          const SizedBox(height: 16),
          _buildTextField("Start Date", _startDateController, readOnly: true),
        ],
      ),
    );
  }

  Widget _buildStakeholderSection() {
    if (!widget.isNewProject && widget.project != null && widget.project!.stakeholders.isNotEmpty) {
      return _buildStakeholderTable();
    }

    if (widget.isNewProject) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stakeholders",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_isLoadingStakeholders)
            const Center(child: CircularProgressIndicator()),
          if (_stakeholderError != null)
            Text(
              _stakeholderError!,
              style: const TextStyle(color: Colors.red),
            ),
          if (!_isLoadingStakeholders && _stakeholderError == null)
            ..._buildStakeholderInputs(),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStakeholderTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stakeholders",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Role")),
              ],
              rows: widget.project!.stakeholders.map((stakeholder) {
                return DataRow(cells: [
                  DataCell(Text(stakeholder.name ?? "N/A")),
                  DataCell(Text(stakeholder.email ?? "N/A")),
                  DataCell(Text(stakeholder.role)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStakeholderInputs() {
    return List.generate(selectedStakeholders.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Stakeholder",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: stakeholdersList.map((s) {
                  return DropdownMenuItem<String>(
                    value: s["userId"],
                    child: Text(s["name"]),
                  );
                }).toList(),
                value: selectedStakeholders[index]["userId"]!.isNotEmpty
                    ? selectedStakeholders[index]["userId"]
                    : null,
                onChanged: (value) {
                  if (value != null) {
                    final selected = stakeholdersList.firstWhere(
                      (s) => s["userId"] == value,
                      orElse: () => {"name": "", "email": ""},
                    );
                    setState(() {
                      selectedStakeholders[index] = {
                        "userId": value,
                        "role": selectedStakeholders[index]["role"] ?? "",
                        "name": selected["name"] ?? "",
                      };
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a stakeholder';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _roleOptions.map((role) {
                  final isDisabled = _isRoleSelectedElsewhere(role, index);
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    enabled: !isDisabled || role == "Additional",
                  );
                }).toList(),
                value: selectedStakeholders[index]["role"]!.isNotEmpty
                    ? selectedStakeholders[index]["role"]
                    : null,
                onChanged: (value) {
                  if (value != null && (!_isRoleSelectedElsewhere(value, index) || value == "Additional")) {
                    setState(() {
                      selectedStakeholders[index]["role"] = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            if (index > 0)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeStakeholder(index),
                tooltip: 'Remove stakeholder',
              ),
            if (index == 0)
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: _addStakeholder,
                tooltip: 'Add stakeholder',
              ),
          ],
        ),
      );
    });
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

Widget _buildHeaderCell(String title) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStakeholderSection() {
    if (!widget.isNewProject && widget.project != null && widget.project!.stakeholders.isNotEmpty) {
      return _buildStakeholderTable();
    }

    if (widget.isNewProject) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stakeholders",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_isLoadingStakeholders)
            const Center(child: CircularProgressIndicator()),
          if (_stakeholderError != null)
            Text(
              _stakeholderError!,
              style: const TextStyle(color: Colors.red),
            ),
          if (!_isLoadingStakeholders && _stakeholderError == null)
            ..._buildStakeholderInputs(),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStakeholderTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Stakeholders",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Role")),
              ],
              rows: widget.project!.stakeholders.map((stakeholder) {
                return DataRow(cells: [
                  DataCell(Text(stakeholder.name ?? "N/A")),
                  DataCell(Text(stakeholder.email ?? "N/A")),
                  DataCell(Text(stakeholder.role)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStakeholderInputs() {
    return List.generate(selectedStakeholders.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Select Stakeholder",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: stakeholdersList.map((s) {
                  return DropdownMenuItem<String>(
                    value: s["userId"],
                    child: Text(s["name"]),
                  );
                }).toList(),
                value: selectedStakeholders[index]["userId"]!.isNotEmpty
                    ? selectedStakeholders[index]["userId"]
                    : null,
                onChanged: (value) {
                  if (value != null) {
                    final selected = stakeholdersList.firstWhere(
                      (s) => s["userId"] == value,
                      orElse: () => {"name": "", "email": ""},
                    );
                    setState(() {
                      selectedStakeholders[index] = {
                        "userId": value,
                        "role": selectedStakeholders[index]["role"] ?? "",
                        "name": selected["name"] ?? "",
                      };
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a stakeholder';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _roleOptions.map((role) {
                  final isDisabled = _isRoleSelectedElsewhere(role, index);
                  return DropdownMenuItem(
                    value: role,
                    child: Text(
                      role,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    enabled: !isDisabled || role == "Additional",
                  );
                }).toList(),
                value: selectedStakeholders[index]["role"]!.isNotEmpty
                    ? selectedStakeholders[index]["role"]
                    : null,
                onChanged: (value) {
                  if (value != null && (!_isRoleSelectedElsewhere(value, index) || value == "Additional")) {
                    setState(() {
                      selectedStakeholders[index]["role"] = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            if (index > 0)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeStakeholder(index),
                tooltip: 'Remove stakeholder',
              ),
            if (index == 0)
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: _addStakeholder,
                tooltip: 'Add stakeholder',
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  List<Stakeholder> getSelectedStakeholders() {
    return selectedStakeholders.map((s) {
      return Stakeholder(
        userId: int.tryParse(s["userId"] ?? "") ?? -1,
        role: s["role"] ?? "",
        name: s["name"] ?? "",
        email: stakeholdersList.firstWhere(
          (stakeholder) => stakeholder["userId"] == s["userId"],
          orElse: () => {"email": ""},
        )["email"] as String,
      );
    }).toList();
  }

  String getProjectName() => _nameController.text.trim();
  String getClient() => _clientController.text.trim();
  String getEmailSubjectHeader() => _emailController.text.trim();
}