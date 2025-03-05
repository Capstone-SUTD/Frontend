import 'package:flutter/material.dart';

class ProjectTabWidget extends StatelessWidget {
  final int selectedTabIndex;
  final Function(int) onTabSelected; // Callback function

  const ProjectTabWidget({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab(context, "Offsite Preparation", 0),
        _buildTab(context, "MS/RA Generation", 1),
        _buildTab(context, "Onsite Checklist", 2),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String title, int index) {
    bool isSelected = index == selectedTabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index), // Pass index back to ProjectScreen
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}







