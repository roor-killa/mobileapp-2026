import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  bool get hasMore => _hasMore;

  final _api = ApiService.instance;

  // ─── Charger l'historique (avec pagination) ────────────────────────────────
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _transactions = [];
    }
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final res =
          await _api.get('${ApiConstants.transactions}?page=$_currentPage');
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final items = (data['data'] as List)
            .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
        _transactions.addAll(items);
        _hasMore = (data['current_page'] as int) < (data['last_page'] as int);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Envoyer de l'argent ───────────────────────────────────────────────────
  Future<Map<String, dynamic>?> sendMoney({
    required String receiverEmail,
    required double amount,
    required String pin,
    String? description,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.post(ApiConstants.sendMoney, {
        'receiver_email': receiverEmail,
        'amount': amount,
        'pin': pin,
        if (description != null && description.isNotEmpty)
          'description': description,
      });
      _isSending = false;
      notifyListeners();
      if (res['success'] == true) return res;
    } catch (e) {
      _error = e.toString();
    }

    _isSending = false;
    notifyListeners();
    return null;
  }

  // ─── Générer un QR Code ────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> generateQr(double amount) async {
    try {
      final res = await _api.post(ApiConstants.qrGenerate, {'amount': amount});
      if (res['success'] == true) return res;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
    return null;
  }

  // ─── Scanner un QR Code ────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> scanQr(String token, String pin) async {
    _isSending = true;
    notifyListeners();
    try {
      final res = await _api.post(ApiConstants.qrScan, {'token': token, 'pin': pin});
      _isSending = false;
      notifyListeners();
      if (res['success'] == true) return res;
    } catch (e) {
      _error = e.toString();
    }
    _isSending = false;
    notifyListeners();
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
