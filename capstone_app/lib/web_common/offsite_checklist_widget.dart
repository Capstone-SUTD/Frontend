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
  Map<String, bool> expandedSections = {
    "Administrative": false,
    "Safety Precautions": false,
  };

  Map<String, List<Map<String, dynamic>>> checklistData = {
    "Administrative": [],
    "Safety Precautions": [],
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChecklistData();
  }

  Future<void> fetchChecklistData() async {
    print("🟢 Sending GET request with projectid=${widget.projectId}");
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse("http://localhost:5000/project/get-project-checklist?projectid=${widget.projectId}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final offsite = jsonData['OffSiteFixed'];

        // Flatten administrative
        final admin = offsite['Administrative'] as Map<String, dynamic>;
        admin.remove('completed');
        admin.remove('comments');
        checklistData['Administrative'] = admin.entries.map((entry) {
          return {
            'taskid': entry.key,
            'label': entry.value,
            'completed': false,
          };
        }).toList();

        // Flatten safety precaution Equipment + Route Survey
        final safety = offsite['Safety precautions'];
        final equipment = (safety['Equipment'] as List<dynamic>);
        final routeSurvey = (safety['Route survey'] as List<dynamic>);

        int taskIdCounter = 1000;
        final allSafety = [...equipment, ...routeSurvey];
        checklistData['Safety Precautions'] = allSafety.map((item) {
          return {
            'taskid': (taskIdCounter++).toString(),
            'label': item,
            'completed': false,
          };
        }).toList();

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

  Future<void> updateChecklistStatus(String taskid, bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse("http://localhost:5000/project/update-checklist-completion"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskid': taskid, 'completed': completed}),
      );

      if (response.statusCode != 200) {
        print("Failed to update checklist task $taskid");
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
            ? const Center(child: CircularProgressIndicator())
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
                        children: expandedSections.keys.map((section) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            section,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: Icon(
              expandedSections[section]! ? Icons.expand_less : Icons.expand_more,
            ),
            onPressed: () {
              setState(() {
                expandedSections[section] = !expandedSections[section]!;
              });
            },
          ),
        ),
        if (expandedSections[section]!)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              children: checklistData[section]!.map((item) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: item['completed'],
                  onChanged: (bool? newValue) {
                    setState(() {
                      item['completed'] = newValue!;
                    });
                    updateChecklistStatus(item['taskid'], newValue!);
                  },
                  title: Text(item['label'], style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}





