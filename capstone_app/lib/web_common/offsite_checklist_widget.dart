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

  Map<String, Map<String, dynamic>> checklistStatus = {
    "Administrative": {},
    "Safety Precautions": {},
  };

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
        Uri.parse("http://localhost:5000/project/get-project-checklist?projectid=${widget.projectId}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final offsite = jsonData['OffSiteFixed'];

        // Extract subtypes and completion status
        final Map<String, dynamic> admin = offsite['Administrative'];
        final Map<String, dynamic> safety = offsite['Safety precautions'];

        setState(() {
          checklistStatus['Administrative'] = {
            'taskid': admin['taskid'],
            'completed': admin['completed'],
          };
          checklistStatus['Safety Precautions'] = {
            'taskid': safety['taskid'],
            'completed': safety['completed'],
          };
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load checklist");
      }
    } catch (e) {
      print("Error fetching checklist: $e");
    }
  }

  Future<void> updateChecklistStatus(String section) async {
    try {
      final taskid = checklistStatus[section]?['taskid'];
      if (taskid == null) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse("http://localhost:5000/project/update-checklist-completion"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskid': taskid}),
      );

      if (response.statusCode == 200) {
        setState(() {
          checklistStatus[section]!['completed'] = !checklistStatus[section]!['completed'];
        });
      } else {
        print("Failed to update checklist status for $section");
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
    final isChecked = checklistStatus[section]?['completed'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: isChecked,
            onChanged: (_) => updateChecklistStatus(section),
          ),
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
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "(Checklist details can go here)",
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }
}






