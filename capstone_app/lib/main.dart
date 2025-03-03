import 'package:flutter/material.dart';
import 'package:capstone_app/mobile_screens/dashboard_screen.dart';
import 'package:capstone_app/common/settings.dart';
import 'package:capstone_app/mobile_screens/my_projects_list.dart';
import 'package:capstone_app/web_screens/all_project_screen.dart';
import 'package:capstone_app/web_screens/dashboard_screen.dart';
import 'web_screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      // title: 'Responsive App',
      // theme: ThemeData(
      //  primarySwatch: Colors.blue,
      //),
      //home: SplashScreen(),
      //routes: {
      //  '/dashboard': (context) => DashboardScreen(),
      //  '/projects': (context) => AllProjectsScreen(),
      //}
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