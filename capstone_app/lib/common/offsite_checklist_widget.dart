import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OffsiteChecklistWidget extends StatefulWidget {
  final int projectId;
  const OffsiteChecklistWidget({Key? key, required this.projectId}) : super(key: key);

  @override
  _OffsiteChecklistWidgetState createState() => _OffsiteChecklistWidgetState();
}

class _OffsiteChecklistWidgetState extends State<OffsiteChecklistWidget> {
  Map<String, bool> expandedSections = {};
  Map<String, dynamic> checklistData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChecklistData();
  }

  Future<void> fetchChecklistData() async {
    print("🟢 Sending GET request with projectid=${widget.projectId} (type: ${widget.projectId.runtimeType})");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse("https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/get-project-checklist?projectid=${widget.projectId}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final offsite = jsonData['OffSiteFixed'] as Map<String, dynamic>;

        // Process each section (e.g., Administrative, Safety Precautions)
        offsite.forEach((section, content) {
          List<String> descriptions = [];

          int? taskId = content['taskid'];
          bool completed = content['completed'] ?? false;
          bool has_comments = content['has_comments'] ?? false;
          bool has_attachment = content['has_attachment'] ?? false;
          // String comments = content['comments'] ?? "";

          // Extract all other keys as descriptions
          content.forEach((key, value) {
            if (key != 'taskid' && key != 'completed' && key != 'has_comments' && key != 'has_attachment') {
              if (value is String) {
                descriptions.add(value);
              } else if (value is List) {
                descriptions.addAll(value.map((v) => v.toString()));
              } else if (value is Map) {
                descriptions.addAll(value.values.map((v) => v.toString()));
              }
            }
          });

          checklistData[section] = {
            'taskid': taskId,
            'completed': completed,
            'has_comments': has_comments,
            'has_attachment': has_attachment,
            //'comments': comments,
            'descriptions': descriptions
          };

          expandedSections[section] = false;
        });

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load checklist");
      }
    } catch (e) {
      print("Error fetching checklist: $e");
    }
  }

  Future<void> updateChecklistStatus(int taskid, bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse("https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/project/update-checklist-completion"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskid': taskid, 'completed': completed}),
      );

      if (response.statusCode != 200) {
        print("❌ Failed to update checklist task $taskid");
      } else {
        print("✅ Checklist task $taskid updated to $completed");
      }
    } catch (e) {
      print("Error updating checklist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: MediaQuery.of(context).size.height * 0.92,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(
              color: Color(0xFF167D86),
              ),
            )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Offsite Checklist",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: checklistData.keys.map((section) {
                          return _buildChecklistSection(section);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildChecklistSection(String section) {
    final sectionData = checklistData[section];
    final isExpanded = expandedSections[section] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: sectionData['completed'],
            onChanged: (bool? newValue) async {
              if (newValue != null) {
                setState(() {
                  checklistData[section]['completed'] = newValue;
                });
                await updateChecklistStatus(sectionData['taskid'], newValue);
              }
            },
          ),
          title: Text(
            section,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                expandedSections[section] = !isExpanded;
              });
            },
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 32.0, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(sectionData['descriptions'] as List<String>).map((desc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text("• $desc", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }
}







