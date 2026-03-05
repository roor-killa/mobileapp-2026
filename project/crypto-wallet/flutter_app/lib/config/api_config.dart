import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _override = '';
  static String get baseUrl => _override.isNotEmpty ? _override : 'http://localhost:3000';
}
