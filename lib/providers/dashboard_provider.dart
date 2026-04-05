import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../core/models/transaction_model.dart';

class DashboardProvider extends ChangeNotifier {
  List<TransactionModel> _recentTransactions = [];
  Map<String, dynamic> _monthlyStats = {};
  int _unreadNotifications = 0;
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get recentTransactions => _recentTransactions;
  Map<String, dynamic> get monthlyStats => _monthlyStats;
  int get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSent => (_monthlyStats['total_sent'] as num?)?.toDouble() ?? 0.0;
  double get totalReceived => (_monthlyStats['total_received'] as num?)?.toDouble() ?? 0.0;

  final _api = ApiService.instance;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.get(ApiConstants.dashboard);
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        _recentTransactions = (data['recent_transactions'] as List)
            .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
            .toList();
        _monthlyStats = (data['monthly_stats'] as Map<String, dynamic>?) ?? {};
        _unreadNotifications = (data['unread_notifications'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void decrementUnread() {
    if (_unreadNotifications > 0) {
      _unreadNotifications--;
      notifyListeners();
    }
  }
}
