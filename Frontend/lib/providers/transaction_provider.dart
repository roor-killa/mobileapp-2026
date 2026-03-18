import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TransactionModel> _transactions = [];
  bool   _loading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool    get loading => _loading;
  String? get error   => _error;

  Future<void> loadHistory({String? type}) async {
    _loading = true;
    _error   = null;
    notifyListeners();
    try {
      _transactions = await _api.getHistory(type: type);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> transfer({
    required String receiverEmail,
    required int    amountCents,
    required String pin,
    String? note,
  }) async {
    return await _api.transfer(
      receiverEmail: receiverEmail,
      amountCents:   amountCents,
      pin:           pin,
      note:          note,
    );
  }

  Future<Map<String, dynamic>> generateQr(int amountCents) =>
      _api.generateQr(amountCents);

  Future<Map<String, dynamic>> scanQr({
    required String token,
    required String pin,
  }) => _api.scanQr(token: token, pin: pin);
}

