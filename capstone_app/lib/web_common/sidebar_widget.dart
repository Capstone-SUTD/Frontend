import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selectedPage;

  const Sidebar({Key? key, required this.selectedPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.blue.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures top, middle, and bottom spacing
        children: [
          // Empty Spacer for top padding
          SizedBox(height: 20),

          // Middle Icons (Home & Projects)
          Column(
            children: [
              _buildSidebarIcon(
                  context, Icons.home, "/dashboard", selectedPage == "/dashboard"),
              SizedBox(height: 20),
              _buildSidebarIcon(
                  context, Icons.list, "/projects", selectedPage == "/projects"),
            ],
          ),

          // Bottom Icons (User & Logout)
          Column(
            children: [
              _buildSidebarIcon(
                  context, Icons.person, "/profile", selectedPage == "/profile"),
              SizedBox(height: 20),
              _buildSidebarIcon(
                  context, Icons.logout, "/logout", selectedPage == "/logout"),
              SizedBox(height: 20), // Extra padding at bottom
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Helper function to create a Sidebar Icon
  Widget _buildSidebarIcon(BuildContext context, IconData icon, String route, bool isSelected) {
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.orange : Colors.white),
      onPressed: () {
        if (ModalRoute.of(context)!.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}


