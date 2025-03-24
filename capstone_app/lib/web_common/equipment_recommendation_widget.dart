import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  String threshold = "";
  String trailer = "";

  bool _isLoading = false;

  Future<void> _callBackendApi(BuildContext context) async {
    final url = Uri.parse('http://localhost:5000/project/equipment');
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "weight": double.parse(_weightController.text),
          "length": double.parse(_lengthController.text),
          "width": double.parse(_widthController.text),
          "height": double.parse(_heightController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          crane = data['crane'] ?? "N/A";
          threshold = data['threshold']?.toString() ?? "N/A";
          trailer = data['trailer'] ?? "N/A";
        });

        if (mounted) {
          Navigator.pop(context); // Close the input dialog
          _showResultsDialog(context); // Show results
        }
      } else {
        _showErrorSnackbar("Failed to get recommendation. (${response.statusCode})");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _showErrorSnackbar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showResultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    controller: TextEditingController(text: threshold),
                    decoration: const InputDecoration(labelText: "Threshold"),
                    readOnly: true,
                  ),
                  TextField(
                    controller: TextEditingController(text: trailer),
                    decoration: const InputDecoration(labelText: "Trailer"),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          String copyText =
                              "Crane: $crane\nThreshold: $threshold\nTrailer: $trailer";
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
          child: SingleChildScrollView(
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
                  decoration: const InputDecoration(labelText: "Weight (kg)"),
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
                      onPressed: _isLoading
                          ? null
                          : () => _callBackendApi(context),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Run"),
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

