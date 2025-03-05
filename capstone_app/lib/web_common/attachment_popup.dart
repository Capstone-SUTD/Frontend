import 'package:flutter/material.dart';

class AttachmentPopup extends StatelessWidget {
  const AttachmentPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Attachments"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Add Attachment"),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: 0.4),
          const Text("Attachment 1.jpg - 5.7MB"),
          LinearProgressIndicator(value: 0.4),
          const Text("Attachment 2.jpg - 4.2MB"),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Discard")),
        ElevatedButton(onPressed: () {}, child: const Text("Add")),
      ],
    );
  }
}
