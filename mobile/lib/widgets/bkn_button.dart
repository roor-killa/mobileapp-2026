import 'package:flutter/material.dart';

class BknButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BknButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
