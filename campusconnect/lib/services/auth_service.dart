import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String nom,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'nom': nom},
    );
    if (response.user == null) throw const AuthException('Inscription échouée');
    // Le trigger handle_new_user() crée automatiquement le profil dans public.users
    final model = await getCurrentUserModel();
    return model ??
        UserModel(
          id: response.user!.id,
          nom: nom,
          email: email,
          dateInscription: DateTime.now(),
        );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw const AuthException('Connexion échouée');
    final model = await getCurrentUserModel();
    return model ??
        UserModel(
          id: response.user!.id,
          nom: response.user!.email ?? '',
          email: response.user!.email ?? '',
          dateInscription: DateTime.now(),
        );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<UserModel?> getCurrentUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    final data = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({
    required String userId,
    required String nom,
    String? bio,
    String? filiere,
    File? photoFile,
    File? coverPhotoFile,
  }) async {
    String? photoUrl;
    if (photoFile != null) {
      final path = '$userId/avatar.jpg';
      await _client.storage.from('avatars').upload(
            path,
            photoFile,
            fileOptions: const FileOptions(upsert: true),
          );
      photoUrl = _client.storage.from('avatars').getPublicUrl(path);
    }

    String? coverPhotoUrl;
    if (coverPhotoFile != null) {
      final path = '$userId/cover.jpg';
      await _client.storage.from('avatars').upload(
            path,
            coverPhotoFile,
            fileOptions: const FileOptions(upsert: true),
          );
      coverPhotoUrl = _client.storage.from('avatars').getPublicUrl(path);
    }

    final updates = <String, dynamic>{
      'nom': nom,
      if (bio != null) 'bio': bio,
      if (filiere != null) 'filiere': filiere,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (coverPhotoUrl != null) 'cover_photo_url': coverPhotoUrl,
    };

    await _client.from('users').update(updates).eq('id', userId);
    final data =
        await _client.from('users').select().eq('id', userId).single();
    return UserModel.fromJson(data);
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<UserModel?> getUserById(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }
}
