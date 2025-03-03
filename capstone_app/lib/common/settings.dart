import 'package:flutter/material.dart';
import 'package:capstone_app/mobile_screens/dashboard_screen.dart';
import 'package:capstone_app/mobile_screens/cargo_detail_page.dart';
import 'package:capstone_app/common/nav_bar.dart';

class SettingsScreen extends StatelessWidget {  // ✅ Change class name if it's not 'Settings'
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      bottomNavigationBar: NavBar(currentIndex: 0),
      body: Center(child: Text("Settings Page")),
    );
  }
}
