import 'package:flutter/material.dart';

class ProjectStepperWidget extends StatefulWidget {
  final int currentStep;
  final Function(int) onStepTapped;

  const ProjectStepperWidget({super.key, required this.currentStep, required this.onStepTapped});

  @override
  _ProjectStepperWidgetState createState() => _ProjectStepperWidgetState();
}

class _ProjectStepperWidgetState extends State<ProjectStepperWidget> {
  late int _selectedStep;

  final List<String> _stepLabels = [
    "Seller", "Customs", "Loading", "Carrier", "Cargo Terminal",
    "Port", "Transport", "Port", "Cargo Terminal", "Carrier",
    "Customs", "Unloading", "Buyer"
  ];

  @override
  void initState() {
    super.initState();
    _selectedStep = widget.currentStep;
  }

  void _onStepTapped(int index) {
    setState(() {
      _selectedStep = index;
    });

    widget.onStepTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double stepWidth = (screenWidth - 40) / (_stepLabels.length - 1);

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
                // Connector Line (Placed at the back)
                Positioned(
                  top: 15, // Aligns the line at the middle of the circles
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

                // Step Circles (Placed at the front)
                Row(
                  children: List.generate(_stepLabels.length, (index) {
                    bool isCompleted = index <= _selectedStep;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onStepTapped(index),
                        child: Column(
                          children: [
                            // Step Circle
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

                            const SizedBox(height: 5), // Proper spacing

                            // Step Label
                            Text(
                              _stepLabels[index],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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



