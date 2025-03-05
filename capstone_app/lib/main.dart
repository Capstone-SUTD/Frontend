import 'package:flutter/material.dart';
import 'package:capstone_app/common/splash_screen.dart';
import 'package:capstone_app/web_screens/all_project_screen.dart';
import 'package:capstone_app/web_screens/dashboard_screen.dart';
import 'web_screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capstone App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),  // Start with SplashScreen
      debugShowCheckedModeBanner: false,  // Remove debug banner
    );
  }
}