import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'project_model.dart';

class DataService {
  static Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); 

    final response = await http.get(
      Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print("API raw response: ${response.body}");

      if (decoded is List) {
        return decoded.map((item) => Project.fromJson(item)).toList();
      } else {
        print("Expected List but got: $decoded");
        return [];
      }
    } else {
      throw Exception('Failed to load projects: ${response.statusCode}');
    }
  }
}

