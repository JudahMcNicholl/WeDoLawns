import 'package:flutter/material.dart';

class LeftRightItem extends StatelessWidget {
  final String leftText;
  final String rightText;

  const LeftRightItem({
    super.key,
    required this.leftText,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftText,
        ),
        Text(
          rightText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
