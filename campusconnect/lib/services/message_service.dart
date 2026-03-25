import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessageService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Flux temps réel des conversations ────────────────────────────────────
  // Utilise la vue conversations_with_other
  Stream<List<ConversationModel>> getConversations(String userId) {
    late StreamController<List<ConversationModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      final data = await _client
          .from('conversations_with_other')
          .select()
          .eq('my_user_id', userId)
          .order('dernier_message_date', ascending: false, nullsFirst: false);

      if (!controller.isClosed) {
        controller.add(
          data.map(ConversationModel.fromJson).toList(),
        );
      }
    }

    controller = StreamController<List<ConversationModel>>(
      onListen: () {
        fetch();
        channel = _client
            .channel('conversations-$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'conversations',
              callback: (_) => fetch(),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'messages',
              callback: (_) => fetch(),
            )
            .subscribe();
      },
      onCancel: () {
        if (channel != null) _client.removeChannel(channel!);
        controller.close();
      },
    );

    return controller.stream;
  }

  // ── Flux temps réel des messages d'une conversation ──────────────────────
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('timestamp')
        .map((data) => data.map(MessageModel.fromJson).toList());
  }

  // ── Obtenir ou créer une conversation entre deux utilisateurs ─────────────
  // Utilise la fonction SQL get_or_create_conversation()
  Future<String> getOrCreateConversation({
    required String userId1,
    required String nom1,
    required String userId2,
    required String nom2,
  }) async {
    final result = await _client.rpc('get_or_create_conversation', params: {
      'user1_id': userId1,
      'user2_id': userId2,
    });
    return result as String;
  }

  // ── Envoyer un message ────────────────────────────────────────────────────
  // Le trigger on_message_sent met à jour automatiquement dernier_message
  Future<void> sendMessage({
    required String conversationId,
    required String expediteurId,
    required String contenu,
  }) async {
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'expediteur_id': expediteurId,
      'contenu': contenu,
    });
  }
}
