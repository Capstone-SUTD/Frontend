import 'package:flutter/material.dart';

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
        primarySwatch: Colors.blueGrey, // Changed from Colors.grey
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyProjectsList(),
    );
  }
}

class MyProjectsList extends StatelessWidget {
  const MyProjectsList({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('My Projects',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      
    ),
    body: ListView.builder(
      itemCount: 4, // Example count of items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cargo Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Jakarta, IDN',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ID: 12345567',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    '23:45 12 Nov 2024',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Right Column (Progress Tick)
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ],
          ),
        );
      },
    ),
  );
}
}

enum CargoStatus {
  completed,
  pending,
}
