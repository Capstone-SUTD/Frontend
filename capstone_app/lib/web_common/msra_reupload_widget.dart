import 'dart:html' as html;
import 'package:flutter/material.dart';

class FileReUploadWidget extends StatefulWidget {
  const FileReUploadWidget({Key? key}) : super(key: key);

  @override
  FileReUploadWidgetState createState() => FileReUploadWidgetState();
}

class FileReUploadWidgetState extends State<FileReUploadWidget> {
  List<html.File> _uploadedFiles = [];
  bool _isDragging = false;
  String? _selectedType;

  List<html.File> getUploadedFiles() {
    return _uploadedFiles;
  }

  void _pickFiles() {
    if (_selectedType == null) {
      return;
    }
    
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = _selectedType == 'MS' ? '.docx' : '.xlsx';
    uploadInput.multiple = false;
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

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
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
          "Select filetype for reupload:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: _selectedType,
          hint: const Text("Select file type"),
          onChanged: (value) {
            setState(() {
              _selectedType = value;
              _uploadedFiles.clear();
            });
          },
          items: ["MS", "RA"].map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: _isDragging ? Colors.blue.withOpacity(0.1) : Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                const Text("Choose or drag & drop MS(.docx) or RA(.xlsx) files"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selectedType != null ? _pickFiles : null,
                  child: const Text("Browse Files"),
                ),
                const SizedBox(height: 10),
                if (_uploadedFiles.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _uploadedFiles.length,
                    itemBuilder: (context, index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "• ${_uploadedFiles[index].name}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeFile(index),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}