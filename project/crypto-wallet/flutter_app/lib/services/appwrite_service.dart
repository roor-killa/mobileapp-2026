import 'package:appwrite/appwrite.dart';
import '../config/appwrite_config.dart';

/// Client Appwrite partagé par l'app.
/// setLocale('fr') : les emails (vérification, Magic URL, etc.) utilisent le template français si configuré.
late final Client appwriteClient = Client()
    .setEndpoint(AppwriteConfig.endpoint)
    .setProject(AppwriteConfig.projectId)
    .setLocale('fr');

/// Service Account Appwrite pour l'authentification.
late final Account appwriteAccount = Account(appwriteClient);
