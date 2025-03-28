// import 'package:flutter/material.dart';
// import 'msra.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Onsite Checklist',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const OnsiteChecklistScreen(),
//     );
//   }
// }

// class OnsiteChecklistScreen extends StatefulWidget {
//   const OnsiteChecklistScreen({Key? key}) : super(key: key);

//   @override
//   _OnsiteChecklistScreenState createState() => _OnsiteChecklistScreenState();
// }

// class _OnsiteChecklistScreenState extends State<OnsiteChecklistScreen> {
//   // List of titles, their checkbox states, and checklist items
//   final List<Map<String, dynamic>> _titles = [
//     {
//       "title": "Forklift",
//       "checked": false,
//       "items": [
//         "Check tires",
//         "Inspect brakes",
//         "Test horn",
//       ],
//     },
//     {
//       "title": "Crane",
//       "checked": false,
//       "items": [
//         "Inspect cables",
//         "Check hydraulic system",
//         "Test controls",
//       ],
//     },
//     {
//       "title": "Scaffolding",
//       "checked": false,
//       "items": [
//         "Check stability",
//         "Inspect platforms",
//         "Verify guardrails",
//       ],
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Onsite Checklist"),
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: _titles.map((title) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // **Title with Checkbox**
//                 TitleWithCheckbox(
//                   title: title["title"],
//                   value: title["checked"],
//                   onChanged: (bool? value) {
//                     setState(() {
//                       title["checked"] = value ?? false;
//                     });
//                   },
//                 ),

//                 // **Checklist Items Dropdown**
//                 ExpansionTile(
//                   title: const Text(
//                     "Checklist Items",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   children: title["items"].map<Widget>((item) {
//                     return ListTile(
//                       title: Text(item),
//                     );
//                   }).toList(),
//                 ),

//                 const SizedBox(height: 16), // Spacing between sections
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

// // Reusable Widget for Title with Checkbox
// class TitleWithCheckbox extends StatelessWidget {
//   final String title;
//   final bool value;
//   final ValueChanged<bool?> onChanged;

//   const TitleWithCheckbox({
//     Key? key,
//     required this.title,
//     required this.value,
//     required this.onChanged,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns items to the edges
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         Checkbox(
//           value: value,
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }
// }