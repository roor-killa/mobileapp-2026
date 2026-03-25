import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Flux temps réel de tous les événements ────────────────────────────────
  Stream<List<EventModel>> getEvents() {
    late StreamController<List<EventModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      final userId = _client.auth.currentUser?.id;

      final data = await _client
          .from('events_full')
          .select()
          .order('date', ascending: true);

      Set<String> participatingIds = {};
      if (userId != null) {
        final participData = await _client
            .from('event_participants')
            .select('event_id')
            .eq('user_id', userId);
        participatingIds =
            participData.map((p) => p['event_id'] as String).toSet();
      }

      if (!controller.isClosed) {
        controller.add(data
            .map((d) => EventModel.fromJson(
                  d,
                  isParticipant:
                      participatingIds.contains(d['id'] as String),
                ))
            .toList());
      }
    }

    controller = StreamController<List<EventModel>>(
      onListen: () {
        fetch();
        channel = _client
            .channel('events-all')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'events',
              callback: (_) => fetch(),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'event_participants',
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

  // ── Événements à venir ────────────────────────────────────────────────────
  Stream<List<EventModel>> getUpcomingEvents() {
    late StreamController<List<EventModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      final userId = _client.auth.currentUser?.id;
      final now = DateTime.now().toIso8601String();

      final data = await _client
          .from('events_full')
          .select()
          .gte('date', now)
          .order('date', ascending: true);

      Set<String> participatingIds = {};
      if (userId != null) {
        final participData = await _client
            .from('event_participants')
            .select('event_id')
            .eq('user_id', userId);
        participatingIds =
            participData.map((p) => p['event_id'] as String).toSet();
      }

      if (!controller.isClosed) {
        controller.add(data
            .map((d) => EventModel.fromJson(
                  d,
                  isParticipant:
                      participatingIds.contains(d['id'] as String),
                ))
            .toList());
      }
    }

    controller = StreamController<List<EventModel>>(
      onListen: () {
        fetch();
        channel = _client
            .channel('events-upcoming')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'events',
              callback: (_) => fetch(),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'event_participants',
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

  // ── Créer un événement ────────────────────────────────────────────────────
  Future<void> createEvent(EventModel event) async {
    await _client.from('events').insert(event.toMap());
  }

  // ── Supprimer un événement ────────────────────────────────────────────────
  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }

  // ── Rejoindre un événement ────────────────────────────────────────────────
  Future<void> rejoindreEvent(String eventId, String userId) async {
    await _client.from('event_participants').insert({
      'event_id': eventId,
      'user_id': userId,
    });
  }

  // ── Quitter un événement ──────────────────────────────────────────────────
  Future<void> quitterEvent(String eventId, String userId) async {
    await _client
        .from('event_participants')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }
}
