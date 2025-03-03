import 'package:flutter/material.dart';

class OffsiteChecklistWidget extends StatefulWidget {
  const OffsiteChecklistWidget({super.key});

  @override
  _OffsiteChecklistWidgetState createState() => _OffsiteChecklistWidgetState();
}

class _OffsiteChecklistWidgetState extends State<OffsiteChecklistWidget> {
  List<bool> _checkedItems = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Fixed sidebar width
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Offsite Checklist",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildChecklistItem(0, "Review System Generated MS"),
          _buildChecklistItem(1, "Fill in Lifting and Lashing Point"),
          _buildChecklistItem(2, "Fill in Route Optimization"),
          _buildChecklistItem(3, "Upload the Edited MS to System"),
          _buildChecklistItem(4, "Confirm All Stakeholders Approved MS"),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(int index, String title) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: _checkedItems[index],
      onChanged: (bool? value) {
        setState(() {
          _checkedItems[index] = value!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

