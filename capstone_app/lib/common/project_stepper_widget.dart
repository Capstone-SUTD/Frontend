import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'step_label.dart';

class ProjectStepperWidget extends StatefulWidget {
  final Function(int) onStepTapped;
  final dynamic projectId;
  final String? currentStage;

  // 1) New callback to notify parent about updated stage
  final Function(String newStage)? onStageUpdated;

  const ProjectStepperWidget({
    Key? key,
    required this.projectId,
    required this.currentStage,
    required this.onStepTapped,
    this.onStageUpdated, // <-- optional
  }) : super(key: key);

  @override
  _ProjectStepperWidgetState createState() => _ProjectStepperWidgetState();
}

class _ProjectStepperWidgetState extends State<ProjectStepperWidget> {
  late int _selectedStep;
  final List<String> _stepLabels = kStepLabels;
  static const String _onsiteInspectionLabel = 'Onsite Inspection'; // The second-to-last step label

  @override
  void initState() {
    super.initState();
    _selectedStep = _getStepIndex(widget.currentStage);
  }

  int _getStepIndex(String? stage) {
    if (stage == null) return 0;
    final index = _stepLabels.indexWhere(
        (label) => label.toLowerCase() == stage.toLowerCase());
    return index >= 0 ? index : 0;
  }

  void _fetchStage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception("Token not found");

      final response = await http.get(
        Uri.parse('http://localhost:5000/project/get-stage?projectid=${widget.projectId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String newStage = responseData['stage'];

        if (mounted) {
          setState(() {
            _selectedStep = _getStepIndex(newStage);
          });
        }
      } else {
        print("Failed to fetch stage: ${response.body}");
      }
    } catch (e) {
      print("Error fetching stage: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchStage(); // Fetch latest stage on page load
  }

  @override
  void didUpdateWidget(ProjectStepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStage != oldWidget.currentStage) {
      _fetchStage(); // Fetch latest stage on widget update
    }
  }

  // @override
  // void didUpdateWidget(ProjectStepperWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.currentStage != oldWidget.currentStage) {
  //     setState(() {
  //       _selectedStep = _getStepIndex(widget.currentStage);
  //     });
  //   }
  // }

  void _onStepTapped(int index) async {
    // Restrict clicking steps that are not "Onsite Inspection" unless the current stage is "Approved - Mr. Jeong"
    if (_stepLabels[index] != _onsiteInspectionLabel &&
        widget.currentStage != 'Approved - Mr. Jeong') {
      return;
    }

    setState(() {
      _selectedStep = index;
    });

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

        // 2) Call parent callback to update the parent's _project.stage
        if (widget.onStageUpdated != null) {
          widget.onStageUpdated!(stage);
        }
      } else {
        print("Failed to update stage: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update stage: ${response.body}")),
        );
      }
    } catch (e) {
      print("Error updating stage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating stage")),
      );
    }

    // Notify parent if they need to do something else
    widget.onStepTapped(index);
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
            Stack(
              alignment: Alignment.center,
              children: [
                // The horizontal line behind the step circles
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
                // The actual step circles and labels
                Row(
                  children: List.generate(_stepLabels.length, (index) {
                    bool isCompleted = index <= _selectedStep;
                    bool isClickable = _stepLabels[index] == _onsiteInspectionLabel &&
                        widget.currentStage == 'Approved - Mr. Jeong';

                    return Expanded(
                      child: GestureDetector(
                        onTap: isClickable ? () => _onStepTapped(index) : null,
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isClickable
                                    ? Colors.blue // Color for clickable step
                                    : Colors.black, // Default color for non-clickable
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