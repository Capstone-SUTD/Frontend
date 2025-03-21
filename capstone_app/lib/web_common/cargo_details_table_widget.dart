import 'package:flutter/material.dart';
import '../models/project_model.dart';

class CargoDetailsTableWidget extends StatefulWidget {
  final List<Cargo> cargoList;
  final bool isEditable;
  final bool isNewProject;
  final bool hasRun;
  final String projectType;
  final VoidCallback? onRunPressed;

  const CargoDetailsTableWidget({
    super.key,
    required this.cargoList,
    required this.isEditable,
    required this.isNewProject,
    required this.hasRun,
    required this.projectType,
    required this.onRunPressed,
  });

  @override
  _CargoDetailsTableWidgetState createState() => _CargoDetailsTableWidgetState();
}

class _CargoDetailsTableWidgetState extends State<CargoDetailsTableWidget> {
  List<Map<String, String>> _cargoList = [];

  @override
  void initState() {
    super.initState();
    if (widget.isNewProject) {
      _cargoList = [
        {"name": "", "length": "", "width": "", "height": "", "weight": "", "quantity": ""}
      ];
    } else {
      _cargoList = widget.cargoList.map((cargo) {
        return {
          "name": cargo.name,
          "length": cargo.length,
          "width": cargo.width,
          "height": cargo.height,
          "weight": cargo.weight,
          "quantity": cargo.quantity,
        };
      }).toList();
    }
  }

  void _addRow() {
    setState(() {
      _cargoList.add({"name": "", "length": "", "width": "", "height": "", "weight": "", "quantity": ""});
    });
  }

  void _updateCargo(int index, String key, String value) {
    setState(() {
      _cargoList[index][key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // **Cargo Details Header with Add Row Button**
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Cargo Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.isNewProject)
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
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
            5: FlexColumnWidth(2),
          },
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                _buildHeaderCell("Cargo Name"),
                _buildHeaderCell("Dimension (LxBxH)"),
                _buildHeaderCell("Weight"),
                _buildHeaderCell("No of Units"),
                _buildHeaderCell("Result"),
                if (widget.isNewProject) _buildHeaderCell("Action"),
              ],
            ),

            // Table Data Rows
            for (int i = 0; i < _cargoList.length; i++)
              TableRow(
                children: [
                  _buildTableCell(i, "name"),
                  _buildDimensionCell(i), // Updated Dimension field
                  _buildWeightCell(i), // Updated Weight field with "tons"
                  _buildTableCell(i, "quantity"),
                  _buildResultCell(),
                  if (widget.isNewProject) _buildActionButtons(i),
                ],
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Show "Run" button if it's a new project & hasn't run yet
        if (widget.isNewProject && !widget.hasRun)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: widget.onRunPressed,
              child: const Text("Run"),
            ),
          ),
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

  // ✅ **Table Cell Builder for Editable Fields**
  Widget _buildTableCell(int index, String key) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          initialValue: _cargoList[index][key],
          textAlign: TextAlign.center,
          onChanged: (value) => _updateCargo(index, key, value),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  // ✅ **Dimension Cell with "cm" Always Visible**
  Widget _buildDimensionCell(int index) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDimensionInput(index, "length"),
            const Text(" cm × "),
            _buildDimensionInput(index, "width"),
            const Text(" cm × "),
            _buildDimensionInput(index, "height"),
            const Text(" cm"),
          ],
        ),
      ),
    );
  }

  // **Helper for Dimension Input Fields**
  Widget _buildDimensionInput(int index, String key) {
    return SizedBox(
      width: 40,
      child: TextFormField(
        initialValue: _cargoList[index][key],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) => _updateCargo(index, key, value),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
    );
  }

  // ✅ **Weight Cell with "tons" Always Visible**
  Widget _buildWeightCell(int index) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: TextFormField(
                initialValue: _cargoList[index]["weight"],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateCargo(index, "weight", value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Text("tons"),
          ],
        ),
      ),
    );
  }

  // ✅ **Result Cell**
  Widget _buildResultCell() {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          widget.projectType.isNotEmpty ? widget.projectType : " ", // Ensuring result consistency
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ✅ **Action Buttons for New Projects**
  Widget _buildActionButtons(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          setState(() {
            _cargoList.removeAt(index);
          });
        },
      ),
    );
  }
}




