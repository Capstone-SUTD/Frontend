import 'dart:async';

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
  final _formKey = GlobalKey<FormState>();

  Future<void> _callBackendApi(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? "";

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/project/equipment-reach'),
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
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          crane = data['crane']?.toString() ?? "Not available";
          threshold = data['threshold']?.toString() ?? "Not available";
          trailer = data['trailer']?.toString() ?? "Not available";
        });
        _showResultsDialog(context);
      } else {
        throw Exception("Server responded with ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      _showError("Network error: ${e.message}");
    } on TimeoutException {
      _showError("Request timed out");
    } on FormatException {
      _showError("Invalid server response");
    } catch (e) {
      _showError("An error occurred: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showResultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Recommended Equipment"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultTile("Crane", crane),
              _buildResultTile("Threshold", threshold),
              _buildResultTile("Trailer", trailer),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: "Crane: $crane\nThreshold: $threshold\nTrailer: $trailer",
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard")),
              );
            },
            child: const Text("COPY"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value.isNotEmpty ? value : "Not available"),
    );
  }

  String? _validateNumberInput(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    final numValue = double.tryParse(value);
    if (numValue == null) return "Enter a valid number";
    if (numValue <= 0) return "Must be greater than 0";
    return null;
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cargo Details"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: "Length (m)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateNumberInput,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(
                  labelText: "Width (m)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateNumberInput,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: "Height (m)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateNumberInput,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validateNumberInput,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _callBackendApi(context),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("RUN"),
        ),
      ],
    );
  }
}