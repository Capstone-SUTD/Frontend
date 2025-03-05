import 'dart:convert';
import 'package:flutter/services.dart';
import 'project_model.dart';

class DataService {
  static Future<List<Project>> getProjects() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final List<dynamic> jsonData = json.decode(response);
    return jsonData.map((item) => Project.fromJson(item)).toList();
  }
}

/* When linking to Azure SQL

class DataService {
  static Future<List<Project>> getProjects() async {
    final response = await http.get(Uri.parse('https://your-api-endpoint/projects'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Project.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }
}

*/