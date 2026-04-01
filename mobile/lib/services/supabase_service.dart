import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/tx.dart';

class SupabaseService {
  SupabaseClient get _db => Supabase.instance.client;

  Future<void> _ensureOwnProfileRow({
    String nom = '',
    String prenom = '',
    String telephone = '',
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');

    await _db.from('profiles').upsert({
      'id': uid,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    });
  }

  Future<void> _ensureWalletRow({
    String? userId,
    double initialBalance = AppConfig.initialBalanceBkn,
  }) async {
    final uid = (userId ?? currentUserId)?.trim();
    if (uid == null || uid.isEmpty) throw Exception('Not logged in');

    final existing = await _db
        .from('wallets')
        .select('user_id, balance_bkn')
        .eq('user_id', uid)
        .maybeSingle();

    if (existing == null) {
      await _db.from('wallets').upsert({
        'user_id': uid,
        'balance_bkn': initialBalance,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Exception _backendException(
    String action,
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is SocketException || error is HttpException) {
      return Exception(
        '$action impossible: backend Stripe injoignable sur ${AppConfig.stripeBackendBaseUrl}. '
        'Si tu testes sur un vrai téléphone, lance l\'app avec '
        '--dart-define=STRIPE_BACKEND_BASE_URL=http://IP_DE_TON_PC:4000.',
      );
    }

    return Exception('$action impossible: $error');
  }

  // AUTH
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final res = await _db.auth.signUp(email: email, password: password);

    final uid = res.user?.id;
    if (uid != null) {
      await _db.from('profiles').upsert({
        'id': uid,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
      });

      await _db.from('wallets').upsert({
        'user_id': uid,
        'balance_bkn': AppConfig.initialBalanceBkn,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _db.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _db.auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    await _db.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _db.auth.updateUser(UserAttributes(password: newPassword));
  }

  String? get currentUserId => _db.auth.currentUser?.id;
  String? get currentEmail => _db.auth.currentUser?.email;
  String? get currentUserEmail => _db.auth.currentUser?.email;

  // PROFILE
  Future<Map<String, dynamic>> getProfile() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');

    final row = await _db
        .from('profiles')
        .select('id, nom, prenom, telephone, wallet_address')
        .eq('id', uid)
        .maybeSingle();

    if (row != null) {
      return (row as Map).cast<String, dynamic>();
    }

    await _ensureOwnProfileRow();

    return {
      'id': uid,
      'nom': '',
      'prenom': '',
      'telephone': '',
      'wallet_address': null,
    };
  }

  Future<void> updateProfile({
    required String nom,
    required String prenom,
    required String telephone,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');
    await _db.from('profiles').upsert({
      'id': uid,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
    });
  }

  // ==========================
  // On-chain wallet (EVM) data
  // ==========================
  Future<String?> getMyWalletAddress() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final row = await _db
        .from('profiles')
        .select('wallet_address')
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    final v = row['wallet_address']?.toString().trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<String?> getWalletAddressByUserId(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) return null;
    final row = await _db
        .from('profiles')
        .select('wallet_address')
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    final v = row['wallet_address']?.toString().trim();
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> updateMyWalletAddress(String? walletAddress) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');
    final v = walletAddress?.trim();
    await _db.from('profiles').upsert({
      'id': uid,
      'wallet_address': (v == null || v.isEmpty) ? null : v,
    });
  }

  Future<void> saveOnchainTx({
    required String? fromUserId,
    required String? toUserId,
    required String fromWallet,
    required String toWallet,
    required double amount,
    required String chain,
    required String tokenAddress,
    required String txHash,
    String status = 'PENDING',
  }) async {
    await _db.from('onchain_transactions').insert({
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'from_wallet': fromWallet,
      'to_wallet': toWallet,
      'amount': amount,
      'chain': chain,
      'token_address': tokenAddress,
      'tx_hash': txHash,
      'status': status,
    });
  }

  // WALLET
  Future<double> getBalance() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');

    final row = await _db
        .from('wallets')
        .select('balance_bkn')
        .eq('user_id', uid)
        .maybeSingle();

    if (row == null) {
      await _ensureWalletRow(userId: uid);
      return AppConfig.initialBalanceBkn;
    }

    return ((row['balance_bkn'] as num?) ?? AppConfig.initialBalanceBkn)
        .toDouble();
  }

  // TRANSACTIONS
  Future<List<Tx>> getTransactions() async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');
    final rows = await _db
        .from('transactions')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(50);

    return (rows as List)
        .map((e) => Tx.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> transferToUserId({
    required String toUserId,
    required double amount,
  }) async {
    final raw = await _db.rpc(
      'transfer_bkn',
      params: {'p_to': toUserId, 'p_amount': amount},
    );

    final Map<String, dynamic> map = (raw is Map)
        ? Map<String, dynamic>.from(raw as Map)
        : <String, dynamic>{};

    final bool ok = map['success'] == true || map['ok'] == true || raw == null;

    final String msg = (map['message'] ?? map['error'] ?? (ok ? 'OK' : 'NOK'))
        .toString();

    return {'success': ok, 'message': msg, ...map};
  }

  Future<String?> userIdByEmail(String email) async {
    final res = await _db.rpc(
      'user_id_by_email',
      params: {'p_email': email.trim().toLowerCase()},
    );
    return res?.toString();
  }

  Future<List<Map<String, dynamic>>> searchUsersByName(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];

    final rows = await _db
        .from('profiles')
        .select('id, nom, prenom, telephone, wallet_address')
        .or('nom.ilike.%$q%,prenom.ilike.%$q%')
        .limit(5);

    return (rows as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }

  Future<Map<String, dynamic>?> getPublicProfileByUserId(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) return null;

    final rows = await _db
        .from('profiles')
        .select('id, nom, prenom, telephone, wallet_address')
        .eq('id', uid)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return (rows.first as Map).cast<String, dynamic>();
  }

  // STRIPE (Checkout Session)
  Future<Map<String, String>> createCheckoutSession({
    required double amountBkn,
  }) async {
    final uid = currentUserId;
    final email = currentUserEmail;
    if (uid == null || email == null) throw Exception('Not logged in');

    final uri = Uri.parse(
      '${AppConfig.stripeBackendBaseUrl}/create-checkout-session',
    );

    try {
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount_bkn': amountBkn,
              'user_id': uid,
              'email': email,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Stripe backend error (${res.statusCode}): ${res.body}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final url = data['url']?.toString();
      final sessionId = data['session_id']?.toString();
      if (url == null || sessionId == null) {
        throw Exception('Stripe backend response invalid: ${res.body}');
      }
      return {'url': url, 'session_id': sessionId};
    } catch (e, st) {
      throw _backendException('Création du paiement Stripe', e, st);
    }
  }

  /// Returns the credited amount if paid, or null if not yet paid.
  Future<double?> isCheckoutPaid({required String sessionId}) async {
    final uri = Uri.parse(
      '${AppConfig.stripeBackendBaseUrl}/checkout-status?session_id=$sessionId',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 15));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Stripe backend error (${res.statusCode}): ${res.body}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['paid'] != true) return null;
      final raw = data['amount_bkn'];
      if (raw == null) return null;
      final parsed =
          raw is num ? raw.toDouble() : double.tryParse(raw.toString());
      if (parsed == null || parsed <= 0) return null;
      return parsed;
    } catch (e, st) {
      throw _backendException('Vérification du paiement Stripe', e, st);
    }
  }

  // BUY/SELL simulated
  Future<void> buySimulated({
    required double amountBkn,
    required bool success,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');
    final status = success ? 'OK' : 'NOK';

    if (success) {
      final bal = await getBalance();
      await _db
          .from('wallets')
          .update({
            'balance_bkn': bal + amountBkn,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', uid);
    }

    await _db.from('transactions').insert({
      'user_id': uid,
      'type': 'BUY',
      'amount_bkn': amountBkn,
      'status': status,
    });
  }

  Future<void> sellSimulated({
    required double amountBkn,
    required bool success,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not logged in');
    final bal = await getBalance();

    final ok = success && bal >= amountBkn;
    final status = ok ? 'OK' : 'NOK';

    if (ok) {
      await _db
          .from('wallets')
          .update({
            'balance_bkn': bal - amountBkn,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', uid);
    }

    await _db.from('transactions').insert({
      'user_id': uid,
      'type': 'SELL',
      'amount_bkn': amountBkn,
      'status': status,
    });
  }
}
