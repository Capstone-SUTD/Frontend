// main.dart

import 'package:flutter/material.dart';
import 'package:capstone_app/mobile_screens/dashboard_screen.dart';
import 'package:capstone_app/common/settings.dart';
import 'package:capstone_app/mobile_screens/my_projects_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {
        '/settings': (context) => SettingsScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/my-projects': (context) => MyProjectsList(),
      },
    );
  }
}