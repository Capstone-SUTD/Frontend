// import 'package:flutter/material.dart';

// class NavBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const NavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

//   @override
//   _NavBarState createState() => _NavBarState();
// }

// class _NavBarState extends State<NavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: widget.currentIndex,
//       onTap: widget.onTap,
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.account_circle),
//           label: 'Profile',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.folder),
//           label: 'All Projects',
//         ),
//       ],
//     );
//   }
// }
