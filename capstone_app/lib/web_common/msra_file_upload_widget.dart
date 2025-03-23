import 'dart:html' as html;
import 'package:flutter/material.dart';

class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? _fileName;
  bool _isDragging = false;

  void _pickFile() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf,.doc,.docx';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final file = files[0];
        setState(() {
          _fileName = file.name;
        });
      }
    });
  }

  void _handleDragOver(html.Event event) {
    event.preventDefault();
    setState(() {
      _isDragging = true;
    });
  }

  void _handleDragLeave(html.Event event) {
    event.preventDefault();
    setState(() {
      _isDragging = false;
    });
  }

  void _handleDrop(html.Event event) {
    event.preventDefault();

    var dragEvent = event as dynamic; // Use dynamic casting

    final html.DataTransfer? dataTransfer = dragEvent.dataTransfer;

    if (dataTransfer != null && dataTransfer.files!.isNotEmpty) {
      final file = dataTransfer.files![0];

      setState(() {
        _fileName = file.name;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Vendor MSRA here",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: _isDragging ? Colors.blue.withOpacity(0.2) : Colors.white,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                    if (_fileName == null)
                      const Text("Choose a file or drag & drop it here"),
                    if (_fileName != null)
                      Text("Uploaded: $_fileName", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text("Browse File"),
                    ),
                  ],
                ),
                // Drag and Drop Listeners
                Positioned.fill(
                  child: DragTarget<html.File>(
                    onWillAccept: (_) => true,
                    onAccept: (file) {
                      setState(() {
                        _fileName = file.name;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return const SizedBox.expand();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
