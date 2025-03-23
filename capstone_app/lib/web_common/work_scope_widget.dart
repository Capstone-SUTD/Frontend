import 'package:flutter/material.dart';
import 'package:capstone_app/web_screens/msra_generation_screen.dart';

class WorkScopeWidget extends StatefulWidget {
  final bool isNewProject;

  const WorkScopeWidget({
    Key? key,
    required this.isNewProject,
  }) : super(key: key);

  @override
  _WorkScopeWidgetState createState() => _WorkScopeWidgetState();
}

class _WorkScopeWidgetState extends State<WorkScopeWidget> {
  List<Map<String, String>> _workScopeList = [];

  final List<String> _scopeOptions = ["Lifting", "Lashing", "Transportation"];

  @override
  void initState() {
    super.initState();
    // Default to one row if it's a new project
    if (widget.isNewProject) {
      _workScopeList = [
        {"startDestination": "", "endDestination": "", "scope": "", "equipmentList": ""}
      ];
    }
  }

  void _addRow() {
    setState(() {
      _workScopeList.add({"startDestination": "", "endDestination": "", "scope": "", "equipmentList": ""});
    });
  }

  void _updateWorkScope(int index, String key, String value) {
    setState(() {
      _workScopeList[index][key] = value;
    });
  }

  void _removeRow(int index) {
    setState(() {
      _workScopeList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **Work Scope Details Header with Add Row Button**
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Work Scope Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text("Add Row"),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(3),
            4: FlexColumnWidth(1), // Action column
          },
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                _buildHeaderCell("Start Destination"),
                _buildHeaderCell("End Destination"),
                _buildHeaderCell("Scope"),
                _buildHeaderCell("Equipment List"),
                _buildHeaderCell("Action"),
              ],
            ),

            // Table Data Rows
            for (int i = 0; i < _workScopeList.length; i++)
              TableRow(
                children: [
                  _buildTableCell(i, "startDestination"),
                  _buildTableCell(i, "endDestination"),
                  _buildDropdownCell(i),
                  _buildTableCell(i, "equipmentList"),
                  i == 0 ? _buildEmptyActionCell() : _buildActionCell(i), // Empty action for first row
                ],
              ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // ✅ **Header Cell Builder**
  Widget _buildHeaderCell(String title) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ✅ **Table Cell Builder for Editable Text Fields**
  Widget _buildTableCell(int index, String key) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          initialValue: _workScopeList[index][key],
          textAlign: TextAlign.center,
          onChanged: (value) => _updateWorkScope(index, key, value),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  // ✅ **Dropdown Cell for Scope**
  Widget _buildDropdownCell(int index) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
          value: _workScopeList[index]["scope"]!.isNotEmpty ? _workScopeList[index]["scope"] : null,
          items: _scopeOptions.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) => _updateWorkScope(index, "scope", value!),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  // ✅ **Action Cell with Remove Button**
  Widget _buildActionCell(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeRow(index),
        ),
      ),
    );
  }

  // ✅ **Empty Action Cell for First Row**
  Widget _buildEmptyActionCell() {
    return const TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(child: SizedBox()), // Empty placeholder
    );
  }
}


