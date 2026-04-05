import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/utils/supabase_config.dart';

void main() async {
  final url = Uri.parse(SupabaseConfig.url + '/rest/v1/');
  final response = await http.get(url, headers: {
    'apikey': SupabaseConfig.anonKey,
  });
  
  if (response.statusCode == 200) {
    final spec = jsonDecode(response.body);
    final definitions = spec['definitions'];
    final announcementsDef = definitions['announcements'] ?? definitions['announcements_full'];
    print("Announcements Table Definition:");
    print(jsonEncode(announcementsDef));
  } else {
    print("Failed to fetch schema: " + response.statusCode.toString() + " " + response.body);
  }
}
