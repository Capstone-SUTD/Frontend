import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/project_model.dart';

class CargoDetailsTableWidget extends StatefulWidget {
  final List<Cargo> cargoList;
  final bool isEditable;
  final bool isNewProject;
  final bool hasRun;
  final VoidCallback? onRunPressed;
  final List<String>? resultList;
  final bool enableRunButton;
  final VoidCallback? onCargoChanged;

  const CargoDetailsTableWidget({
    super.key,
    required this.cargoList,
    required this.isEditable,
    required this.isNewProject,
    required this.hasRun,
    required this.onRunPressed,
    required this.enableRunButton,
    this.resultList,
    this.onCargoChanged,
  });

  @override
  CargoDetailsTableWidgetState createState() => CargoDetailsTableWidgetState();
}

class CargoDetailsTableWidgetState extends State<CargoDetailsTableWidget> {
  List<Map<String, String>> _cargoList = [];

  @override
  void initState() {
    super.initState();
    if (widget.isNewProject) {
      _cargoList = [
        {
          "cargoname": "",
          "length": "",
          "breadth": "",
          "height": "",
          "weight": "",
          "quantity": "",
          "result": ""
        }
      ];
    } else {
      _cargoList = widget.cargoList.map((cargo) {
        return {
          "cargoname": cargo.cargoname,
          "length": cargo.length,
          "breadth": cargo.breadth,
          "height": cargo.height,
          "weight": cargo.weight,
          "quantity": cargo.quantity,
          "result": cargo.result,
        };
      }).toList();
    }
  }

  void _addRow() {
    setState(() {
      _cargoList.add({
        "cargoname": "",
        "length": "",
        "breadth": "",
        "height": "",
        "weight": "",
        "quantity": "",
        "result": ""
      });
    });
    widget.onCargoChanged?.call();
  }

  void _updateCargo(int index, String key, String value) {
    setState(() {
      _cargoList[index][key] = value;
    });
    widget.onCargoChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: IntrinsicHeight(
            child: Column(
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
                    if (widget.isNewProject && widget.isEditable)
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
                    for (int i = 0; i < _cargoList.length; i++)
                      TableRow(
                        children: [
                          _buildTableCell(i, "cargoname", isString: true),
                          _buildDimensionCell(i),
                          _buildWeightCell(i),
                          _buildTableCell(i, "quantity"),
                          _buildResultCell(i),
                          if (widget.isNewProject) _buildActionButtons(i),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                if (widget.isNewProject && !widget.hasRun)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: widget.enableRunButton ? widget.onRunPressed : null,
                      child: const Text("Run"),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, String>> getCargoList() {
    return _cargoList;
  }

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

  Widget _buildTableCell(int index, String key, {bool isString = false}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: widget.isEditable
              ? TextFormField(
                  initialValue: _cargoList[index][key],
                  textAlign: TextAlign.center,
                  keyboardType: key == "quantity" ? TextInputType.number : TextInputType.text,
                  inputFormatters: key == "quantity"
                      ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
                      : [],
                  onChanged: (value) => _updateCargo(index, key, value),
                  decoration: const InputDecoration(border: InputBorder.none),
                )
              : Text(
                  _cargoList[index][key] ?? "",
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  Widget _buildDimensionCell(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildDimensionInput(index, "length"),
              const Text(" m × "),
              _buildDimensionInput(index, "breadth"),
              const Text(" m × "),
              _buildDimensionInput(index, "height"),
              const Text(" m"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionInput(int index, String key) {
    return SizedBox(
      width: 40,
      child: widget.isEditable
          ? TextFormField(
              initialValue: _cargoList[index][key],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              onChanged: (value) => _updateCargo(index, key, value),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
            )
          : Text(
              _cargoList[index][key] ?? "",
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _buildWeightCell(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextFormField(
                  initialValue: _cargoList[index]["weight"],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  onChanged: (value) => _updateCargo(index, "weight", value),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 4),
              const Text("kg", style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCell(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            (widget.resultList != null && index < widget.resultList!.length)
                ? widget.resultList![index]
                : (_cargoList[index]["result"] ?? " "),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(int index) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: index == 0
          ? const SizedBox.shrink()
          : MouseRegion(
              cursor: SystemMouseCursors.basic,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () {
                  setState(() {
                    _cargoList.removeAt(index);
                  });
                  widget.onCargoChanged?.call();
                },
              ),
            ),
    );
  }
}


