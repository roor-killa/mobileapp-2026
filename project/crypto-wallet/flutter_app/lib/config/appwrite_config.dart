/// Configuration Appwrite pour l'authentification et la base de données.
/// Récupérez ces valeurs dans Appwrite Console → Settings / Databases.
class AppwriteConfig {
  /// URL de l'API Appwrite (ex: https://cloud.appwrite.io/v1)
  static const String endpoint = 'https://nyc.cloud.appwrite.io/v1';

  /// ID du projet Appwrite
  static const String projectId = '69b967ae000261f18de0';

  /// ID de la base de données NodEX (Console → Databases → NodEX)
  static const String databaseId = '69b96d910037a19096d6';

  /// ID de la table ondes (Console → Databases → ondes)
  static const String ondesTableId = 'ondes';

  /// URL de redirection pour Magic URL, "Mot de passe oublié" et OAuth.
  /// Sur le web : utilise l’origine courante + path (ex: http://localhost/app).
  /// Appwrite autorise localhost par défaut. Pour un domaine custom, ajoutez-le dans
  /// Appwrite Console → Auth → Settings → Platforms (Web app).
  static String get redirectUrl {
    try {
      final base = Uri.base;
      final origin = base.origin;
      if (origin.isEmpty) return 'http://127.0.0.1/app';
      // Si on est dans /app/, inclure le path pour les redirections
      final path = base.path;
      if (path.startsWith('/app')) return '$origin$path'.replaceAll(RegExp(r'/$'), '');
      return origin;
    } catch (_) {}
    return 'http://127.0.0.1/app';
  }

  /// URL pour le lien de vérification email (inscription).
  static String get verificationRedirectUrl {
    final base = redirectUrl.endsWith('/') ? redirectUrl : '$redirectUrl/';
    return '${base}verify-email';
  }
}
