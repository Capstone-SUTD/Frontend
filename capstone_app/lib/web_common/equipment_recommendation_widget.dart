import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For copying to clipboard

class EquipmentRecommendationDialog extends StatefulWidget {
  const EquipmentRecommendationDialog({super.key});

  @override
  _EquipmentRecommendationDialogState createState() =>
      _EquipmentRecommendationDialogState();
}

class _EquipmentRecommendationDialogState
    extends State<EquipmentRecommendationDialog> {
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String crane = "";
  String trailerBed = "";
  String primeMover = "";

  // Function to show the second popup (results)
  void _showResultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 400,
            height: 320,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Recommended Equipment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: crane),
                    decoration: const InputDecoration(labelText: "Crane"),
                    readOnly: true,
                  ),
                  TextField(
                    controller: TextEditingController(text: trailerBed),
                    decoration: const InputDecoration(labelText: "Trailer Bed"),
                    readOnly: true,
                  ),
                  TextField(
                    controller: TextEditingController(text: primeMover),
                    decoration: const InputDecoration(labelText: "Prime Mover"),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Copy to clipboard
                          String copyText =
                              "Crane: $crane\nTrailer Bed: $trailerBed\nPrime Mover: $primeMover";
                          Clipboard.setData(ClipboardData(text: copyText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Copied to clipboard")),
                          );
                        },
                        child: const Text("Copy"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 400,
        height: 320,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView( // Prevents overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Cargo Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _lengthController,
                  decoration: const InputDecoration(labelText: "Length (m)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _widthController,
                  decoration: const InputDecoration(labelText: "Width (m)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: "Height (m)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: "Weight (tons)"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Call backend API here

                        // Mock values for now
                        setState(() {
                          crane = "Tower Crane";
                          trailerBed = "Flatbed Trailer";
                          primeMover = "Heavy-Duty Truck";
                        });

                        // Close this popup and open the results popup
                        Navigator.pop(context);
                        _showResultsDialog(context);
                      },
                      child: const Text("Run"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
