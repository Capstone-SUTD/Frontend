import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadMSRAWidget extends StatefulWidget {
  final String projectId;
  final String projectName;
  final int msVersion;
  final int raVersion;

  const DownloadMSRAWidget({
    Key? key,
    required this.projectId,
    required this.projectName,
    required this.msVersion,
    required this.raVersion,
  }) : super(key: key);

  @override
  State<DownloadMSRAWidget> createState() => _DownloadMSRAWidgetState();
}

class _DownloadMSRAWidgetState extends State<DownloadMSRAWidget> {
  late int selectedMSVersion;
  late int selectedRAVersion;

  @override
  void initState() {
    super.initState();
    selectedMSVersion = widget.msVersion;
    selectedRAVersion = widget.raVersion;
  }

  Future<void> _downloadFile(String fileType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception("Token not found");

      final uri = Uri.parse('https://backend-app-huhre9drhvh6dphh.southeastasia-01.azurewebsites.net/app/download');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectid': int.tryParse(widget.projectId),
          'filetype': fileType,
          'version': fileType == "MS" ? selectedMSVersion : selectedRAVersion,
        }),
      );

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        String extension = fileType == "MS" ? "docx" : "xlsx";
        String projname = widget.projectName;
        String ver = fileType == "MS" ? selectedMSVersion.toString() : selectedRAVersion.toString();
        String fileName = "$projname-$fileType(v$ver).$extension";

        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
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

  void _changeVersion(String fileType, int change) {
    setState(() {
      if (fileType == "MS") {
        selectedMSVersion = (selectedMSVersion + change).clamp(1, widget.msVersion);
      } else {
        selectedRAVersion = (selectedRAVersion + change).clamp(1, widget.raVersion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
          child: Text(
            "Files Prepared Here",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        // const SizedBox(height: 4), 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDownloadButton("Download MS", "MS", selectedMSVersion),
            _buildDownloadButton("Download RA", "RA", selectedRAVersion),
          ],
        ),
      ],
    );
  }


  Widget _buildDownloadButton(String label, String fileType, int version) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: version > 1 ? () => _changeVersion(fileType, -1) : null,
            ),
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
            IconButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: version < (fileType == "MS" ? widget.msVersion : widget.raVersion)
                  ? () => _changeVersion(fileType, 1)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          "Version: $version",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}