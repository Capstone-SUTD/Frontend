import 'package:flutter/material.dart';
import 'eq_reco_list.dart';
import 'my_projects_list.dart';
import 'new_project_form.dart';
import 'offsite_checklist_screen.dart';
//import 'package:capstone_app/common/main_screen.dart';
import 'cargo_detail_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: const Color.fromARGB(255, 7, 23, 114),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,          
          children: [
            const Text(
              'Welcome Back, User',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'HSE OFFICER • USER ID: 12345',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo[900],
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/profile_picture.png'),
                ),
                title: const Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                subtitle: const Text(
                  'HSE OFFICER • USER ID: 12345',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login_signup_screen');
                // Add logout logic here
              },
            ),
          ],
        ),
      ),
    
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        'title': 'Offsite Checklist',
        'icon': Icons.assignment,
        'page': OffsiteChecklistScreen(),
      },
      {
        'title': 'All Projects',
        'icon': Icons.folder,
        'page': MyProjectsList(),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((button) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CargoDetailPage()),
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
                  'Cargo ID: 12345567',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Expand MSRA',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // const Text(
            //   'Cargo ID: 12345567',
            //   style: TextStyle(color: Colors.grey),
            // ),
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
    const steps = ['Lifted', 'Loaded', 'Shipped', 'Arrived at Port'];
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
        const Text(
          'Recently Opened',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // const SizedBox(height: 16),
        // _buildSearchBar(),
        const SizedBox(height: 16),
        _buildRecentItem('Completed'),
        const SizedBox(height: 8),
        _buildRecentItem('In Progress'),
        const SizedBox(height: 8),
        _buildRecentItem('Arrived at Port'),
      ],
    );
  }

  // Widget _buildSearchBar() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[100],
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: const Row(
  //       children: [
  //         Icon(Icons.search, color: Colors.grey),
  //         SizedBox(width: 8),
  //         Expanded(
  //           child: TextField(
  //             decoration: InputDecoration(
  //               border: InputBorder.none,
  //               hintText: 'Search',
  //               hintStyle: TextStyle(color: Colors.grey),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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