import 'package:flutter/material.dart';
import 'package:capstone_app/common/settings.dart';
import 'package:capstone_app/common/nav_bar.dart';
import 'dashboard_screen.dart';
import 'my_projects_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
        routes: {
        '/': (context) => const CargoDetailPage(),
        '/settings': (context) => SettingsScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/my-projects': (context) => MyProjectsList(),
      },
      home: const CargoDetailPage(),
    );
  }
}

class CargoDetailPage extends StatelessWidget {
  // ignore: use_super_parameters
  const CargoDetailPage({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Cargo Details',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    ),
    bottomNavigationBar: NavBar(currentIndex: 1), 
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cargo Name',
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          const Text(
            'Cargo ID: 12345',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Checklist',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '20% complete',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChecklistItem(
                  'Photo Verification',
                  Icons.camera_alt,
                  true,
                ),
                const SizedBox(width: 12),
                _buildChecklistItem(
                  'Remarks',
                  Icons.edit,
                  true,
                ),
                const SizedBox(width: 12),
                _buildChecklistItem(
                  'Verification',
                  Icons.check_circle_outline,
                  false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Project Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressTimeline(),
        ],
      ),
    ),
  );
}


  Widget _buildChecklistItem(String title, IconData icon, bool completed) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(title),
          const SizedBox(height: 4),
          Text(
            completed ? 'Completed' : 'Pending',
            style: TextStyle(
              color: completed ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineItem('Pending Project Manager Approval', true, false),
          _buildTimelineItem('MSRA Remarks Updated', true, true),
          _buildTimelineItem('MSRA Generated', true, true),
          _buildTimelineItem('Photo Verification Completed', true, true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, bool showLine, bool completed) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? Colors.green[700] : Colors.grey[300],
                ),
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: completed ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}