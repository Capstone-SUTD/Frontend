import 'package:flutter/material.dart';

class DownloadMSRAWidget extends StatelessWidget {
  const DownloadMSRAWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDownloadButton("Download MS"),
        _buildDownloadButton("Download RA"),
      ],
    );
  }

  Widget _buildDownloadButton(String label) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: Text(label),
        ),
        const SizedBox(height: 5),
        const Text(
          "Created on: 23:45\n10 Nov 2024",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
