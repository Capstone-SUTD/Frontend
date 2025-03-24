import 'dart:convert';

import 'package:capstone_app/mobile_screens/new_project_form.dart';

class Project {
  final String client;
  final String projectId;
  final String projectName;
  final String projectType;
  final String startDestination;
  final String endDestination;
  final String projectStatus;
  final DateTime startDate;
  final String emailsubjectheader;
  final List<Stakeholder> stakeholders;
  final List<Cargo> cargo;
  final List<Scope> scope;

  Project({
    required this.client,
    required this.projectId,
    required this.projectName,
    required this.projectType,
    required this.startDestination,
    required this.endDestination,
    required this.projectStatus,
    required this.startDate,
    required this.emailsubjectheader,
    required this.stakeholders,
    required this.cargo,
    required this.scope,
  });

  // Factory constructor to parse JSON into Dart object
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      client: json['client']?.toString() ?? "",
      projectId: json['projectid'].toString(), // match API key
      projectName: json['projectname'] ?? "",
      projectType: json['projecttype'] ?? "",
      startDestination: json['startdestination'] ?? "",
      endDestination: json['enddestination'] ?? "",
      projectStatus: "", 
      emailsubjectheader: json['emailsubjectheader'].toString() ?? "",
      startDate: DateTime.tryParse(json['startdate']) ?? DateTime.now(),
      stakeholders: (json['stakeholders'] as List<dynamic>? ?? [])
          .map((item) => Stakeholder.fromJson(item))
          .toList(),
      cargo: (json['cargo'] as List<dynamic>? ?? [])
          .map((item) => Cargo.fromJson(item))
          .toList(),
      scope: (json['scope'] as List<dynamic>? ?? [])
          .map((item) => Scope.fromJson(item))
          .toList(),
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
      'projectstatus': projectStatus,
      'emailsubjectheader': emailsubjectheader,
      'startdate': startDate.toIso8601String(),
      'stakeholders': stakeholders.map((item) => item.toJson()).toList(),
      'cargo': cargo.map((item) => item.toJson()).toList(),
      'scope': scope.map((item) => item.toJson()).toList(),
    };
  }

  // Helper function to convert date format from "DD/MM/YYYY" to "YYYY-MM-DD"
  /**static String _convertDateFormat(String date) {
    List<String> parts = date.split('/');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }**/

  // ✅ ADD THIS METHOD TO ALLOW UPDATING FIELDS
  Project copyWith({
    String? client,
    String? projectId,
    String? projectName,
    String? projectType,
    String? startDestination,
    String? endDestination,
    String? projectStatus,
    DateTime? startDate,
    String? emailsubjectheader,
    List<Stakeholder>? stakeholders,
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
        projectStatus: projectStatus ?? this.projectStatus,
        startDate: startDate ?? this.startDate,
        emailsubjectheader: emailsubjectheader ?? this.emailsubjectheader,
        stakeholders: stakeholders ?? this.stakeholders,
        cargo: cargo ?? this.cargo,
        scope: scope ?? this.scope,
      );
  }
}

class Stakeholder {
  final int userId;
  final String role;

  Stakeholder({
    required this.userId,
    required this.role,
  });

  factory Stakeholder.fromJson(Map<String, dynamic> json) {
    return Stakeholder(
      userId: int.parse(json['userId'].toString()),
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'role': role,
    };
  }
}


// Cargo Model
class Cargo {
  final String cargoname;
  final String length;
  final String breadth;
  final String height;
  final String weight;
  final String quantity;

  Cargo({
    required this.cargoname,
    required this.length,
    required this.breadth,
    required this.height,
    required this.weight,
    required this.quantity,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      cargoname: json['cargoname'],
      length: json['length'],
      breadth: json['breadth'],
      height: json['height'],
      weight: json['weight'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cargoname': cargoname,
      'length': length,
      'breadth': breadth,
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


