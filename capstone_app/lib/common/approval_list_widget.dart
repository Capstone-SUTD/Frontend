import 'package:flutter/material.dart';
import 'msra_reupload_widget.dart';
import '../models/project_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class ApprovalListWidget extends StatefulWidget {
  int selectedTab;
  int approvalStage;
  final List<Stakeholder> stakeholders;
  final int projectid;
  final List<Map<String, dynamic>> rejectionList;
  final Function(int) onApprovalStageChange;
  final Function(String) onVersionIncrease;
  final Function(String) onStageUpdated;

  ApprovalListWidget({
    super.key,
    required this.selectedTab,
    required this.approvalStage,
    required this.stakeholders,
    required this.projectid,
    required this.rejectionList, // Initialize rejectionList prop
    required this.onApprovalStageChange,
    required this.onVersionIncrease,
    required this.onStageUpdated,
  });

  @override
  _ApprovalListWidgetState createState() => _ApprovalListWidgetState();
}

class _ApprovalListWidgetState extends State<ApprovalListWidget> {
  late List<Map<String, dynamic>> _pendingApprovals;
  final GlobalKey<FileReUploadWidgetState> _fileUploadKey = GlobalKey<FileReUploadWidgetState>();

  @override
  void initState() {
    super.initState();
    _initializePendingApprovals();
  }

  void _updateStage(String newStage) {
      print("2, Stage Updated: $newStage");
      widget.onStageUpdated(newStage); // Update the project stage
  }

  void _initializePendingApprovals() {
    List<String> validRoles = ["HSEOfficer", "ProjectManager", "Head"];

    _pendingApprovals = widget.stakeholders
        .where((stakeholder) => validRoles.contains(stakeholder.role))
        .map((stakeholder) => {
              "name": stakeholder.name,
              "role": stakeholder.role,
              "approved": false,
              "rejected": false,
            })
        .toList();
  }

