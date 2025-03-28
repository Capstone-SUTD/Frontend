import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OnsiteChecklistScreen extends StatefulWidget {
  final dynamic project;
  const OnsiteChecklistScreen({Key? key, required this.project}) : super(key: key);

  @override
  _OnsiteChecklistScreenState createState() => _OnsiteChecklistScreenState();
}

class _OnsiteChecklistScreenState extends State<OnsiteChecklistScreen> {
  late dynamic _project;
  Map<String, bool> expandedSections = {};
  Map<String, dynamic> checklistData = {};
  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    fetchChecklistData();
  }

  Future<void> fetchChecklistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
          "http://10.0.2.2:3000/project/get-project-checklist?projectid=${_project.projectId}"
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData.containsKey("OnSiteFixed")) {
          final general = jsonData["OnSiteFixed"] as Map<String, dynamic>;
          checklistData["General"] = _parseChecklistGroup(general);
        }

        for (String section in ["Lifting", "Forklift", "Transportation"]) {
          if (jsonData.containsKey(section)) {
            final data = jsonData[section] as Map<String, dynamic>;
            checklistData[section] = _parseChecklistGroup(data);
          }
        }

        for (var key in checklistData.keys) {
          expandedSections[key] = false;
        }

        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading checklist: $e")),
      );
    }
  }

  Map<String, Map<String, dynamic>> _parseChecklistGroup(Map<String, dynamic> group) {
    final result = <String, Map<String, dynamic>>{};
    group.forEach((subtype, content) {
      if (content is Map<String, dynamic>) {
        result[subtype] = {
          'taskid': content['taskid'],
          'completed': content['completed'] ?? false,
          'comments': content['comments'] ?? '',
          'hasAttachment': content['attachments']?.toString().isNotEmpty ?? false,
          'descriptions': _extractDescriptions(content),
          'expanded': false,
        };
      }
    });
    return result;
  }

  List<String> _extractDescriptions(Map<String, dynamic> content) {
    final descriptions = <String>[];
    content.forEach((key, value) {
      if (!['taskid', 'completed', 'comments', 'attachments'].contains(key)) {
        if (value is String) descriptions.add(value);
        else if (value is List) descriptions.addAll(value.map((v) => v.toString()));
        else if (value is Map) descriptions.addAll(value.values.map((v) => v.toString()));
      }
    });
    return descriptions;
  }

  Future<void> _updateChecklistStatus(int taskid, bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      await http.post(
        Uri.parse("http://10.0.2.2:3000/project/update-checklist-completion"),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'taskid': taskid, 'completed': completed}),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e")),
      );
    }
  }

  Future<void> _updateTaskComments(int taskid, String comments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      await http.post(
        Uri.parse("http://10.0.2.2:3000/project/update-task-comments"),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'taskid': taskid, 'comments': comments}),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update comments: $e")),
      );
    }
  }

  Future<bool> _uploadAttachment(int taskid, Uint8List fileBytes, String fileName) async {
    setState(() => isUploading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://10.0.2.2:3000/project/upload-blob-azure"),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['taskid'] = taskid.toString();
      request.files.add(http.MultipartFile.fromBytes(
        'image', fileBytes, filename: fileName));

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<Uint8List?> _fetchAttachment(int taskid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/project/get-blob-url?taskid=$taskid"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        final String? signedUrl = raw is String ? raw : raw['signedUrl'];
        if (signedUrl == null) return null;

        final imageResponse = await http.get(Uri.parse(signedUrl));
        return imageResponse.statusCode == 200 ? imageResponse.bodyBytes : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Onsite Checklist"),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...checklistData.entries.map((entry) => _buildSection(entry.key, entry.value)),
                  if (isUploading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String section, Map<String, dynamic> subtypes) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(section, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: expandedSections[section] ?? false,
        onExpansionChanged: (expanded) => setState(() => expandedSections[section] = expanded),
        children: subtypes.entries.map((entry) => _buildSubtype(entry.key, entry.value)).toList(),
      ),
    );
  }

  Widget _buildSubtype(String subtype, Map<String, dynamic> data) {
    final hasComment = data['comments']?.trim().isNotEmpty ?? false;
    final hasAttachment = data['hasAttachment'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(subtype),
            value: data['completed'],
            onChanged: (value) {
              setState(() => data['completed'] = value);
              _updateChecklistStatus(data['taskid'], value!);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          
          if (data['expanded'] || true)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...(data['descriptions'] as List<String>).map((desc) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text("• $desc", style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionButton(
                        icon: Icons.comment,
                        label: hasComment ? "Edit Comment" : "Add Comment",
                        onPressed: () => _handleCommentAction(data),
                      ),
                      if (hasComment)
                        _buildActionButton(
                          icon: Icons.visibility,
                          label: "View Comment",
                          onPressed: () => _showCommentDialog(subtype, data['comments']),
                        ),
                      _buildActionButton(
                        icon: Icons.attach_file,
                        label: hasAttachment ? "Change Photo" : "Add Photo",
                        onPressed: () => _handleAttachmentAction(data),
                      ),
                      if (hasAttachment)
                        _buildActionButton(
                          icon: Icons.photo,
                          label: "View Photo",
                          onPressed: () => _showAttachmentDialog(data['taskid']),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }

  Future<void> _handleCommentAction(Map<String, dynamic> data) async {
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add/Edit Comment"),
        content: TextField(
          controller: TextEditingController(text: data['comments']),
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Enter your comment...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, data['comments']),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (comment != null) {
      setState(() => data['comments'] = comment);
      await _updateTaskComments(data['taskid'], comment);
    }
  }

  Future<void> _showCommentDialog(String title, String comment) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Comment for $title"),
        content: SingleChildScrollView(child: Text(comment)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAttachmentAction(Map<String, dynamic> data) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        final success = await _uploadAttachment(data['taskid'], file.bytes!, file.name);
        if (success) {
          setState(() => data['hasAttachment'] = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Attachment uploaded successfully")),
          );
        }
      }
    }
  }

  Future<void> _showAttachmentDialog(int taskid) async {
    final imageBytes = await _fetchAttachment(taskid);
    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not load attachment")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}