import 'package:flutter/material.dart';
import '../models/project_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'custom_equipment_options';

class WorkScopeWidget extends StatefulWidget {
  final bool isNewProject;
  final List<Scope>? workScopeList;
  final VoidCallback? onWorkScopeChanged;

  const WorkScopeWidget({
    Key? key,
    required this.isNewProject,
    this.workScopeList,
    this.onWorkScopeChanged,
  }) : super(key: key);

  @override
  WorkScopeWidgetState createState() => WorkScopeWidgetState();
}

class WorkScopeWidgetState extends State<WorkScopeWidget> {
  List<Map<String, String>> _workScopeList = [];
  final List<String> _scopeOptions = ["Lifting", "Transportation"];
  bool get isReadOnly => widget.workScopeList != null && widget.workScopeList!.isNotEmpty;

  List<Map<String, String>> getWorkScopeData() => _workScopeList;

  List<String> _defaultEquipmentOptions = [
    "8ft X 40ft Trailer",
    "8ft X 45ft Trailer",
    "8ft X 50ft Trailer",
    "10.5ft X 30ft Low Bed",
    "10.5ft X 40ft Low Bed",
    "Self Loader",
  ];

  Set<String> _customEquipmentOptions = {};
  Map<int, TextEditingController> _controllers = {};

  Future<void> _saveCustomEquipmentOptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _customEquipmentOptions.toList());
  }

  Future<void> _loadCustomEquipmentOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOptions = prefs.getStringList(_prefsKey);
    if (savedOptions != null) {
      setState(() {
        _customEquipmentOptions = savedOptions.toSet();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomEquipmentOptions();

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
    widget.onWorkScopeChanged?.call();
  }

  void _updateWorkScope(int index, String key, String value) {
    setState(() {
      _workScopeList[index][key] = value;
    });
    widget.onWorkScopeChanged?.call();
  }

  void _removeRow(int index) {
    setState(() {
      _workScopeList.removeAt(index);
      _controllers.remove(index);
    });
    widget.onWorkScopeChanged?.call();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                cursorColor: Colors.black87,
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
    String currentValue = _workScopeList[index]["equipmentList"] ?? "";
    _controllers[index] ??= TextEditingController(text: currentValue);

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: isReadOnly
            ? Text(currentValue, textAlign: TextAlign.center)
            : ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                child: _workScopeList[index]["scope"] == "Lifting"
                    ? TextFormField(
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          _updateWorkScope(index, "equipmentList", "$value ton crane");
                        },
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        cursorColor: Colors.black87,
                        decoration: const InputDecoration(
                          labelText: "Enter Crane Threshold (Tons)",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          labelStyle: const TextStyle(color: Colors.black87),
                        ),
                      )
                    : _workScopeList[index]["scope"] == "Transportation"
                        ? Row(
                            children: [
                              Expanded(
                                child: TypeAheadFormField<String>(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: _controllers[index]!,
                                    onEditingComplete: () {
                                      String newValue = _controllers[index]!.text.trim();
                                      if (!_defaultEquipmentOptions.contains(newValue) &&
                                          !_customEquipmentOptions.contains(newValue) &&
                                          newValue.isNotEmpty) {
                                        setState(() {
                                          _customEquipmentOptions.add(newValue);
                                        });
                                        _saveCustomEquipmentOptions();
                                      }
                                      _updateWorkScope(index, "equipmentList", newValue);
                                      FocusScope.of(context).unfocus();
                                    },
                                    cursorColor: Colors.black87,
                                    decoration: const InputDecoration(
                                      labelText: "Select or Add Equipment",
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      labelStyle: const TextStyle(color: Colors.black87),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black87, width: 2),
                                      ),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    return [
                                      ..._defaultEquipmentOptions,
                                      ..._customEquipmentOptions
                                    ].where((item) => item.toLowerCase().contains(pattern.toLowerCase()));
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(title: Text(suggestion));
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    _controllers[index]!.text = suggestion;
                                    _updateWorkScope(index, "equipmentList", suggestion);
                                  },
                                ),
                              ),
                              if (!_defaultEquipmentOptions.contains(currentValue) &&
                                  currentValue.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: Text("Are you sure you want to delete \"$currentValue\" from your custom equipment list?"),
                                          actions: [
                                            TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            TextButton(
                                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        setState(() {
                                          _customEquipmentOptions.remove(currentValue);
                                          _workScopeList[index]["equipmentList"] = "";
                                          _controllers[index]!.clear();
                                        });
                                        _saveCustomEquipmentOptions();
                                      }
                                    },
                                  ),
                            ],
                          )
                        : TextFormField(
                            initialValue: currentValue,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              _updateWorkScope(index, "equipmentList", value);
                            },
                            cursorColor: Colors.black87,
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



