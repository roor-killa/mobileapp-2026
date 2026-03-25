import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'CampusConnect';
  static const String appTagline = 'La plateforme des étudiants de Martinique';

  // Announcement categories
  static const List<Map<String, dynamic>> categories = [
    {'id': 'cours', 'label': 'Cours', 'icon': Icons.school},
    {'id': 'covoiturage', 'label': 'Covoiturage', 'icon': Icons.directions_car},
    {'id': 'logement', 'label': 'Logement', 'icon': Icons.home},
    {'id': 'entraide', 'label': 'Entraide', 'icon': Icons.people},
    {'id': 'autre', 'label': 'Autre', 'icon': Icons.category},
  ];

  static IconData categoryIcon(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'icon': Icons.category},
    );
    return cat['icon'] as IconData;
  }

  static String categoryLabel(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'label': 'Autre'},
    );
    return cat['label'] as String;
  }

  static Color categoryColor(String categoryId) {
    switch (categoryId) {
      case 'cours':
        return Colors.blue;
      case 'covoiturage':
        return Colors.green;
      case 'logement':
        return Colors.orange;
      case 'entraide':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
