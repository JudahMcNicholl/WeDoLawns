import 'package:flutter/material.dart';
import 'package:wedolawns/utils/constants.dart';

class ColorKeyWidget extends StatelessWidget {
  final bool inProgress;
  final bool isNew;
  final bool isComplete;

  const ColorKeyWidget({
    super.key,
    this.inProgress = false,
    this.isComplete = false,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centers the Row horizontally
      crossAxisAlignment: CrossAxisAlignment.center, // Centers the children vertically
      children: [
        _buildColorKeyItem(isActive: inProgress, color: inProgressColor, label: "In Progress"),
        _buildColorKeyItem(isActive: isNew, color: isNewColor, label: "New"),
        _buildColorKeyItem(isActive: isComplete, color: isCompletedColor, label: "Complete"),
      ],
    );
  }

  Widget _buildColorKeyItem({required bool isActive, required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adds spacing between items
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: ShapeDecoration(
              color: isActive ? color : color.withOpacity(0.3), // Dim the color if not active
              shape: OvalBorder(),
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? null : Colors.grey, // Dim the text if not active
            ),
          ),
        ],
      ),
    );
  }
}
