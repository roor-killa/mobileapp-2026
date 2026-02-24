import 'package:flutter/material.dart';
import '../core/supabase_service.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class BankProvider extends ChangeNotifier {
  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<AccountModel> get accounts => List.unmodifiable(_accounts);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Chargement ─────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _accounts     = await SupabaseService.getMyAccounts();
      _transactions = await SupabaseService.getHistory();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Création de compte ─────────────────────────────────────────────────────

  Future<String?> createAccount(String label, double initialBalance) async {
    try {
      final acc = await SupabaseService.createAccount(label, initialBalance);
      _accounts = [..._accounts, acc];
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  // ── Virement ───────────────────────────────────────────────────────────────

  Future<String?> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? note,
  }) async {
    try {
      final txn = await SupabaseService.transfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        note: note,
      );
      // Mise à jour locale immédiate du solde
      final idx = _accounts.indexWhere((a) => a.id == fromAccountId);
      if (idx != -1) _accounts[idx].balance -= amount;
      _transactions = [txn, ..._transactions];
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  // ── Recherche ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      return await SupabaseService.searchUsers(query);
    } catch (_) {
      return [];
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  AccountModel? findById(String id) {
    try { return _accounts.firstWhere((a) => a.id == id); }
    catch (_) { return null; }
  }

  List<TransactionModel> transactionsFor(String accountId) => _transactions
      .where((t) => t.fromAccountId == accountId || t.toAccountId == accountId)
      .toList();

  void clear() {
    _accounts = [];
    _transactions = [];
    notifyListeners();
  }
}