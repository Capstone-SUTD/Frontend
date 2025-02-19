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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'My Projects',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min, // Fixes layout issue
                children: [
                  Text('ONSITE', style: TextStyle(color: Colors.black)),
                  Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildCargoItem(
            'Cargo Name',
            '12345567',
            'Jakarta, IDN',
            '23:45 12 Nov 2024',
            status: CargoStatus.pending,
          ),
          const Divider(height: 1),
          _buildCargoItem(
            'Cargo Name',
            '12345567',
            'Jakarta, IDN',
            '23:45 10 Nov 2024',
            status: CargoStatus.completed,
          ),
          const Divider(height: 1),
          _buildCargoItem(
            'Cargo Name',
            '12345567',
            'Jakarta, IDN',
            '23:45 10 Nov 2024',
            status: CargoStatus.completed,
          ),
          const Divider(height: 1),
          _buildCargoItem(
            'Cargo Name',
            '12345567',
            'Jakarta, IDN',
            '23:45 10 Nov 2024',
            status: CargoStatus.completed,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildCargoItem(
    String name,
    String id,
    String location,
    String datetime, {
    required CargoStatus status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $id',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datetime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusIcon(status),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(CargoStatus status) {
    switch (status) {
      case CargoStatus.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        );
      case CargoStatus.pending:
        return SizedBox(
          width: 24,
          height: 24,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
    }
  }
}

enum CargoStatus {
  completed,
  pending,
}
