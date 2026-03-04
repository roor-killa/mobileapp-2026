import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/user.dart';

SupabaseClient get sb => Supabase.instance.client;

class SupabaseService {

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required double initialBalance,
  }) async {
    final res = await sb.auth.signUp(email: email, password: password);
    final uid = res.user?.id;
    if (uid == null) throw Exception('Inscription échouée.');

    await sb.from('profiles').insert({
      'id': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    });

    await sb.from('accounts').insert({
      'owner_id': uid,
      'label': 'Compte principal',
      'balance': initialBalance,
      'account_number': _generateAccountNumber(),
    });
  }

  static Future<void> login(String email, String password) async {
    await sb.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    await sb.auth.signOut();
  }

  static String get currentUserId => sb.auth.currentUser!.id;

  // ── Profil ────────────────────────────────────────────────────────────────

  static Future<UserModel> getMyProfile() async {
    final row = await sb
        .from('profiles')
        .select()
        .eq('id', currentUserId)
        .single();
    return UserModel.fromJson(row);
  }

  // ── Comptes ───────────────────────────────────────────────────────────────

  static Future<List<AccountModel>> getMyAccounts() async {
    final rows = await sb
        .from('accounts')
        .select('*, profiles!owner_id(first_name, last_name)')
        .eq('owner_id', currentUserId)
        .order('created_at');

    return rows.map<AccountModel>((r) {
      final p = r['profiles'] as Map<String, dynamic>?;
      final name = p != null ? '${p['first_name']} ${p['last_name']}' : '';
      return AccountModel.fromJson({...r, 'owner_name': name});
    }).toList();
  }

  static Future<AccountModel> createAccount(String label, double initialBalance) async {
    final profile = await getMyProfile();
    final row = await sb.from('accounts').insert({
      'owner_id': currentUserId,
      'label': label,
      'balance': initialBalance,
      'account_number': _generateAccountNumber(),
    }).select().single();
    return AccountModel.fromJson({...row, 'owner_name': profile.fullName});
  }

  // ── Virement ─────────────────────────────────────────────────────────────

  static Future<TransactionModel> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? note,
  }) async {
    await sb.rpc('do_transfer', params: {
      'p_from_account_id': fromAccountId,
      'p_to_account_id': toAccountId,
      'p_amount': amount,
      'p_note': note,
    });

    // Récupère la transaction fraîchement créée
    final txRow = await sb
        .from('transactions')
        .select()
        .eq('from_account_id', fromAccountId)
        .order('created_at', ascending: false)
        .limit(1)
        .single();

    return TransactionModel.fromJson(txRow);
  }

  // ── Historique ────────────────────────────────────────────────────────────

  static Future<List<TransactionModel>> getHistory() async {
    final accountRows = await sb
        .from('accounts')
        .select('id')
        .eq('owner_id', currentUserId);

    final ids = (accountRows as List).map((r) => r['id'] as String).toList();
    if (ids.isEmpty) return [];

    final rows = await sb
        .from('transactions')
        .select()
        .or('from_account_id.in.(${ids.join(',')}),to_account_id.in.(${ids.join(',')})')
        .order('created_at', ascending: false);

    // ✅ CORRIGÉ : fromJson est synchrone, pas de Future.wait nécessaire
    return rows.map<TransactionModel>((r) => TransactionModel.fromJson(r)).toList();
  }

  static Future<List<TransactionModel>> getAccountTransactions(String accountId) async {
    final rows = await sb
        .from('transactions')
        .select()
        .or('from_account_id.eq.$accountId,to_account_id.eq.$accountId')
        .order('created_at', ascending: false);

    return rows.map<TransactionModel>((r) => TransactionModel.fromJson(r)).toList();
  }

  // ── Recherche ─────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().length < 2) return [];
    final q = query.trim().toLowerCase();

    final profiles = await sb
        .from('profiles')
        .select('id, first_name, last_name, email')
        .neq('id', currentUserId)
        .or('first_name.ilike.%$q%,last_name.ilike.%$q%,email.ilike.%$q%')
        .limit(20);

    final List<Map<String, dynamic>> results = [];
    for (final p in profiles) {
      final accounts = await sb
          .from('accounts')
          .select('id, account_number, label, balance, owner_id')
          .eq('owner_id', p['id'] as String);

      final fullName = '${p['first_name']} ${p['last_name']}';
      results.add({
        'user_id': p['id'],
        'full_name': fullName,
        'email': p['email'],
        'accounts': (accounts as List).map((a) => {...a, 'owner_name': fullName}).toList(),
      });
    }
    return results;
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static String _generateAccountNumber() {
    final n = DateTime.now().millisecondsSinceEpoch % 100000000;
    return 'FR76-${n.toString().padLeft(8, '0')}';
  }

  static Future<Object?> getChatMessages(String city) async {
    return null;
  }

  static Future<void> saveChatMessage({required String content, required bool isUser, required String city}) async {}
}