import 'package:flutter/material.dart';

class CommentPopup extends StatefulWidget {
  final String? initialComment;
  final Function(String) onCommentAdded; // Pass comment text

  const CommentPopup({
    super.key,
    this.initialComment, // Make optional
    required this.onCommentAdded,
  });

  @override
  _CommentPopupState createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.initialComment ?? "");
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Comment"),
      content: TextField(
        controller: _commentController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Type your comment here...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Close popup
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_commentController.text.trim().isNotEmpty) {
              widget.onCommentAdded(_commentController.text); // Pass comment back
              Navigator.pop(context);
            }
          },
          child: Text(widget.initialComment != null && widget.initialComment!.isNotEmpty
              ? "Update Comment"
              : "Add Comment"),
        ),
      ],
    );
  }
}

