import 'dart:convert';

class Project {
  final String client;
  final String projectId;
  final String projectName;
  final String projectType;
  final String startDestination;
  final String endDestination;
  final String currentTask;
  final String projectStatus;
  final DateTime startDate;
  final List<Cargo> cargo;
  final List<Scope> scope;

  Project({
    required this.client,
    required this.projectId,
    required this.projectName,
    required this.projectType,
    required this.startDestination,
    required this.endDestination,
    required this.currentTask,
    required this.projectStatus,
    required this.startDate,
    required this.cargo,
    required this.scope,
  });

  // Factory constructor to parse JSON into Dart object
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      client: json['client'],
      projectId: json['projectId'],
      projectName: json['projectname'],
      projectType: json['projecttype'],
      startDestination: json['startdestination'],
      endDestination: json['enddestination'],
      currentTask: json['currenttask'],
      projectStatus: json['projectstatus'],
      startDate: DateTime.parse(_convertDateFormat(json['startdate'])), // Handle date parsing
      cargo: (json['cargo'] as List).map((item) => Cargo.fromJson(item)).toList(),
      scope: (json['scope'] as List).map((item) => Scope.fromJson(item)).toList(),
    );
  }

  // Convert Dart object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'client': client,
      'projectId': projectId,
      'projectname': projectName,
      'projecttype': projectType,
      'startdestination': startDestination,
      'enddestination': endDestination,
      'currenttask': currentTask,
      'projectstatus': projectStatus,
      'startdate': startDate.toIso8601String(),
      'cargo': cargo.map((item) => item.toJson()).toList(),
      'scope': scope.map((item) => item.toJson()).toList(),
    };
  }

  // Helper function to convert date format from "DD/MM/YYYY" to "YYYY-MM-DD"
  static String _convertDateFormat(String date) {
    List<String> parts = date.split('/');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  // ✅ ADD THIS METHOD TO ALLOW UPDATING FIELDS
  Project copyWith({
    String? client,
    String? projectId,
    String? projectName,
    String? projectType,
    String? startDestination,
    String? endDestination,
    String? currentTask,
    String? projectStatus,
    DateTime? startDate,
    List<Cargo>? cargo,
    List<Scope>? scope,
  }) {
      return Project(
        client: client ?? this.client,
        projectId: projectId ?? this.projectId,
        projectName: projectName ?? this.projectName,
        projectType: projectType ?? this.projectType,
        startDestination: startDestination ?? this.startDestination,
        endDestination: endDestination ?? this.endDestination,
        currentTask: currentTask ?? this.currentTask,
        projectStatus: projectStatus ?? this.projectStatus,
        startDate: startDate ?? this.startDate,
        cargo: cargo ?? this.cargo,
        scope: scope ?? this.scope,
      );
  }
}


// Cargo Model
class Cargo {
  final String name;
  final String length;
  final String width;
  final String height;
  final String weight;
  final String quantity;

  Cargo({
    required this.name,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    required this.quantity,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      name: json['name'],
      length: json['length'],
      width: json['width'],
      height: json['height'],
      weight: json['weight'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'length': length,
      'width': width,
      'height': height,
      'weight': weight,
      'quantity': quantity,
    };
  }
}

// Scope Model
class Scope {
  final String start;
  final String description;
  final String equipment;

  Scope({
    required this.start,
    required this.description,
    required this.equipment,
  });

  factory Scope.fromJson(Map<String, dynamic> json) {
    return Scope(
      start: json['start'],
      description: json['description'],
      equipment: json['equipment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'description': description,
      'equipment': equipment,
    };
  }
}


