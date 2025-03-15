// import 'package:flutter/material.dart';
// // import 'package:capstone_app/mobile_screens/dashboard_screen.dart';
// // import 'package:capstone_app/mobile_screens/cargo_detail_page.dart';
// import 'main_screen.dart';
// //import 'nav_bar.dart';

// class SettingsScreen extends StatelessWidget {  // ✅ Change class name if it's not 'Settings'
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Settings")),
//     //   bottomNavigationBar: NavBar(
//     //     currentIndex: 1, 
//     //     onTap: (index) {
//     // // Handle navigation here
//     //   }
//     // ),
//       body: Center(child: Text("Settings Page")),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//         DrawerHeader(
//           decoration: BoxDecoration(
//             color: Colors.blue,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//           CircleAvatar(
//             radius: 40,
//             backgroundImage: AssetImage('assets/profile_picture.png'),
//           ),
//           SizedBox(height: 10),
//           Text(
//             'John Doe',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//             ),
//           ),
//           Text(
//             'john.doe@example.com',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//             ),
//           ),
//             ],
//           ),
//         ),
//         ListTile(
//           leading: Icon(Icons.settings),
//           title: Text('Settings'),
//           onTap: () {
//             Navigator.pop(context);
//           },
//         ),
//         ListTile(
//           leading: Icon(Icons.logout),
//           title: Text('Logout'),
//           onTap: () {
//             Navigator.pop(context);
//           },
//         ),
//           ],
//         ),
//       ),
//     );
//   }
// }
