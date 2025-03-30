import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? _fileName;
  bool _isDragging = false;
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
          _fileName = _pickedFile?.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _handleDragEnter(DragTargetDetails details) {
    setState(() => _isDragging = true);
  }

  void _handleDragExit() {
    setState(() => _isDragging = false);
  }

  void _handleDrop(DragTargetDetails<PlatformFile> details) {
    setState(() {
      _isDragging = false;
      _pickedFile = details.data;
      _fileName = _pickedFile?.name;
    });
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
          child: MouseRegion(
            onEnter: (_) => setState(() => _isDragging = true),
            onExit: (_) => setState(() => _isDragging = false),
            child: DragTarget<PlatformFile>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: _handleDrop,
              onLeave: (_) => _handleDragExit(),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isDragging ? Colors.blue : Colors.grey,
                      width: _isDragging ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _isDragging 
                        ? Colors.blue 
                        : Colors.grey,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isDragging ? Icons.file_upload : Icons.cloud_upload,
                        size: 50,
                        color: _isDragging ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      if (_fileName == null)
                        Text(
                          _isDragging 
                              ? "Drop your file here"
                              : "Choose a file or drag & drop it here",
                          style: TextStyle(
                            color: _isDragging ? Colors.blue : Colors.grey,
                          ),
                        ),
                      if (_fileName != null)
                        Text(
                          "Uploaded: $_fileName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDragging ? Colors.blue : null,
                        ),
                        child: Text(
                          _isDragging ? "Release to upload" : "Browse File",
                          style: TextStyle(
                            color: _isDragging ? Colors.white : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Add this method to get the picked file data
  PlatformFile? getPickedFile() {
    return _pickedFile;
  }
}