/// Destination de navigation que le chatbot peut suggérer.
enum ChatDestination {
  announcements, // index 0
  events,        // index 1
  messages,      // index 2
  profile,       // index 3
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatDestination? destination;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.destination,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class BotResponse {
  final String text;
  final ChatDestination? destination;

  const BotResponse(this.text, {this.destination});
}

class ChatbotService {
  /// Simple rule-based logic to guide users to resources.
  Future<BotResponse> getBotResponse(String userMessage) async {
    // Simulate a slight network delay to make it feel natural
    await Future.delayed(const Duration(milliseconds: 1500));

    final msg = userMessage.toLowerCase();

    if (msg.contains('événement') || msg.contains('evenement') || msg.contains('fête')) {
      return const BotResponse(
        "Tu cherches des événements ? Voici l'onglet 'Événements' pour voir toutes les activités prévues sur le campus !",
        destination: ChatDestination.events,
      );
    } else if (msg.contains('annonce') || msg.contains('vendre') || msg.contains('acheter') || msg.contains('colocation')) {
      return const BotResponse(
        "Pour tout ce qui concerne les achats, ventes, ou colocations, voici l'onglet 'Annonces'. Tu pourras y trouver ce que proposent les autres étudiants ou publier ta propre offre.",
        destination: ChatDestination.announcements,
      );
    } else if (msg.contains('cours') || msg.contains('aide') || msg.contains('tutorat')) {
      return const BotResponse(
        "Besoin d'aide pour tes cours ? Tu peux poster une annonce dans la catégorie 'Entraide' ou vérifier si des séances de tutorat sont organisées en 'Événements'.",
        destination: ChatDestination.announcements,
      );
    } else if (msg.contains('message') || msg.contains('discuter') || msg.contains('contacter') || msg.contains('conversation')) {
      return const BotResponse(
        "Tu veux discuter avec quelqu'un ? Voici l'onglet 'Messages' pour retrouver tes conversations ou en commencer une nouvelle.",
        destination: ChatDestination.messages,
      );
    } else if (msg.contains('profil') || msg.contains('photo') || msg.contains('nom')) {
      return const BotResponse(
        "Tu peux modifier tes informations, ta photo de profil et ta couverture directement depuis l'onglet 'Profil'.",
        destination: ChatDestination.profile,
      );
    } else if (msg.contains('bonjour') || msg.contains('salut') || msg.contains('coucou')) {
      return const BotResponse(
        "Salut ! 😊 Je suis l'assistant CampusConnect. Comment puis-je t'aider aujourd'hui ? Tu cherches des événements, des annonces, ou autre chose ?",
      );
    } else if (msg.contains('merci')) {
      return const BotResponse(
        "Avec plaisir ! N'hésite pas si tu as d'autres questions.",
      );
    }

    // Default fallback
    return const BotResponse(
      "Je ne suis pas sûr de bien comprendre. Pourrais-tu reformuler ? Je peux t'aider à trouver des événements, des annonces, ou t'expliquer comment fonctionne l'application.",
    );
  }
}
