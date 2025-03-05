import 'package:flutter/material.dart';
import 'package:capstone_app/common/main_screen.dart';
import 'dashboard_screen.dart';
import 'my_projects_list.dart';
import 'package:capstone_app/common/settings.dart';
//import 'package:capstone_app/common/nav_bar.dart';

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
        backgroundColor: Colors.indigo[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
          SizedBox(width: 10),
          Text(
            "Offsite Checklist",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
    
    //bottomNavigationBar: NavBar(), 
    body: ListView.builder(
        itemCount: checklistItems.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(checklistItems[index]),
            activeColor: Colors.green,
            checkColor: Colors.white,
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
