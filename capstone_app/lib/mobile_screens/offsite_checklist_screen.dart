import 'package:flutter/material.dart';
import 'package:capstone_app/common/nav_bar.dart';
import 'dashboard_screen.dart';
import 'my_projects_list.dart';
import 'package:capstone_app/common/settings.dart';

// ignore: use_key_in_widget_constructors
class OffsiteChecklistScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _OffsiteChecklistScreenState createState() => _OffsiteChecklistScreenState();
}
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offsite Checklist")),
    );
  }


class _OffsiteChecklistScreenState extends State<OffsiteChecklistScreen> {
  List<String> checklistItems = [
    "Review System Generated MS",
    "Fill In Lifting And Lashing Point",
    "Fill In Route Optimization",
    "Upload The Edited MS To System",
    "Confirm All Stakeholders Approved MS",
    "Confirm All Stakeholders Approved MS",
    "Confirm All Stakeholders Approved MS",
  ];

  List<bool> checkedItems = List.generate(7, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
          SizedBox(width: 10),
          Text(
            "Offsite Checklist",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    bottomNavigationBar: const NavBar(), 
    body: ListView.builder(
        itemCount: checklistItems.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(checklistItems[index]),
            value: checkedItems[index],
            onChanged: (bool? value) {
              setState(() {
                checkedItems[index] = value!;
              });
            },
          );
        },
      ),
    );
  }
}
