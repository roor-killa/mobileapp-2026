import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/utils/supabase_config.dart';
import 'dart:io';

Future<void> main() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  final client = Supabase.instance.client;
  
  try {
    // We cannot insert unless we are authenticated. We'd have to sign in first.
    // Assuming there's a test user or we can just try to sign up/sign in a dummy user
    final authRes = await client.auth.signUp(email: 'testagent1@test.com', password: 'password123', data: {'nom':'Test Agent'});
    final user = authRes.user;
    
    if (user != null) {
      print("Signed in as \${user.id}");
      
      try {
        await client.from('announcements').insert({
          'titre': 'Test',
          'description': 'Test Desc',
          'categorie': 'cours',
          'user_id': user.id,
        });
        print("Insert SUCCESS without date_publication!");
      } catch (e) {
        print("Insert Failed without date_publication: \$e");
      }
      
      try {
        await client.from('announcements').insert({
          'titre': 'Test 2',
          'description': 'Test Desc',
          'categorie': 'cours',
          'user_id': user.id,
          'date_publication': DateTime.now().toUtc().toIso8601String(),
        });
        print("Insert SUCCESS with date_publication!");
      } catch (e) {
        print("Insert Failed with date_publication: \$e");
      }
      
    }
  } catch (e) {
    print("Auth Error: \$e");
  }
  exit(0);
}