  Future<void> _approveProject(int projectId) async {
    final url = Uri.parse('http://localhost:5000/app/approve');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "projectid": projectId,
        }),
      );

      if (response.statusCode == 200) {
        widget.onApprovalStageChange(widget.approvalStage + 1);
        print("Approval Stage ${widget.approvalStage}");
        if(widget.approvalStage == 0){
          _updateStage("Approved - HSE");
          print("1, Stage Updated: Approved HSE");
        }
        if(widget.approvalStage == 1){
          _updateStage("Approved - PM");
          print("1, Stage Updated: Approved PM");
        }
        if(widget.approvalStage == 2){
          _updateStage("Approved - Mr. Jeong");
          print("1, Stage Updated: Approved Mr. Jeong");
        }
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approved succesfully')),);
      } else {
        var responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Unknown error';
        _showErrorSnackbar("Failed. ($errorMessage)");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  Widget _buildApprovalCard(int index, Map<String, dynamic> approval) {
    bool isEnabled = false;
    bool isApprovedOrRejected = approval["approved"] || approval["rejected"];

    // If selectedTab is 0, show approvals starting from approvalStage
    // If selectedTab is 1, show approvals before approvalStage
    if (widget.selectedTab == 0) {
      if (index < widget.approvalStage) {
        return SizedBox(); // Skip the item if it's before approvalStage
      }
    } else if (widget.selectedTab == 1) {
      if (index >= widget.approvalStage) {
        return SizedBox(); // Skip the item if it's after approvalStage
      }
    }

    // Determine which button to show based on the approvalStage
    if (widget.selectedTab == 0) {
      // Enable the button only if the stage matches the approval stage
      if (widget.approvalStage == 0 && approval["role"] == "HSEOfficer") {
        isEnabled = true;
        
      } else if (widget.approvalStage == 1 && approval["role"] == "ProjectManager") {
        isEnabled = true;
      } else if (widget.approvalStage == 2 && approval["role"] == "Head") {
        isEnabled = true;
      }
    }

    const roleMapping = {
      "HSEOfficer": "HSE Officer",
      "ProjectManager": "Project Manager",
      "Head": "GPIS Head",
    };

    // For selectedTab == 1, display a disabled "Approved" button
    return Card(
      child: ListTile(
        title: Text("MSRA Approval by ${roleMapping[approval["role"]]}"),
        subtitle: Text("Action by ${approval["name"]}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // For selectedTab == 0, show approve and reject buttons
            if (widget.selectedTab == 0) ...[
              ElevatedButton(
                onPressed: isEnabled && !isApprovedOrRejected
                    ? () => _approveProject(widget.projectid)
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Approve"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isEnabled && !isApprovedOrRejected
                    ? () => _showRejectionDialog(approval)
                    : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Reject"),
              ),
            ],
            // For selectedTab == 1, show the "Approved" button that does nothing when clicked
            if (widget.selectedTab == 1) ...[
              ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Approved"),
              )
            ],
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showRejectionDialog(Map<String, dynamic> approval) {
    final TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Rejection Reason"),
          content: TextField(
            controller: _reasonController,
            decoration: const InputDecoration(hintText: "Enter your rejection reason here"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String comments = _reasonController.text;

                // Call API to reject the project
                _rejectProject(approval, comments);

                Navigator.of(context).pop();
              },
              child: const Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectProject(Map<String, dynamic> approval, String comments) async {
    final url = Uri.parse('http://localhost:5000/app/reject');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "projectid": widget.projectid,
          "comments": comments,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (_pendingApprovals.isNotEmpty) {
          var firstPendingApproval = _pendingApprovals[widget.approvalStage];
          var newRejection = {
            "role": firstPendingApproval["role"],
            "name": firstPendingApproval["name"],
            "comments": comments,
          };
          widget.rejectionList.add(newRejection);
          widget.selectedTab = 2;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rejected succesfully')),
          );
        }});
      } else {
        var responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Unknown error';
        _showErrorSnackbar("Failed to reject. ($errorMessage)");
      }
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
    }
  }

  void uploadFile() async {
    final projectId = widget.projectid;
    String filetype = "";
    final uploadedFiles = _fileUploadKey.currentState?.getUploadedFiles() ?? [];

    html.File? file;
    for (final uploadedFile in uploadedFiles) {
      final extension = uploadedFile.name.split('.').last.toLowerCase(); 

      if (extension == 'xlsx') {
        filetype = "RA";
        file = uploadedFile;
      } else if (extension == 'docx') {
        filetype = "MS";
        file = uploadedFile;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Missing token");

      final formData = html.FormData();
      
      // Append the files only if they exist
      if (file != null) {
        formData.appendBlob('file', file, file.name);
      } 

      formData.append('projectid', projectId.toString());
      formData.append('filetype', filetype);

      final request = html.HttpRequest();
      request
        ..open('POST', 'http://localhost:5000/app/reupload')
        ..setRequestHeader('Authorization', 'Bearer $token')
        ..onLoadEnd.listen((event) async {
          if (request.status == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("File uploaded successfully.")),
            );
            if (filetype.isNotEmpty) {
              widget.onVersionIncrease(filetype);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${request.status} - ${request.responseText}")),
            );
          }
        })
        ..onError.listen((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error upload file: $e")),
          );
        })
        ..send(formData);
    } catch (e) {
      print("Error saving project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving project: $e")),
      );
    }
  }

  Widget _buildRejectedCard(int index, Map<String, dynamic> approval) {
  return Card(
    child: ListTile(
      title: Text("MSRA Rejection by ${approval["role"]}"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Action by ${approval["name"]}"),
          const SizedBox(height: 8),
          Text("Comments: ${approval["comments"]}"),
        ],
      ),
      trailing: widget.selectedTab == 2
          ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Rejected"),
            )
          : null,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (widget.selectedTab == 0) {
      // Pending Approvals
      return ListView.builder(
        itemCount: _pendingApprovals.length,
        itemBuilder: (context, index) {
          var approval = _pendingApprovals[index];
          return _buildApprovalCard(index, approval);
        },
      );
    }

    if (widget.selectedTab == 1) {
      // Show Pending Approvals up to approvalStage
      return ListView.builder(
        itemCount: _pendingApprovals.length,
        itemBuilder: (context, index) {
          var approval = _pendingApprovals[index];
          // Show the approval only if the index is before or at the approvalStage
          if (index < widget.approvalStage) {
            return _buildApprovalCard(index, approval);
          }
          return SizedBox(); // Skip approvals after the approvalStage
        },
      );
    }

    if (widget.selectedTab == 2) {
      return ListView.builder(
        itemCount: widget.rejectionList.length,
        itemBuilder: (context, index) {
          var rejection = widget.rejectionList[index];
          return _buildRejectedCard(index, rejection);
        },
      );
    }

    if (widget.selectedTab == 3) {
      return SingleChildScrollView (
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            width: 400,
            child: FileReUploadWidget(
              key: _fileUploadKey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: uploadFile,
                child: const Text("Upload Revised MSRA"),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      );
    }

    return const Center(child: Text("No approvals available"));
  }
}