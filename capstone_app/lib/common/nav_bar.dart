import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  
  const NavBar({
    Key? key, 
    this.currentIndex = 1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'My Projects',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue[700],
      onTap: (index) {
        if (index != currentIndex) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/dashboard-screen');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/my-projects-list');
              break;
          }
        }
      },
    );
  }
}