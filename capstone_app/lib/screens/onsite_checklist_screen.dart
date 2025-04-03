import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/project_stepper_widget.dart';
import '../common/project_tab_widget.dart';
import 'msra_generation_screen.dart';
import 'project_screen.dart';

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
              Text("Picked File: $_pickedFileName",
                  style: const TextStyle(fontSize: 13)),
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
///  CommentPopup: simple text field for add comment
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
  bool isSaveEnabled = false;
  String? validationMessage;
  final int maxChars = 200;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment);
    isSaveEnabled = widget.initialComment.trim().isNotEmpty;

    _controller.addListener(() {
      setState(() {
        isSaveEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Comments"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: maxChars,
            onChanged: (value) {
              setState(() {
                isSaveEnabled = value.trim().isNotEmpty;
                if (validationMessage != null && isSaveEnabled) {
                  validationMessage = null;
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Type your comment here...",
              border: const OutlineInputBorder(),
              counterText: "${_controller.text.trim().length} / $maxChars",
            ),
          ),
          if (validationMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                validationMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSaveEnabled
              ? () {
                  if (_controller.text.trim().isEmpty) {
                    setState(() {
                      validationMessage = "Comment cannot be empty";
                    });
                  } else {
                    widget.onCommentAdded(_controller.text.trim());
                  }
                }
              : null,
          child: const Text("Save"),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
///  View CommentPopup: display the entire conversation
/// ---------------------------------------------------------------------------
class CommentsConversationPopup extends StatefulWidget {
  final int taskid;
  final String taskName;
  final int projectid;

  const CommentsConversationPopup({
    Key? key,
    required this.taskid,
    required this.taskName,
    required this.projectid,
  }) : super(key: key);

  @override
  _CommentsConversationPopupState createState() =>
      _CommentsConversationPopupState();
}

class _CommentsConversationPopupState extends State<CommentsConversationPopup> {
  bool isLoading = true;
  List<dynamic> comments = [];
  Map<int, bool> isEditing = {}; // track editing state
  Map<int, TextEditingController> controllers =
      {}; // one controller per comment

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<List<dynamic>> getTaskComments(int taskid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        // ✅ Use GET instead of POST for reading
        Uri.parse(
            "http://localhost:5000/project/get-task-comments?taskid=${taskid.toString()}"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Successfully fetched comments for task $taskid");

        final decoded = json.decode(response.body);

        // Ensure the data is a List of Maps and convert any string keys if needed
        if (decoded is List) {
          return decoded.map((comment) {
            return {
              'commentid': int.tryParse(comment['commentid'].toString()) ?? 0,
              'comments': comment['comments'] ?? '',
              'username': comment['username'] ?? '',
            };
          }).toList();
        } else {
          print("❌ Unexpected response format: $decoded");
          return [];
        }
      } else {
        print("❌ Failed to fetch comments. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exception fetching task comments: $e");
      return [];
    }
  }

  Future<void> updateTaskComment(int commentid, String newComment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse("http://localhost:5000/project/update-task-comments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'commentid': commentid,
          'comments': newComment,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Comment updated successfully");
      } else {
        print("❌ Error updating comment: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception updating comment: $e");
    }
  }

  /// Delete a specific comment
  Future<void> deleteTaskComment(int commentid, int taskid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse(
            "http://localhost:5000/project/delete-task-comment?commentid=$commentid&taskid=$taskid"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Comment deleted successfully");
      } else {
        print("❌ Error deleting comment: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception deleting comment: $e");
    }
  }

  Future<void> loadComments() async {
    setState(() => isLoading = true);
    final fetched = await getTaskComments(widget.taskid);
    setState(() {
      comments = fetched;
      isLoading = false;
      isEditing.clear();
      controllers.clear();
      for (var c in comments) {
        final id = c['commentid'];
        isEditing[id] = false;
        controllers[id] = TextEditingController(text: c['comments']);
      }
    });
  }

  Future<void> handleUpdate(int commentid) async {
    final text = controllers[commentid]?.text.trim() ?? "";
    if (text.isNotEmpty) {
      await updateTaskComment(commentid, text);
      await loadComments();
    }
  }

  Future<void> handleDelete(int commentid) async {
    await deleteTaskComment(commentid, widget.taskid);
    await loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Comments for ${widget.taskName}"),
      content: SizedBox(
        width: 600,
        height: 400,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final commentid = comment['commentid'];
                  final username = comment['username'] ?? 'Unknown';
                  final editing = isEditing[commentid] ?? false;
                  final controller = controllers[commentid]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            editing
                                ? TextField(
                                    controller: controller,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                    ),
                                  )
                                : Text(
                                    comment['comments'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon:
                                      Icon(editing ? Icons.check : Icons.edit),
                                  tooltip: editing ? 'Save' : 'Edit',
                                  onPressed: () {
                                    if (editing) {
                                      handleUpdate(commentid);
                                    } else {
                                      setState(
                                          () => isEditing[commentid] = true);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete',
                                  onPressed: () => handleDelete(commentid),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// ---------------------------------------------------------------------------
///  OnsiteChecklistScreen - the main screen
/// ---------------------------------------------------------------------------
class OnsiteChecklistScreen extends StatefulWidget {
  final dynamic project;
  const OnsiteChecklistScreen({Key? key, required this.project})
      : super(key: key);

  @override
  _OnsiteChecklistScreenState createState() => _OnsiteChecklistScreenState();
}

class _OnsiteChecklistScreenState extends State<OnsiteChecklistScreen> {
  late dynamic _project;
  late int _currentStep;

  Map<String, bool> expandedSections = {};
  Map<String, dynamic> checklistData = {};
  bool isLoading = true;

  // Adapt to your actual step labels, or remove if not used
  final List<String> stepLabels = [
    'seller',
    'customs',
    'loading',
    'carrier',
    'cargo terminal',
    'port',
    'transport',
    'port2',
    'cargo terminal2',
    'carrier2',
    'customs2',
    'unloading',
    'buyer'
  ];

  @override
  void initState() {
    super.initState();
    _project = widget.project;

    final stage = _project?.stage?.toString().toLowerCase();
    _currentStep = stage != null && stepLabels.contains(stage)
        ? stepLabels.indexOf(stage)
        : 0;

    fetchChecklistData();
  }

  /// 1) Fetch your entire onsite checklist
  Future<void> fetchChecklistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
            "http://localhost:5000/project/get-project-checklist?projectid=${_project.projectId}"),
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
  Map<String, Map<String, dynamic>> _parseChecklistGroup(
      Map<String, dynamic> group) {
    final result = <String, Map<String, dynamic>>{};
    group.forEach((subtype, content) {
      if (content is Map<String, dynamic>) {
        int? taskId = content['taskid'];
        bool completed = content['completed'] ?? false;
        bool hasComments = content['has_comments'] ?? false;
        bool hasAttachment = content['has_attachment'] ?? false;
        //String comments = content['comments'] ?? '';

        // If the server includes an 'attachments' field:
        // if (content.containsKey('attachments')) {
        // final attachVal = content['attachments'];
        // if (attachVal != null && attachVal.toString().isNotEmpty) {
        //   hasAttachment = true;
        // }
        // }

        // Parse out any descriptions that are leftover
        List<String> descriptions = [];
        content.forEach((key, value) {
          if (key != 'taskid' &&
              key != 'completed' &&
              key != 'has_comments' &&
              key != 'has_attachments') {
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
          'has_comments': hasComments,
          'has_attachment': hasAttachment,
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

  /// Add a new comment
  Future<void> addTaskComment(int taskid, String comment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final projectid = _project.projectId; // from your project object

      final response = await http.post(
        Uri.parse("http://localhost:5000/project/add-task-comments"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'taskid': taskid,
          'comments': comment,
          'projectid': projectid,
        }),
      );
      if (response.statusCode == 200) {
        print("✅ Comment added successfully");
      } else {
        print("❌ Error adding comment: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception adding comment: $e");
    }
  }

  /// 4) Upload an attachment from bytes
  Future<bool> uploadAttachment(
      int taskid, Uint8List fileBytes, String fileName) async {
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
          'image', // the field name expected by your API
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
  Future<Uint8List?> fetchAttachmentImageBytes(int taskid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // First, fetch the signed URL.
      final response = await http.get(
        Uri.parse("http://localhost:5000/project/get-blob-url?taskid=$taskid"),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Request Headers: ${response.request?.headers}");
      print("Status Code: ${response.statusCode}");
      print("Headers: ${response.headers}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        String? signedUrl;

        // Handle case A: plain string
        if (raw is String) {
          signedUrl = raw;
        }
        // Handle case B: JSON object with a key
        else if (raw is Map && raw['signedUrl'] is String) {
          signedUrl = raw['signedUrl'] as String;
        } else {
          print("❌ Unexpected format for signed URL: $raw");
          return null;
        }

        // Step 2: Fetch the actual image using the signed URL
        final imageResponse = await http.get(Uri.parse(signedUrl));
        if (imageResponse.statusCode == 200) {
          return imageResponse.bodyBytes;
        } else {
          print(
              "❌ Failed to load image from signed URL. Status: ${imageResponse.statusCode}");
          print("Headers: ${imageResponse.headers}");
          print("Body: ${imageResponse.body}");
          return null;
        }

        // Now fetch the image bytes from the signed URL.
        // final imageResponse = await http.get(Uri.parse(signedUrl));
        // if (imageResponse.statusCode == 200) {
        //   return imageResponse.bodyBytes;
        // } else {
        //   throw Exception('Failed to load image from signedUrl');
        // }
      } else {
        print(
            "❌ Failed to get blob URL for task $taskid. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception fetching attachment image bytes: $e");
      return null;
    }
  }

  // Example of switching tabs, if your app uses them
  void _onTabSelected(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectScreen(
            projectId: _project?.projectId,
            selectedTab: 0,
          ),
        ),
      );
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MSRAGenerationScreen(project: _project),
        ),
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
              onTabSelected: _onTabSelected,
            ),
            const SizedBox(height: 20),
            ProjectStepperWidget(
              currentStage: _project.stage,
              projectId: _project.projectId,
              onStepTapped: (_) {},
            ),
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
                        final subtypes =
                            entry.value as Map<String, Map<String, dynamic>>;
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

        final bool hasComment = data['has_comments'] == true;
        final bool hasAttachment = data['has_attachment'] == true;

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
                    return Text("• $desc",
                        style: const TextStyle(fontSize: 13));
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
                      final newComment = await showDialog<String>(
                        context: context,
                        builder: (context) => CommentPopup(
                          initialComment: "",
                          onCommentAdded: (text) =>
                              Navigator.pop(context, text),
                        ),
                      );
                      if (newComment != null && newComment.isNotEmpty) {
                        // Update server
                        await addTaskComment(data['taskid'], newComment);
                        // Update local
                        setState(() {
                          data['has_comments'] = true;
                        });
                      }
                    },
                    child: const Text("Add Comment"),
                  ),

                  // B) View Comment (only if we have one)
                  if (hasComment)
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => CommentsConversationPopup(
                            taskid: data['taskid'],
                            taskName: subtype,
                            projectid:
                                int.tryParse(_project.projectId.toString()) ??
                                    0,
                          ),
                        );
                      },
                      child: const Text("View Comments"),
                    ),

                  // C) Add/Edit Attachment
                  ElevatedButton(
                    onPressed: () async {
                      final pickedData = await showDialog<PickedFileData>(
                        context: context,
                        builder: (context) => AttachmentPopup(
                          onAttach: (fileData) =>
                              Navigator.pop(context, fileData),
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
                            data['has_attachment'] = true;
                          });
                        }
                      }
                    },
                    child: Text(
                        hasAttachment ? "Edit Attachment" : "Add Attachment"),
                  ),

                  // D) View Attachment (only if hasAttachment)
                  if (hasAttachment)
                    OutlinedButton(
                      onPressed: () async {
                        final imageBytes =
                            await fetchAttachmentImageBytes(data['taskid']);
                        print("image $imageBytes");
                        if (imageBytes == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "No attachment found or error retrieving."),
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
                              child: Image.memory(imageBytes),
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
