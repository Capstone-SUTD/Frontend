import 'package:flutter/material.dart';
import '../models/project_model.dart';

class WorkScopeWidget extends StatefulWidget {
  final bool isNewProject;
  final List<Scope>? workScopeList;

  // ✅ New callback to notify when scope changes
  final VoidCallback? onWorkScopeChanged;

  const WorkScopeWidget({
    Key? key,
    required this.isNewProject,
    this.workScopeList,
    this.onWorkScopeChanged, // ✅ Include it here
  }) : super(key: key);

  @override
  WorkScopeWidgetState createState() => WorkScopeWidgetState();
}

class WorkScopeWidgetState extends State<WorkScopeWidget> {
  List<Map<String, String>> _workScopeList = [];
  final List<String> _scopeOptions = ["Lifting", "Transportation"];
  bool get isReadOnly => widget.workScopeList != null && widget.workScopeList!.isNotEmpty;

  List<Map<String, String>> getWorkScopeData() => _workScopeList;

  @override
  void initState() {
    super.initState();
    if (widget.workScopeList != null && widget.workScopeList!.isNotEmpty) {
      _workScopeList = widget.workScopeList!
          .map((scope) => {
                "startDestination": scope.startdestination,
                "endDestination": scope.enddestination,
                "scope": scope.scope,
                "equipmentList": scope.equipmentList
              })
          .toList();
    } else if (widget.isNewProject) {
      _workScopeList = [
        {"startDestination": "", "endDestination": "", "scope": "", "equipmentList": ""}
      ];
    }
  }

  void _addRow() {
    setState(() {
      _workScopeList.add({"startDestination": "", "endDestination": "", "scope": "", "equipmentList": ""});
    });
    widget.onWorkScopeChanged?.call(); // ✅ Trigger on add
  }

  void _updateWorkScope(int index, String key, String value) {
    setState(() {
      _workScopeList[index][key] = value;
    });
    widget.onWorkScopeChanged?.call(); // ✅ Trigger on update
  }

  void _removeRow(int index) {
    setState(() {
      _workScopeList.removeAt(index);
    });
    widget.onWorkScopeChanged?.call(); // ✅ Trigger on delete
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Work Scope Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Work Scope Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!isReadOnly)
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: const Text("Add Row"),
              ),
          ],
        ),
        const SizedBox(height: 8),

        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: isReadOnly
                      ? {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(3),
                        }
                      : {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(3),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(3),
                          4: FlexColumnWidth(1),
                        },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: [
                        _buildHeaderCell("Start Destination"),
                        _buildHeaderCell("End Destination"),
                        _buildHeaderCell("Scope"),
                        _buildHeaderCell("Equipment"),
                        if (!isReadOnly) _buildHeaderCell("Action"),
                      ],
                    ),
                    ...List.generate(_workScopeList.length, (i) {
                      return TableRow(
                        children: [
                          _buildTableCell(i, "startDestination"),
                          _buildTableCell(i, "endDestination"),
                          _buildDropdownCell(i),
                          _buildEquipmentCell(i),
                          if (!isReadOnly)
                            (i == 0 ? _buildEmptyActionCell() : _buildActionCell(i)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
      ],
    );
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

  Widget _buildTableCell(int index, String key) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: isReadOnly
            ? Text(_workScopeList[index][key] ?? "", textAlign: TextAlign.center)
            : TextFormField(
                initialValue: _workScopeList[index][key],
                textAlign: TextAlign.center,
                onChanged: (value) => _updateWorkScope(index, key, value),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
      ),
    );
  }

  Widget _buildDropdownCell(int index) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: isReadOnly
            ? Text(_workScopeList[index]["scope"] ?? "", textAlign: TextAlign.center)
            : Container(
                constraints: const BoxConstraints(maxWidth: 150),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _workScopeList[index]["scope"]!.isNotEmpty
                      ? _workScopeList[index]["scope"]
                      : null,
                  items: _scopeOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
                  onChanged: (value) => _updateWorkScope(index, "scope", value!),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
      ),
    );
  }

  Widget _buildEquipmentCell(int index) {
    String equipmentValue = _workScopeList[index]["equipmentList"] ?? "";

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: isReadOnly
            ? Text(equipmentValue, textAlign: TextAlign.center)
            : ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                child: _workScopeList[index]["scope"] == "Lifting"
                    ? TextFormField(
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          _updateWorkScope(index, "equipmentList", "$value ton crane");
                        },
                        decoration: const InputDecoration(
                          labelText: "Enter Crane Threshold (Tons)",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      )
                    : _workScopeList[index]["scope"] == "Transportation"
                        ? DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _workScopeList[index]["equipmentList"]!.isNotEmpty
                                ? _workScopeList[index]["equipmentList"]
                                : null,
                            items: [
                              "8ft X 40ft Trailer",
                              "8ft X 45ft Trailer",
                              "8ft X 50ft Trailer",
                              "10.5ft X 30ft Low Bed",
                              "10.5ft X 40ft Low Bed",
                              "Self Loader"
                            ].map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateWorkScope(index, "equipmentList", value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: "Select Transport",
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          )
                        : TextFormField(
                            initialValue: equipmentValue,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              _updateWorkScope(index, "equipmentList", value);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
              ),
      ),
    );
  }

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

  Widget _buildEmptyActionCell() {
    return const TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Center(child: SizedBox()),
    );
  }
}

