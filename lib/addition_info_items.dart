import 'package:flutter/material.dart';

class AdditionInfoItems extends StatelessWidget {
  final String title, temp;
  final IconData iconData;

  const AdditionInfoItems({
    super.key,
    required this.title,
    required this.temp,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          iconData,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(title),
        const SizedBox(height: 8),
        Text(
          temp,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
