import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String nom;
  final String? photoUrl;
  final double radius;
  final bool showBorder;

  const UserAvatar({
    super.key,
    required this.nom,
    this.photoUrl,
    this.radius = 20,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.7,
                ),
                child: Text(
                  _getInitials(nom),
                ),
              )
            : null,
      ),
    );
  }

  String _getInitials(String nom) {
    if (nom.isEmpty) return '?';
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nom[0].toUpperCase();
  }
}