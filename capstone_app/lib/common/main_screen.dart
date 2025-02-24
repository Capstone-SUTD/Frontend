import 'package:flutter/material.dart';
import 'package:capstone_app/mobile_screens/dashboard_screen.dart';
import 'package:capstone_app/mobile_screens/my_projects_list.dart'; 
import 'settings.dart';
// import 'nav_bar.dart';
// import 'package:capstone_app/mobile_screens/cargo_detail_page.dart';
// import 'package:capstone_app/mobile_screens/new_project_form.dart';
// import 'package:capstone_app/mobile_screens/eq_reco_list.dart';
// import 'package:capstone_app/mobile_screens/offsite_checklist_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;
//   final List<Widget> _screens = [
//     DashboardScreen(),
//     //CargoDetailPage(),
//     //NewProjectForm(),
//     //EqRecoList(),
//     //OffsiteChecklistScreen(),
//     SettingsScreen(),
//     MyProjectsList(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: NavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> widgetOptions = [
    SettingsScreen(),
    DashboardScreen(),
    MyProjectsList(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.indigo,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'All Projects',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}