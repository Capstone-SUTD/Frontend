import 'package:flutter/material.dart';

class AttachmentPopup extends StatelessWidget {
  /// A callback that provides the selected file path back to the caller.
  final ValueChanged<String> onAttach;

  const AttachmentPopup({
    Key? key,
    required this.onAttach,  // Mark it required so it must be provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attach a File'),
      content: const Text('File selection UI goes here.'),
      actions: [
        TextButton(
          onPressed: () {
            // Suppose you have logic to pick a file & get a path:
            const dummyFilePath = '/path/to/chosen/file.png';

            // Call the callback with the path
            onAttach(dummyFilePath);

            // This will close the dialog from the parent side, if you prefer
            // Navigator.pop(context);
          },
          child: const Text('Attach'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

