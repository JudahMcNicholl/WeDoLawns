import 'package:flutter/material.dart';

Color inProgressColor = Color(0xFF62B6CB);
Color isCompletedColor = Color(0xFF236002);
Color isNewColor = Color(0xFF8F9563);

Color inProgressColorOpaque = Color(0x3862B6CB);
Color isCompletedColorOpaque = Color(0xFFCBD9C3);
Color isNewColorOpaque = Color(0x358F9563);

final List<Map<String, dynamic>> tools = [
  {'icon': Icons.grass, 'label': 'Chainsaw', 'isActive': false},
  {'icon': Icons.grass, 'label': 'Hedgetrimmer', 'isActive': false},
  {'icon': Icons.grass, 'label': 'Lawnmower', 'isActive': false},
];
