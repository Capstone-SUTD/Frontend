import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class MSRAGenerationScreen extends StatefulWidget {
  final dynamic project;
  const MSRAGenerationScreen({super.key, required this.project});

  @override
  _MSRAGenerationScreenState createState() => _MSRAGenerationScreenState();
}

class _MSRAGenerationScreenState extends State<MSRAGenerationScreen> {
  int _selectedApprovalTab = 0;
  int _approvalStage = 0;
  late dynamic _project;
  List<Map<String, dynamic>> _rejectionList = [];
  int _msVersions = 0;
  int _raVersions = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _loadApprovalStatus();
  }

  Future<void> _loadApprovalStatus() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Authentication required");

      final response = await http.post(
        Uri.parse('https:localhost:3000/approval-rejection-status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'projectid': int.tryParse(_project?.projectId?.toString() ?? "0") ?? 0
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _approvalStage = data['Approvals'] ?? 0;
          _msVersions = data['MSVersions'] ?? 0;
          _raVersions = data['RAVersions'] ?? 0;
          _rejectionList = _processRejectionData(data['RejectionDetails']);
        });
      } else {
        throw Exception("Failed to load approval status");
      }
    } catch (e) {
      _showError("Error loading data: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _processRejectionData(List<dynamic>? rejections) {
    return (rejections ?? []).map((rejection) {
      final role = rejection['role'];
      final stakeholder = _project.stakeholders.firstWhere(
        (s) => s.role == role,
        orElse: () => {'name': 'Unknown'},
      );
      return {
        'role': role,
        'comments': rejection['comments'],
        'name': stakeholder['name']
      };
    }).toList();
  }

  Future<void> _handleApprovalAction(String action) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Authentication required");

      final response = await http.post(
        Uri.parse('https:10.0.2.2:3000/handle-approval'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'projectid': _project.projectId,
          'action': action,
          'version': action == 'approve' ? _msVersions : _raVersions,
        }),
      );

      if (response.statusCode == 200) {
        _loadApprovalStatus(); // Refresh data
        _showSuccess("Action completed successfully");
      } else {
        throw Exception("Action failed");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildApprovalTabs() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Denied"),
              Tab(text: "Reupload"),
            ],
            onTap: (index) => setState(() => _selectedApprovalTab = index),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVersionIndicator(String label, int version) {
    return Chip(
      label: Text("$label v$version"),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Widget _buildApprovalControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("Approve"),
          onPressed: () => _handleApprovalAction('approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text("Reject"),
          onPressed: () => _showRejectionDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _showRejectionDialog() async {
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rejection Reason"),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter rejection reason...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "Rejected: User comment"),
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    if (comment != null) {
      await _handleApprovalAction('reject');
    }
  }

  Widget _buildRejectionList() {
    if (_rejectionList.isEmpty) {
      return const Center(child: Text("No rejections found"));
    }

    return ExpansionTile(
      title: const Text("Rejection Details", style: TextStyle(fontWeight: FontWeight.bold)),
      children: _rejectionList.map((rejection) => ListTile(
        title: Text("${rejection['role']}: ${rejection['name']}"),
        subtitle: Text(rejection['comments']),
        leading: const Icon(Icons.warning, color: Colors.orange),
      )).toList(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildApprovalTabs(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildVersionIndicator("MS", _msVersions),
            _buildVersionIndicator("RA", _raVersions),
          ],
        ),
        const SizedBox(height: 20),
        if (_approvalStage < 2) _buildApprovalControls(),
        const SizedBox(height: 20),
        if (_selectedApprovalTab == 2 && _rejectionList.isNotEmpty) 
          _buildRejectionList(),
        // Add other tab content here
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MS/RA Generation"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApprovalStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }
}