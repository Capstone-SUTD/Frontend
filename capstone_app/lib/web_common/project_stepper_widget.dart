import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'step_label.dart';

class ProjectStepperWidget extends StatefulWidget {
  final String currentStage;
  final Function(int) onStepTapped;
  final dynamic projectId;

  const ProjectStepperWidget({
    Key? key,
    required this.currentStage,
    required this.onStepTapped,
    required this.projectId,
  }) : super(key: key);

  @override
  _ProjectStepperWidgetState createState() => _ProjectStepperWidgetState();
}

class _ProjectStepperWidgetState extends State<ProjectStepperWidget> {
  late int _selectedStep;

  final List<String> _stepLabels = kStepLabels;

  @override
  void initState() {
    super.initState();
    final stage = widget.currentStage.toLowerCase();
    _selectedStep = kStepLabels.indexWhere(
      (label) => label.toLowerCase() == stage,
    );
    if (_selectedStep == -1) _selectedStep = 0;
  }

  void _onStepTapped(int index) async {
    setState(() {
      _selectedStep = index;
    });

    // Get the step label as stage (e.g., "Seller", "Customs", etc.)
    final String stage = _stepLabels[index];

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception("Token not found");

      final response = await http.post(
        Uri.parse('http://localhost:5000/project/update-stage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid': widget.projectId,
          'stage': stage,
        }),
      );

      if (response.statusCode == 200) {
        print("Stage updated to: $stage");
      } else {
        print("Failed to update stage: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update stage: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error updating stage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating stage")),
      );
    }

    widget.onStepTapped(index); // Notify parent
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Step Circles & Connector Line
            Stack(
              alignment: Alignment.center,
              children: [
                // Connector Line
                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: List.generate(_stepLabels.length - 1, (index) {
                      bool isCompleted = index < _selectedStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          color: isCompleted ? Colors.green : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),

                // Step Circles
                Row(
                  children: List.generate(_stepLabels.length, (index) {
                    bool isCompleted = index <= _selectedStep;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onStepTapped(index),
                        child: Column(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted ? Colors.green : Colors.grey,
                                border: Border.all(color: Colors.black, width: 1),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _stepLabels[index],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



