import 'dart:html' as html;
import 'package:flutter/material.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({Key? key}) : super(key: key);

  @override
  FileUploadWidgetState createState() => FileUploadWidgetState();
}

class FileUploadWidgetState extends State<FileUploadWidget> {
  List<html.File> _uploadedFiles = [];
  bool _isDragging = false;

  List<html.File> getUploadedFiles() {
    return _uploadedFiles;
  }

  void _pickFiles() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf,.doc,.docx,.csv,.xlsx';
    uploadInput.multiple = true; 
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        setState(() {
          _uploadedFiles.addAll(files);
        });
      }
    });
  }

  void _handleDrop(html.Event event) {
    event.preventDefault();
    final dragEvent = event as dynamic;
    final html.DataTransfer? dataTransfer = dragEvent.dataTransfer;

    if (dataTransfer != null && dataTransfer.files!.isNotEmpty) {
      setState(() {
        _uploadedFiles.addAll(dataTransfer.files!);
      });
    }
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

  @override
  void initState() {
    super.initState();
    html.document.body?.addEventListener('dragover', _handleDragOver);
    html.document.body?.addEventListener('drop', _handleDrop);
    html.document.body?.addEventListener('dragleave', _handleDragLeave);
  }

  @override
  void dispose() {
    html.document.body?.removeEventListener('dragover', _handleDragOver);
    html.document.body?.removeEventListener('drop', _handleDrop);
    html.document.body?.removeEventListener('dragleave', _handleDragLeave);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Vendor MSRA files",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: _isDragging ? Colors.blue.withOpacity(0.1) : Colors.white,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text("Choose or drag & drop multiple files"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickFiles,
                    child: const Text("Browse Files"),
                  ),
                  const SizedBox(height: 10),
                  if (_uploadedFiles.isNotEmpty)
                    Column(
                      children: _uploadedFiles
                          .map((file) => Text("• ${file.name}"))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}




