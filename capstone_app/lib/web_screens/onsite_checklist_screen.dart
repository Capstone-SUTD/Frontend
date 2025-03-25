import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'msra_generation_screen.dart';
import '../web_common/project_tab_widget.dart';
import '../web_common/project_stepper_widget.dart';
import '../web_common/attachment_popup.dart';
import '../web_common/comment_popup.dart';
import '../web_common/step_label.dart';

/// ---------------------------------------------------------------------------
///  A small data class to hold both the file bytes and the name
/// ---------------------------------------------------------------------------
class PickedFileData {
  final Uint8List bytes;
  final String fileName;
  PickedFileData(this.bytes, this.fileName);
}

/// ---------------------------------------------------------------------------
///  AttachmentPopup: lets user pick a file (mainly a picture) and confirm
/// ---------------------------------------------------------------------------
class AttachmentPopup extends StatefulWidget {
  /// This callback returns the chosen file data (bytes, name) to the caller
  final ValueChanged<PickedFileData> onAttach;

  const AttachmentPopup({Key? key, required this.onAttach}) : super(key: key);

  @override
  State<AttachmentPopup> createState() => _AttachmentPopupState();
}

class _AttachmentPopupState extends State<AttachmentPopup> {
  Uint8List? _pickedBytes;
  String _pickedFileName = '';

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, // restrict to images if needed
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        // For web or desktop, we’ll get bytes:
        _pickedBytes = result.files.single.bytes;
        // For mobile, we also typically get a path: result.files.single.path
        // but we can stick to bytes for cross-platform usage
        _pickedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Attach a File"),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Pick an Image"),
            ),
            const SizedBox(height: 8),
            if (_pickedFileName.isNotEmpty)
              Text("Picked File: $_pickedFileName", style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Attach"),
          onPressed: () {
            if (_pickedBytes != null && _pickedFileName.isNotEmpty) {
              // Send the file info back to the parent
              widget.onAttach(PickedFileData(_pickedBytes!, _pickedFileName));
              // The parent can pop this dialog
            } else {
              // If user hasn't picked anything, just close
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
///  CommentPopup: add or edit a comment
/// ---------------------------------------------------------------------------
class CommentPopup extends StatefulWidget {
  final String initialComment;
  final ValueChanged<String> onCommentAdded;

  const CommentPopup({
    Key? key,
    required this.initialComment,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add/Edit Comment"),
      content: TextField(
        controller: _controller,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: "Type your comment here...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCommentAdded(_controller.text.trim());
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
///  OnsiteChecklistScreen - the main screen
/// ---------------------------------------------------------------------------
class OnsiteChecklistScreen extends StatefulWidget {
  final dynamic project;

  const OnsiteChecklistScreen({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  _OnsiteChecklistScreenState createState() => _OnsiteChecklistScreenState();
}

class _OnsiteChecklistScreenState extends State<OnsiteChecklistScreen> {
  late dynamic _project;

  Map<String, bool> expandedSections = {};
  Map<String, dynamic> checklistData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  /// 1) Fetch your entire onsite checklist
  Future<void> fetchChecklistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
          "http://localhost:5000/project/get-project-checklist?projectid=${_project.projectId}"
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Example: Process "OnSiteFixed" for "General" section
        if (jsonData.containsKey("OnSiteFixed")) {
          final general = jsonData["OnSiteFixed"] as Map<String, dynamic>;
          checklistData["General"] = _parseChecklistGroup(general);
        }

        // Example: other sections
        for (String section in ["Lifting", "Forklift", "Transportation"]) {
          if (jsonData.containsKey(section)) {
            final data = jsonData[section] as Map<String, dynamic>;
            checklistData[section] = _parseChecklistGroup(data);
          }
        }

        // Start each section collapsed
        for (var key in checklistData.keys) {
          expandedSections[key] = false;
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print("❌ Failed to load onsite checklist");
      }
    } catch (e) {
      print("❌ Exception in fetching onsite checklist: $e");
    }
  }

  /// Converts the server JSON into a local map
  Map<String, Map<String, dynamic>> _parseChecklistGroup(Map<String, dynamic> group) {
    final result = <String, Map<String, dynamic>>{};
    group.forEach((subtype, content) {
      if (content is Map<String, dynamic>) {
        int? taskId = content['taskid'];
        bool completed = content['completed'] ?? false;
        String comments = content['comments'] ?? '';

        bool hasAttachment = false;
        // If the server includes an 'attachments' field:
        if (content.containsKey('attachments')) {
          final attachVal = content['attachments'];
          if (attachVal != null && attachVal.toString().isNotEmpty) {
            hasAttachment = true;
          }
        }

        // Parse out any descriptions that are leftover
        List<String> descriptions = [];
        content.forEach((key, value) {
          if (key != 'taskid' && 
              key != 'completed' && 
              key != 'comments' && 
              key != 'attachments') {
            if (value is String) {
              descriptions.add(value);
            } else if (value is List) {
              descriptions.addAll(value.map((v) => v.toString()));
            } else if (value is Map) {
              descriptions.addAll(value.values.map((v) => v.toString()));
            }
          }
        });

        result[subtype] = {
          'taskid': taskId,
          'completed': completed,
          'comments': comments,
          'hasAttachment': hasAttachment,
          'descriptions': descriptions,
          'expanded': false,
        };
      }
    });
    return result;
  }

  /// 2) Update the "completed" status of a subtask
  Future<void> updateChecklistStatus(int taskid, bool completed) async {
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

      if (response.statusCode == 200) {
        print("✅ Updated task $taskid => $completed");
      } else {
        print("❌ Failed to update task $taskid");
      }
    } catch (e) {
      print("❌ Error updating checklist task: $e");
    }
  }

  /// 3) Update/Add comments to a subtask
  Future<void> updateTaskComments(int taskid, String comments) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse("http://localhost:5000/project/update-task-comments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'taskid': taskid, 'comments': comments}),
      );

      if (response.statusCode == 200) {
        print("✅ Successfully updated comments for task $taskid");
      } else {
        print("❌ Failed to update comments for task $taskid");
      }
    } catch (e) {
      print("❌ Error updating task comments: $e");
    }
  }

  /// 4) Upload an attachment from bytes
  Future<bool> uploadAttachment(int taskid, Uint8List fileBytes, String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final uri = Uri.parse("http://localhost:5000/project/upload-blob-azure");
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['taskid'] = taskid.toString();

      // Attach the file as bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',        // the field name expected by your API
          fileBytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        print("✅ Uploaded attachment for task $taskid");
        return true;
      } else {
        print("❌ Failed to upload attachment for task $taskid");
        return false;
      }
    } catch (e) {
      print("❌ Error uploading attachment: $e");
      return false;
    }
  }

  /// 5) Get a signed URL for the attachment
  Future<String?> fetchAttachmentUrl(int taskid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse("http://localhost:5000/project/get-blob-url?taskid=$taskid"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // If response.body is a plain string, just return it directly:
        final url = jsonDecode(response.body);
        // If url is a String, return it; otherwise, if it's wrapped in an object, extract it:
        if (url is String) {
          return url;
        } else if (url is Map && url.containsKey('signedUrl')) {
          return url['signedUrl'] as String?;
        }
        return null;
      } else {
        print("❌ Failed to get blob URL for task $taskid");
        return null;
      }
    } catch (e) {
      print("❌ Exception fetching attachment URL: $e");
      return null;
    }
  }

  // Example of switching tabs, if your app uses them
  void _onTabSelected(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MSRAGenerationScreen(project: _project)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Onsite Checklist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProjectTabWidget(
              selectedTabIndex: 2,
              onTabSelected: _onTabSelected
            ),
            const SizedBox(height: 20),
            ProjectStepperWidget(
              currentStage: _project.stage,
              projectId: _project.projectId,
              onStepTapped: (newIndex) {
                // optional
              },
              onStageUpdated: (newStage) {
                setState(() {
                  _project.stage = newStage; // direct local update
                });
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Onsite Checklist",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView(
                      children: checklistData.entries.map((entry) {
                        final sectionTitle = entry.key;
                        final subtypes = entry.value as Map<String, Map<String, dynamic>>;
                        return _buildChecklistSection(sectionTitle, subtypes);
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection(
    String section,
    Map<String, Map<String, dynamic>> subtypes,
  ) {
    return ExpansionTile(
      title: Text(section, style: const TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: expandedSections[section] ?? false,
      onExpansionChanged: (value) {
        setState(() {
          expandedSections[section] = value;
        });
      },
      children: subtypes.entries.map((subEntry) {
        final subtype = subEntry.key;
        final data = subEntry.value;

        final bool hasComment =
            data['comments'] != null && data['comments'].trim().isNotEmpty;
        final bool hasAttachment = data['hasAttachment'] == true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) "completed" checkbox
            CheckboxListTile(
              title: Text(subtype),
              value: data['completed'],
              onChanged: (checked) {
                setState(() {
                  data['completed'] = checked!;
                });
                updateChecklistStatus(data['taskid'], checked!);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // 2) Subtype descriptions
            if (data['expanded'] == true || true)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (data['descriptions'] as List<String>).map((desc) {
                    return Text("• $desc", style: const TextStyle(fontSize: 13));
                  }).toList(),
                ),
              ),

            // 3) Row of comment + attachment buttons
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  // A) Add/Edit Comment
                  ElevatedButton(
                    onPressed: () async {
                      final initialComment = data['comments'] ?? '';
                      final newComment = await showDialog<String>(
                        context: context,
                        builder: (context) => CommentPopup(
                          initialComment: initialComment,
                          onCommentAdded: (text) => Navigator.pop(context, text),
                        ),
                      );
                      if (newComment != null) {
                        // Update server
                        await updateTaskComments(data['taskid'], newComment);
                        // Update local
                        setState(() {
                          data['comments'] = newComment;
                        });
                      }
                    },
                    child: Text(hasComment ? "Edit Comment" : "Add Comment"),
                  ),

                  // B) View Comment (only if we have one)
                  if (hasComment)
                    OutlinedButton(
                      onPressed: () {
                        final latest = data['comments'];
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Comment for $subtype"),
                            content: SingleChildScrollView(
                              child: Text(latest),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("View Comment"),
                    ),

                  // C) Add/Edit Attachment
                  ElevatedButton(
                    onPressed: () async {
                      final pickedData = await showDialog<PickedFileData>(
                        context: context,
                        builder: (context) => AttachmentPopup(
                          onAttach: (fileData) => Navigator.pop(context, fileData),
                        ),
                      );
                      // If user actually picked a file
                      if (pickedData != null) {
                        final success = await uploadAttachment(
                          data['taskid'],
                          pickedData.bytes,
                          pickedData.fileName,
                        );
                        if (success) {
                          setState(() {
                            data['hasAttachment'] = true;
                          });
                        }
                      }
                    },
                    child: Text(hasAttachment ? "Edit Attachment" : "Add Attachment"),
                  ),

                  // D) View Attachment (only if hasAttachment)
                  if (hasAttachment)
                    OutlinedButton(
                      onPressed: () async {
                        final signedUrl = await fetchAttachmentUrl(data['taskid']);
                        if (signedUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No attachment found or error retrieving."),
                            ),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Attachment for $subtype"),
                            content: SizedBox(
                              width: 400,
                              height: 400,
                              child: Image.network(signedUrl, fit: BoxFit.contain),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("View Attachment"),
                    ),
                ],
              ),
            ),

            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}







