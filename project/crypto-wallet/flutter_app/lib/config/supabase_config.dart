class SupabaseConfig {
  static const String url = 'https://thrhalhegtlhmjzjhesj.supabase.co';
  static const String anonKey = 'sb_publishable_8zHy1NXe4xwvrtOqcOYpew_B3G6YOUz';

  /// URL de redirection pour "Mot de passe oublié".
  /// IMPORTANT : Ajoutez cette URL dans Supabase Dashboard → Authentication → URL Configuration → Redirect URLs.
  /// Ex: http://localhost:52873 (le port varie selon Flutter web - affiché au lancement).
  static String get passwordResetRedirectUrl {
    try {
      return Uri.base.origin;
    } catch (_) {
      return 'http://localhost:3000';
    }
  }
}
