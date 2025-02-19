import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:capstone_app/screens/dashboard_screen.dart';  // ✅ Change import path if it's not 'screens/settings.dart'

class SettingsScreen extends StatelessWidget {  // ✅ Change class name if it's not 'Settings'
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Center(child: Text("Settings Page")),
    );
  }
}
