import 'package:flutter/material.dart';
import 'eq_reco_list.dart';
import 'my_projects_list.dart';
import 'new_project_form.dart';
import 'offsite_checklist_screen.dart';

//import 'project_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

// ignore: use_key_in_widget_constructors
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 0, 0),
        elevation: 0,
        title: Text("Welcome back, User", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        //actions: [
          //ElevatedButton(
            //onPressed: () {},
            //style: ElevatedButton.styleFrom(
              //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              //backgroundColor: Colors.grey[300],
              //padding: EdgeInsets.symmetric(horizontal: 15),
            //),
            //child: Text("ONSITE", style: TextStyle(color: Colors.black)),
          //),
          //SizedBox(width: 10),
        //],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("HSE OFFICER • USER ID: 12345", style: TextStyle(color: Colors.black)),
              SizedBox(height: 20),

              // Top Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navButton(context, "New Project", NewProjectForm()),
                  _navButton(context, "Equipment", EqRecoList()),
                  _navButton(context, "Offsite Checklist", OffsiteChecklistScreen()),
                  _navButton(context, "My Projects", MyProjectsList()),
                ],
              ),
              SizedBox(height: 20),

              // Current Shipping Section
              _shippingSection(),

              SizedBox(height: 20),

              // Recently Opened Section
              _recentlyOpenedSection(),
            ],
          ),
        ),
      ),
    );
  }


  // Function to create Navigation Buttons
   Widget _navButton(BuildContext context, String title, Widget? targetScreen) {
    return GestureDetector(
      onTap: () {
        if (targetScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(radius: 20, backgroundColor: Colors.grey[400]),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }


  // Current Shipping Section
  Widget _shippingSection() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Current Shipping", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              //Text("Expand", style: TextStyle(color: Colors.blue)),
            ],
          ),
          SizedBox(height: 5),
          Text("Cargo Name • ID: 12345567", style: TextStyle(color: Colors.black)),
          SizedBox(height: 10),
          _shippingProgressBar(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("10 Nov 2024", style: TextStyle(color: Colors.black)),
                  Text("Jakarta, IDN", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("20 Dec 2024", style: TextStyle(color: Colors.black)),
                  Text("Singapore, SIN", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Shipping Progress Bar
  Widget _shippingProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _progressCircle(true),
        _progressCircle(true),
        _progressCircle(true),
        _progressCircle(false),
      ],
    );
  }

  Widget _progressCircle(bool isCompleted) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  // Recently Opened Section
  Widget _recentlyOpenedSection() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recently Opened", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("See All", style: TextStyle(color: Colors.blue)),
            ],
          ),
          SizedBox(height: 10),
          _searchBar(),
          SizedBox(height: 10),
          _recentListItem("In Progress"),
          _recentListItem("In Progress"),
          _recentListItem("Completed"),
        ],
      ),
    );
  }

  // Search Bar
  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none, hintText: "Search"),
            ),
          ),
          Icon(Icons.search, color: Colors.grey),
        ],
      ),
    );
  }

  // Recently Opened List Item
  Widget _recentListItem(String status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SENDER", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Cargo Type", style: TextStyle(color: Colors.black)),
              Text("ID: 12345567", style: TextStyle(color: Colors.black)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(status, style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
