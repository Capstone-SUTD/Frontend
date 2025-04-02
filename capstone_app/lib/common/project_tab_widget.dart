import 'package:flutter/material.dart';

class ProjectTabWidget extends StatelessWidget {
  final int selectedTabIndex;
  final Function(int) onTabSelected;

  const ProjectTabWidget({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTab(context, "Offsite Preparation", 0,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                )),
            _buildTab(context, "MS/RA Generation", 1),
            _buildTab(context, "Onsite Checklist", 2,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, int index,
      {BorderRadius? borderRadius}) {
    final isSelected = index == selectedTabIndex;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTabSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.transparent,
              borderRadius: borderRadius ?? BorderRadius.zero,
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
      ),
    );
  }
}
