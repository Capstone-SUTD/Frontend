import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selectedPage;
  final Function(String)? onPageSelected;

  const Sidebar({
    Key? key,
    required this.selectedPage,
    this.onPageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isSmallScreen ? 60 : 80,
      color: theme.colorScheme.primary,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Navigation Icons
            Column(
              children: [
                const SizedBox(height: 20),
                _buildSidebarItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/dashboard',
                ),
                const SizedBox(height: 16),
                _buildSidebarItem(
                  context,
                  icon: Icons.list_alt,
                  label: 'Projects',
                  route: '/projects',
                ),
              ],
            ),

            // Bottom Navigation Icons
            Column(
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  route: '/profile',
                ),
                const SizedBox(height: 16),
                _buildSidebarItem(
                  context,
                  icon: Icons.logout,
                  label: 'Logout',
                  route: '/logout',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = selectedPage == route;
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Tooltip(
      message: label,
      preferBelow: false,
      verticalOffset: 20,
      child: InkWell(
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != route) {
            if (onPageSelected != null) {
              onPageSelected!(route);
            } else {
              Navigator.pushNamed(context, route);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: theme.colorScheme.secondary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 24 : 28,
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onPrimary,
              ),
              if (!isSmallScreen) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}