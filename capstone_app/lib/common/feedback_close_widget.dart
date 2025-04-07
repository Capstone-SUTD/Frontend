import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/project_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackAndClose extends StatefulWidget {
  final List<Stakeholder> stakeholders;
  final VoidCallback onClose;
  final Future<List<Stakeholder>> Function() fetchUpdatedStakeholders;
  final String projectId;
  final String projectStage;
  final Function(String) onStageUpdated;
  const FeedbackAndClose({
    required this.stakeholders,
    required this.onClose,
    required this.fetchUpdatedStakeholders,
    required this.projectId,
    required this.projectStage,
    required this.onStageUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _FeedbackAndCloseState createState() => _FeedbackAndCloseState();
}

class _FeedbackAndCloseState extends State<FeedbackAndClose> {
  final Map<int, TextEditingController> _controllers = {};
  List<Stakeholder> _updatedStakeholders = [];
  late String _projectStage;

  @override
  void initState() {
    super.initState();
    _updatedStakeholders = widget.stakeholders;
    _projectStage = widget.projectStage;
    for (var stakeholder in _updatedStakeholders) {
      _controllers[stakeholder.userId] = TextEditingController();
    }
  }

  void _updateStage(String newStage) {
      widget.onStageUpdated(newStage); // Update the project stage
  }

  Future<void> _submitFeedback(int userId, String role) async {
    String feedback = _controllers[userId]?.text ?? "";
    if (feedback.isEmpty) return;

    await _sendFeedbackToAPI(userId, feedback, role);

    List<Stakeholder> updatedList = await widget.fetchUpdatedStakeholders();

    setState(() {
      _updatedStakeholders = List.from(updatedList);
      _controllers.clear();
      for (var stakeholder in _updatedStakeholders) {
        _controllers[stakeholder.userId] = TextEditingController();
      }
    });
  }

  Future<void> _sendFeedbackToAPI(int userId, String feedback, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/feedback'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid': int.tryParse(widget.projectId) ?? 0,
          'comments': feedback,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
      } else {
        var responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Unknown error';
        _showErrorSnackbar("Failed. ($errorMessage)");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  Future<void> _closeProject() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/close'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid': int.tryParse(widget.projectId) ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _projectStage = "Project Completion";
        });
        _updateStage("Project Completion");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project successfully closed')),
        );
      } else {
        var responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Unknown error';
        _showErrorSnackbar("Failed. ($errorMessage)");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black87,
          selectionColor: Colors.black26,
          selectionHandleColor: Colors.black45,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Feedback and Close",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _updatedStakeholders.map((stakeholder) {
                  bool hasComments = stakeholder.comments != null &&
                                    stakeholder.comments!.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 120),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF167D86), // teal border
                              width: 6,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "Feedback from ${stakeholder.name ?? "Unknown"}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (hasComments)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  stakeholder.comments!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _controllers[stakeholder.userId],
                                    cursorColor: Colors.black87,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your feedback...",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black87),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () => _submitFeedback(
                                      stakeholder.userId,
                                      stakeholder.role,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF167D86),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                    ),
                                    child: const Text("Submit Feedback"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _projectStage == "Project Completion" ? null : _closeProject,
            style: ElevatedButton.styleFrom(
              backgroundColor: _projectStage == "Project Completion"
                  ? Colors.grey
                  : const Color(0xFF167D86),
              foregroundColor: Colors.white,
            ),
            child: Text(
              _projectStage == "Project Completion"
                  ? "Project Completed"
                  : "Close Project",
            ),
          ),
        ],
      ),
    );
  }


}