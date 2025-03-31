import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/login_signup_screen.dart';

class Sidebar extends StatefulWidget {
  final String selectedPage;

  const Sidebar({Key? key, required this.selectedPage}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = isExpanded ? 200 : 70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      color: Colors.blue.shade900,
      child: Column(
        children: [
          // Top Toggle Button
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                isExpanded ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),

          // Navigation Items (flush to top)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.list,
                  label: 'Projects',
                  route: '/projects',
                  isSelected: widget.selectedPage == '/projects',
                ),
                // Add more nav items here if needed
              ],
            ),
          ),

          // Logout Button (pinned to bottom)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildNavItem(
              context,
              icon: Icons.logout,
              label: 'Logout',
              route: '/logout',
              isSelected: false,
              onTap: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build nav item row
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
    Function? onTap,
  }) {
    return InkWell(
      onTap: () {
        if (route == '/logout') {
          if (onTap != null) onTap();
        } else if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        color: isSelected ? Colors.blue.shade700 : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle logout logic
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginSignUpScreen()),
    );
  }
}
