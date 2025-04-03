import 'package:capstone_app/screens/all_project_screen.dart';
import 'package:capstone_app/screens/dashboard_screen.dart';
import 'package:capstone_app/screens/web_splash_screen.dart';
import 'package:flutter/material.dart';

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
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
          cardColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: WebSplashScreen(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/projects': (context) => AllProjectsScreen(),
      },
    );
  }
}
