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
  String crane_rule = "";
  String threshold_rule = "";

  bool _isLoading = false;

  Future<void> _callBackendApi(BuildContext context) async {
    final url = Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/equipment');
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
          crane_rule = data['crane_rule'] ?? "N/A";
          threshold_rule = data['threshold_rule']?.toString() ?? "N/A";
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 500,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recommended Equipment",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    const Text("By Threshold Rule", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildStyledTextField("Crane", crane_rule),
                    const SizedBox(height: 10),
                    _buildStyledTextField("Threshold (kg)", threshold_rule),
                    const SizedBox(height: 20),

                    const Text("By ML Model", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildStyledTextField("Crane", crane),
                    const SizedBox(height: 10),
                    _buildStyledTextField("Threshold (kg)", threshold),
                    const SizedBox(height: 10),
                    _buildStyledTextField("Trailer", trailer),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            String copyText =
                                "By Rule\nCrane: $crane_rule\nThreshold (kg): $threshold_rule\nBy ML Model\nCrane: $crane\nThreshold (kg): $threshold\nTrailer: $trailer";
                            Clipboard.setData(ClipboardData(text: copyText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Copied to clipboard")),
                            );
                          },
                          child: const Text("Copy", style: TextStyle(color: Color(0xFF167D86))),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF167D86),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledTextField(String label, String value) {
    final focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        focusNode: focusNode,
        child: StatefulBuilder(
          builder: (context, setState) {
            focusNode.addListener(() {
              setState(() {}); // Rebuild when focus changes
            });

            return TextField(
              controller: TextEditingController(text: value),
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                isDense: true,
                labelStyle: TextStyle(
                  color: focusNode.hasFocus ? const Color(0xFF167D86) : Colors.black,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF167D86)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Cargo Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Please fill in all cargo dimensions before proceeding.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),

              _buildFieldRow("Length", _lengthController, "m"),
              const SizedBox(height: 12),
              _buildFieldRow("Width", _widthController, "m"),
              const SizedBox(height: 12),
              _buildFieldRow("Height", _heightController, "m"),
              const SizedBox(height: 12),
              _buildFieldRow("Weight", _weightController, "kg"),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4EB8C1),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _callBackendApi(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF167D86),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("Run"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldRow(String label, TextEditingController controller, String unit) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: const InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF167D86)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(unit, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}