import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import '../models/project_model.dart';

class ProjectFormWidget extends StatefulWidget {
  final Project? project;
  final bool isNewProject;

  const ProjectFormWidget({
    super.key,
    this.project,
    required this.isNewProject,
  });

  @override
  _ProjectFormWidgetState createState() => _ProjectFormWidgetState();
}

class _ProjectFormWidgetState extends State<ProjectFormWidget> {
  late TextEditingController _nameController;
  late TextEditingController _clientController;
  late TextEditingController _stakeholderController;
  late TextEditingController _emailController;
  late TextEditingController _startDateController;

  @override
  void initState() {
    super.initState();
    
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Generate today's date

    _nameController = TextEditingController(text: widget.project?.projectName ?? "");
    _clientController = TextEditingController(text: widget.project?.client ?? "");
    _stakeholderController = TextEditingController(); // No data in model, leave empty
    _emailController = TextEditingController(); // No data in model, leave empty
    _startDateController = TextEditingController(
      text: widget.isNewProject ? formattedDate : widget.project?.startDate.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clientController.dispose();
    _stakeholderController.dispose();
    _emailController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField("Name", _nameController),
        _buildTextField("Client", _clientController),
        _buildTextField("Stakeholder", _stakeholderController),
        _buildTextField("Email Subject Header", _emailController),

        // Auto-Generated Start Date Field (Read-Only)
        _buildTextField("Start Date", _startDateController, readOnly: true),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}



