import 'package:flutter/material.dart';
import 'package:capstone_app/common/main_screen.dart';

//import 'package:capstone_app/common/main_screen.dart'; 
// import 'dashboard_screen.dart';
// import 'package:capstone_app/common/settings.dart';
//import 'package:capstone_app/common/nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
  
    );
  }
}

class MyProjectsList extends StatelessWidget {
  final List<Map<String, dynamic>> projects = [
    {"status": "In Progress", "color": Colors.blue},
    {"status": "On Hold", "color": Colors.orange},
    {"status": "Completed", "color": Colors.green},
    {"status": "Completed", "color": Colors.green},
    {"status": "Completed", "color": Colors.green},
    {"status": "Completed", "color": Colors.green},
    {"status": "On Hold", "color": Colors.orange},
    {"status": "In Progress", "color": Colors.blue},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        leading: BackButton(color: Colors.white, onPressed: () {Navigator.pop(context);},
        ),

        title: const Text(
          'All Projects',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
            
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black), onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black), onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectCard(status: project["status"], color: project["color"]);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left), onPressed: () {},
                  //child: const Text('Previous'),
                ),
                const Text('Page 1 of 10'),
                IconButton(
                  icon: const Icon(Icons.chevron_right), onPressed: () {},
                  //child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String status;
  final Color color;

  const ProjectCard({Key? key, required this.status, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cargo Name',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text('Jakarta, IDN', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('23:45 12 Nov 2024', style:TextStyle(color:Colors.grey)),
                ],
              ),
              Container(
                padding:const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}