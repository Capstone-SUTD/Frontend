import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadMSRAWidget extends StatefulWidget {
  final String projectId;
  final DateTime createdDateTime;

  const DownloadMSRAWidget({
    Key? key,
    required this.projectId,
    required this.createdDateTime,
  }) : super(key: key);

  @override
  State<DownloadMSRAWidget> createState() => _DownloadMSRAWidgetState();
}

class _DownloadMSRAWidgetState extends State<DownloadMSRAWidget> {
  late String formattedDateTime;

  @override
  void initState() {
    super.initState();
    final timeStr = DateFormat('HH:mm').format(widget.createdDateTime);
    final dateStr = DateFormat('dd MMM yyyy').format(widget.createdDateTime);
    formattedDateTime = 'Created on: $timeStr\n$dateStr';
  }

  Future<void> _downloadFile(String fileType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception("Token not found");

      final uri = Uri.parse('http://localhost:5000/app/download');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid': int.tryParse(widget.projectId),
          'filetype': fileType,
          'version': 1,
        }),
      );

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "$fileType.pdf")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        throw Exception("Download failed: ${response.body}");
      }
    } catch (e) {
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download $fileType")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDownloadButton("Download MS", "MS"),
        _buildDownloadButton("Download RA", "RA"),
      ],
    );
  }

  Widget _buildDownloadButton(String label, String fileType) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _downloadFile(fileType),
          icon: const Icon(Icons.download, color: Colors.deepPurple),
          label: Text(label, style: const TextStyle(color: Colors.deepPurple)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.deepPurple),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          formattedDateTime,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}


