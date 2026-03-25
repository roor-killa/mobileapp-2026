import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Flux temps réel des annonces ─────────────────────────────────────────
  Stream<List<AnnouncementModel>> getAnnouncements({String? categorie}) {
    late StreamController<List<AnnouncementModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      final userId = _client.auth.currentUser?.id;

      final List<Map<String, dynamic>> data;
      if (categorie != null && categorie != 'tous') {
        data = await _client
            .from('announcements_full')
            .select()
            .eq('categorie', categorie)
            .order('date_publication', ascending: false);
      } else {
        data = await _client
            .from('announcements_full')
            .select()
            .order('date_publication', ascending: false);
      }

      Set<String> favoriIds = {};
      if (userId != null) {
        final favorisData = await _client
            .from('announcement_favoris')
            .select('announcement_id')
            .eq('user_id', userId);
        favoriIds =
            favorisData.map((f) => f['announcement_id'] as String).toSet();
      }

      if (!controller.isClosed) {
        controller.add(data
            .map((d) => AnnouncementModel.fromJson(
                  d,
                  isFavori: favoriIds.contains(d['id'] as String),
                ))
            .toList());
      }
    }

    controller = StreamController<List<AnnouncementModel>>(
      onListen: () {
        fetch();
        channel = _client
            .channel('announcements-${categorie ?? 'all'}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'announcements',
              callback: (_) => fetch(),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'announcement_favoris',
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

  // ── Annonces de l'utilisateur courant ────────────────────────────────────
  Stream<List<AnnouncementModel>> getUserAnnouncements(String userId) {
    late StreamController<List<AnnouncementModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      final data = await _client
          .from('announcements_full')
          .select()
          .eq('user_id', userId)
          .order('date_publication', ascending: false);

      final favoriIds = await _client
          .from('announcement_favoris')
          .select('announcement_id')
          .eq('user_id', userId)
          .then((r) => r.map((f) => f['announcement_id'] as String).toSet());

      if (!controller.isClosed) {
        controller.add(data
            .map((d) => AnnouncementModel.fromJson(
                  d,
                  isFavori: favoriIds.contains(d['id'] as String),
                ))
            .toList());
      }
    }

    controller = StreamController<List<AnnouncementModel>>(
      onListen: () {
        fetch();
        channel = _client
            .channel('user-announcements-$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'announcements',
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

  // ── Créer une annonce ─────────────────────────────────────────────────────
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    await _client.from('announcements').insert(announcement.toMap());
  }

  // ── Supprimer une annonce ─────────────────────────────────────────────────
  Future<void> deleteAnnouncement(String id) async {
    await _client.from('announcements').delete().eq('id', id);
  }

  // ── Basculer le favori ────────────────────────────────────────────────────
  Future<void> toggleFavori(String announcementId, String userId) async {
    final existing = await _client
        .from('announcement_favoris')
        .select()
        .eq('announcement_id', announcementId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('announcement_favoris')
          .delete()
          .eq('announcement_id', announcementId)
          .eq('user_id', userId);
    } else {
      await _client.from('announcement_favoris').insert({
        'announcement_id': announcementId,
        'user_id': userId,
      });
    }
  }

  // ── Favoris de l'utilisateur ──────────────────────────────────────────────
  Stream<List<AnnouncementModel>> getFavoris(String userId) {
    late StreamController<List<AnnouncementModel>> controller;
    RealtimeChannel? channel;

    Future<void> fetch() async {
      final favoriIds = await _client
          .from('announcement_favoris')
          .select('announcement_id')
          .eq('user_id', userId)
          .then((r) => r.map((f) => f['announcement_id'] as String).toList());

      if (favoriIds.isEmpty) {
        if (!controller.isClosed) controller.add([]);
        return;
      }

      final data = await _client
          .from('announcements_full')
          .select()
          .inFilter('id', favoriIds)
          .order('date_publication', ascending: false);

      if (!controller.isClosed) {
        controller.add(data
            .map((d) => AnnouncementModel.fromJson(d, isFavori: true))
            .toList());
      }
    }

    controller = StreamController<List<AnnouncementModel>>(
      onListen: () {
        fetch();
        channel = _client
            .channel('favoris-$userId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'announcement_favoris',
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
}
