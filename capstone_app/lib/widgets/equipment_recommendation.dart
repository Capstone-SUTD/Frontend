/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EquipmentRecommendation extends StatefulWidget {
  @override
  _EquipmentRecommendationDialogState createState() => _EquipmentRecommendationDialogState();
}

class _EquipmentRecommendationDialogState extends State<EquipmentRecommendation> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;
  String? _recommendationResult;

  Future<void> _fetchRecommendation() async {
    setState(() {
      _isLoading = true;
      _recommendationResult = null;
    });

    final response = await http.post(
      Uri.parse('https://'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_input": _inputController.text}),
    );
  

    if (response.statusCode == 200) {
      setState(() {
        _recommendationResult = jsonDecode(response.body)['recommendation'];
      });
    } else {
      setState(() {
        _recommendationResult = "Error retrieving recommendation";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Equipment Recommendation"),
      content: _recommendationResult == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _inputController,
                  decoration: InputDecoration(labelText: "Enter Details"),
                ),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _fetchRecommendation,
                        child: Text("Get Recommendation"),
                      ),
              ],
            )
          : Text(_recommendationResult!), // Show result after fetching
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}

*/