import 'package:flutter/material.dart';
import 'eq_reco_list.dart';
import 'my_projects_list.dart';
import 'new_project_form.dart';
import 'offsite_checklist_screen.dart';
import 'package:capstone_app/common/settings.dart';
import 'package:capstone_app/common/nav_bar.dart'; 
import 'cargo_detail_page.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavBar(currentIndex: 1), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildNavigationButtons(context),
                const SizedBox(height: 24),
                _buildCurrentShipping(context),
                const SizedBox(height: 24),
                _buildRecentlyOpened(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  //   backgroundColor: Colors.blue[900],
  //   items: const [
  //     BottomNavigationBarItem(
  //       icon: Icon(Icons.account_circle, color: Colors.white),
  //       label: '',
  //     ),
  //     BottomNavigationBarItem(
  //       icon: Icon(Icons.home, color: Colors.white),
  //       label: '',
  //     ),
  //     BottomNavigationBarItem(
  //       icon: Icon(Icons.folder, color: Colors.white),
  //       label: '',
  //     ),
  //   ],
  //   selectedItemColor: Colors.white,
  //   unselectedItemColor: Colors.white54,
  // ),
  // );
  


  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome back, User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'HSE OFFICER • USER ID: 12345',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        )
  //       GestureDetector(
  //         onTap: () {
  //           Navigator.push( // you'll need to import SettingsScreen
  //           context,
  //           MaterialPageRoute(builder: (context) => SettingsScreen()),
  //           );
  //         },
  //         child: CircleAvatar(
  //           backgroundColor: Colors.grey[200],
  //           child: const Icon(Icons.person, color: Colors.grey),
  //         ),
  //       ),
  ],
  );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final buttons = [
      {
        'title': 'New Project',
        'icon': Icons.add,
        'page': NewProjectForm(), 
      },
      {
        'title': 'Equipment',
        'icon': Icons.build,
        'page': EqRecoList(), 
      },
      {
        'title': 'Add Work',
        'icon': Icons.work,
        'page': OffsiteChecklistScreen(), 
      },
      {
        'title': 'My Projects',
        'icon': Icons.folder,
        'page': MyProjectsList(), 
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((button) {
        return GestureDetector(
          onTap: () {
            Navigator.push( // you'll need to import these pages
            context,
            MaterialPageRoute(builder: (context) => button['page'] as Widget),
            );
          },
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 25,
                child: Icon(button['icon'] as IconData, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                button['title'] as String,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentShipping(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push( // you'll need to import CargoDetailPage
        context,
        MaterialPageRoute(builder: (context) => CargoDetailPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Shipping',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Expand',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Cargo Name • ID: 12345567',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildShippingProgress(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLocationInfo('10 Nov 2024', 'Jakarta, IDN'),
                _buildLocationInfo('20 Dec 2024', 'Singapore, SIN'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingProgress() {
    final steps = ['Lifted', 'Loaded', 'Shipped', 'Arrived at Port'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: steps.asMap().entries.map((entry) {
        final isCompleted = entry.key < 3;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: entry.key > 0
                        ? Divider(
                            color: isCompleted ? Colors.green : Colors.grey[300],
                            thickness: 1,
                          )
                        : Container(),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? Colors.green : Colors.grey[300],
                    ),
                  ),
                  Expanded(
                    child: entry.key < steps.length - 1
                        ? Divider(
                            color: entry.key < 2 ? Colors.green : Colors.grey[300],
                            thickness: 1,
                          )
                        : Container(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationInfo(String date, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyOpened() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recently Opened',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildRecentItem('Completed'),
        const SizedBox(height: 8),
        _buildRecentItem('In Progress'),
        const SizedBox(height: 8),
        _buildRecentItem('Arrived at Port'),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SENDER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Cargo Type',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'ID: 12345567',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
