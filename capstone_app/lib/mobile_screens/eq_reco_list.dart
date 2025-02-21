import 'package:flutter/material.dart';
import 'package:capstone_app/common/nav_bar.dart';
import 'dashboard_screen.dart';
import 'package:capstone_app/common/settings.dart';
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
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        '/': (context) => const EqRecoList(),
        '/dashboard': (context) => DashboardScreen(),
        '/settings': (context) => SettingsScreen(),
        '/my-projects': (context) => MyProjectsList(),
      },
      home: const EqRecoList(),
    );
  }
}

class EqRecoList extends StatelessWidget {
  const EqRecoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Equipment Recommendation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildEquipmentGroup(
              'Crane',
              [
                EquipmentItem('X Crane', 'Max capacity: x ton'),
                EquipmentItem('Y Crane', 'Max capacity: x ton'),
                EquipmentItem('Z Crane', 'Max capacity: x ton'),
              ],
            ),
            const SizedBox(height: 16),
            _buildEquipmentGroup(
              'Trailer Bed',
              [
                EquipmentItem('X Bed', 'Length: x metres'),
                EquipmentItem('Y Bed', 'Length: x metres'),
                EquipmentItem('Z Bed', 'Length: x metres'),
              ],
            ),
            const SizedBox(height: 16),
            _buildEquipmentGroup(
              'Flatbed Trailer',
              [
                EquipmentItem('A Flatbed', 'Length: x metres'),
                EquipmentItem('B Flatbed', 'Length: x metres'),
                EquipmentItem('C Flatbed', 'Length: x metres'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentGroup(String title, List<EquipmentItem> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items.map((item) => Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item.specification,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

class EquipmentItem {
  final String name;
  final String specification;

  EquipmentItem(this.name, this.specification);
}
