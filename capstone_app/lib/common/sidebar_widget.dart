import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_signup_screen.dart';
import '../screens/project_screen.dart';
import 'equipment_recommendation_widget.dart';

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

          // Navigation Items
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.list,
                  label: 'Dashboard',
                  route: '/projects',
                  isSelected: widget.selectedPage == '/projects',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.add,
                  label: 'New Project',
                  route: '',
                  isSelected: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProjectScreen(projectId: null),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.precision_manufacturing,
                  label: 'Equipment',
                  route: '',
                  isSelected: false,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const EquipmentRecommendationDialog(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button
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
        } else if (route.isEmpty) {
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

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginSignUpScreen()),
    );
  }
}


