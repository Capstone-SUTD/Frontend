import 'package:flutter/material.dart';
import '../models/project_model.dart';

class WorkScopeWidget extends StatefulWidget {
  final bool isNewProject;
  final List<Scope>? workScopeList;
  final Function(List<Map<String, String>>)? onWorkScopeUpdated;

  const WorkScopeWidget({
    Key? key,
    required this.isNewProject,
    this.workScopeList,
    this.onWorkScopeUpdated,
  }) : super(key: key);

  @override
  WorkScopeWidgetState createState() => WorkScopeWidgetState();
}

class WorkScopeWidgetState extends State<WorkScopeWidget> {
  late List<Map<String, String>> _workScopeList;
  final List<String> _scopeOptions = ["Lifting", "Transportation", "Other"];
  bool _isReadOnly = false;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> get workScopeData => _workScopeList;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.workScopeList != null && widget.workScopeList!.isNotEmpty;
    _initializeWorkScopeList();
  }

  void _initializeWorkScopeList() {
    if (_isReadOnly) {
      _workScopeList = widget.workScopeList!.map((scope) {
        return {
          "startDestination": scope.startdestination,
          "endDestination": scope.enddestination,
          "scope": scope.scope,
          "equipmentList": scope.equipmentList,
          "id": scope.id?.toString() ?? "",
        };
      }).toList();
    } else if (widget.isNewProject) {
      _workScopeList = [
        {
          "startDestination": "",
          "endDestination": "",
          "scope": "",
          "equipmentList": "",
          "id": DateTime.now().millisecondsSinceEpoch.toString(),
        }
      ];
    } else {
      _workScopeList = [];
    }
  }

  void _addRow() {
    setState(() {
      _workScopeList.add({
        "startDestination": "",
        "endDestination": "",
        "scope": "",
        "equipmentList": "",
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
      });
    });
    _notifyParent();
  }

  void _updateWorkScope(int index, String key, String value) {
    setState(() {
      _workScopeList[index][key] = value;
    });
    _notifyParent();
  }

  void _removeRow(int index) {
    setState(() {
      _workScopeList.removeAt(index);
    });
    _notifyParent();
  }

  void _notifyParent() {
    if (widget.onWorkScopeUpdated != null) {
      widget.onWorkScopeUpdated!(_workScopeList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Work Scope Details",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isReadOnly)
                ElevatedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Scope"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_workScopeList.isEmpty)
            const Center(child: Text("No work scopes added")),
          
          if (_workScopeList.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: isSmallScreen ? Axis.horizontal : Axis.vertical,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Table(
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: theme.dividerColor),
                  ),
                  columnWidths: {
                    0: const FlexColumnWidth(3),
                    1: const FlexColumnWidth(3),
                    2: const FlexColumnWidth(2),
                    3: const FlexColumnWidth(3),
                    if (!_isReadOnly) 4: const FixedColumnWidth(60),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    // Table Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                      ),
                      children: [
                        _buildHeaderCell("Start Destination", theme),
                        _buildHeaderCell("End Destination", theme),
                        _buildHeaderCell("Scope", theme),
                        _buildHeaderCell("Equipment", theme),
                        if (!_isReadOnly) _buildHeaderCell("", theme),
                      ],
                    ),

                    // Table Data Rows
                    for (int i = 0; i < _workScopeList.length; i++)
                      TableRow(
                        decoration: BoxDecoration(
                          color: i.isEven
                              ? theme.colorScheme.surface
                              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        children: [
                          _buildTableCell(i, "startDestination", theme),
                          _buildTableCell(i, "endDestination", theme),
                          _buildDropdownCell(i, theme),
                          _buildEquipmentCell(i, theme),
                          if (!_isReadOnly) _buildActionCell(i, theme),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, ThemeData theme) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(int index, String key, ThemeData theme) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: _isReadOnly
            ? Text(
                _workScopeList[index][key] ?? "",
                style: theme.textTheme.bodyMedium,
              )
            : TextFormField(
                initialValue: _workScopeList[index][key],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                onChanged: (value) => _updateWorkScope(index, key, value),
              ),
      ),
    );
  }

  Widget _buildDropdownCell(int index, ThemeData theme) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: _isReadOnly
            ? Text(
                _workScopeList[index]["scope"] ?? "",
                style: theme.textTheme.bodyMedium,
              )
            : DropdownButtonFormField<String>(
                value: _workScopeList[index]["scope"]!.isNotEmpty
                    ? _workScopeList[index]["scope"]
                    : null,
                items: _scopeOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyMedium,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select scope';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value != null) {
                    _updateWorkScope(index, "scope", value);
                    // Clear equipment when scope changes
                    _updateWorkScope(index, "equipmentList", "");
                  }
                },
              ),
      ),
    );
  }

  Widget _buildEquipmentCell(int index, ThemeData theme) {
    final scope = _workScopeList[index]["scope"] ?? "";
    final equipmentValue = _workScopeList[index]["equipmentList"] ?? "";

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: _isReadOnly
            ? Text(equipmentValue, style: theme.textTheme.bodyMedium)
            : _buildEquipmentInput(index, scope, theme),
      ),
    );
  }

  Widget _buildEquipmentInput(int index, String scope, ThemeData theme) {
    switch (scope) {
      case "Lifting":
        return TextFormField(
          initialValue: _workScopeList[index]["equipmentList"]
              ?.replaceAll(" ton crane", ""),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: "Enter tons",
          ),
          style: theme.textTheme.bodyMedium,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter tons';
            }
            if (double.tryParse(value) == null) {
              return 'Enter valid number';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              _updateWorkScope(index, "equipmentList", "$value ton crane");
            }
          },
        );
      case "Transportation":
        return TextFormField(
          initialValue: _workScopeList[index]["equipmentList"]
              ?.replaceAll(" trailer", ""),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: "Enter trailer type",
          ),
          style: theme.textTheme.bodyMedium,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter trailer';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              _updateWorkScope(index, "equipmentList", "$value trailer");
            }
          },
        );
      default:
        return TextFormField(
          initialValue: _workScopeList[index]["equipmentList"],
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: "Enter equipment",
          ),
          style: theme.textTheme.bodyMedium,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter equipment';
            }
            return null;
          },
          onChanged: (value) => _updateWorkScope(index, "equipmentList", value),
        );
    }
  }

  Widget _buildActionCell(int index, ThemeData theme) {
    return TableCell(
      child: Center(
        child: IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: () => _removeRow(index),
          tooltip: 'Remove scope',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  bool validate() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }
}