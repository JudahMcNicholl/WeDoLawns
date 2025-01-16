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
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: ShapeDecoration(
                color: inProgressColor,
                shape: OvalBorder(),
              ),
            ),
            Text("In Progress")
          ],
        ),
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: ShapeDecoration(
                color: isNewColor,
                shape: OvalBorder(),
              ),
            ),
            Text("New")
          ],
        ),
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: ShapeDecoration(
                color: isCompletedColor,
                shape: OvalBorder(),
              ),
            ),
            Text("Complete")
          ],
        )
      ],
    );
  }
}
