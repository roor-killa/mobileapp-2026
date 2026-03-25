import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Événement enregistré dans le journal de sécurité.
class SecurityEvent {
  final String type;
  final String description;
  final DateTime date;

  SecurityEvent({required this.type, required this.description, required this.date});

  Map<String, dynamic> toJson() => {'type': type, 'description': description, 'date': date.toIso8601String()};
  factory SecurityEvent.fromJson(Map<String, dynamic> j) => SecurityEvent(
        type: j['type'] ?? '',
        description: j['description'] ?? '',
        date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
      );
}

/// Gère la sécurité : PIN, timeout, journal, paramètres.
class SecurityProvider with ChangeNotifier {
  static const _pinKey = 'app_pin_hash';
  static const _pinEnabledKey = 'pin_enabled';
  static const _timeoutKey = 'session_timeout_min';
  static const _biometricKey = 'biometric_enabled';
  static const _clipboardClearKey = 'clipboard_clear_enabled';
  static const _logKey = 'security_log';
  static const _maxLogEntries = 50;
  static const _failedAttemptsKey = 'failed_login_attempts';
  static const _lockUntilKey = 'login_lock_until';
  static const _maxFailedAttempts = 5;
  static const _lockoutMinutes = 15;

  /// Si false : pas de blocage « réessayez dans X min » après échecs (meilleure UX / démo).
  static const bool enableLoginCooldown = false;

  final _storage = const FlutterSecureStorage();

  bool _pinEnabled = false;
  int _timeoutMinutes = 45;
  bool _biometricEnabled = false;
  bool _clipboardClearEnabled = true;
  bool _isLocked = false;
  List<SecurityEvent> _log = [];
  int _failedLoginAttempts = 0;
  DateTime? _loginLockUntil;

  bool get pinEnabled => _pinEnabled;
  int get timeoutMinutes => _timeoutMinutes;
  bool get biometricEnabled => _biometricEnabled;
  bool get clipboardClearEnabled => _clipboardClearEnabled;
  bool get isLocked => _isLocked;
  List<SecurityEvent> get securityLog => List.unmodifiable(_log);
  int get failedLoginAttempts => _failedLoginAttempts;
  DateTime? get loginLockUntil => _loginLockUntil;
  bool get isLoginLocked {
    if (!enableLoginCooldown) return false;
    if (_loginLockUntil == null) return false;
    if (DateTime.now().isAfter(_loginLockUntil!)) {
      _loginLockUntil = null;
      _failedLoginAttempts = 0;
      notifyListeners();
      return false;
    }
    return true;
  }
  int get remainingLockMinutes {
    if (_loginLockUntil == null) return 0;
    return _loginLockUntil!.difference(DateTime.now()).inMinutes + 1;
  }

  /// Dernière activité (pour timeout).
  DateTime _lastActivity = DateTime.now();
  DateTime get lastActivity => _lastActivity;

  SecurityProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pinEnabled = prefs.getBool(_pinEnabledKey) ?? false;
      _timeoutMinutes = prefs.getInt(_timeoutKey) ?? 45;
      _biometricEnabled = prefs.getBool(_biometricKey) ?? false;
      _clipboardClearEnabled = prefs.getBool(_clipboardClearKey) ?? true;

      final logJson = prefs.getString(_logKey);
      if (logJson != null) {
        final list = jsonDecode(logJson) as List?;
        _log = (list ?? []).map((e) => SecurityEvent.fromJson(e as Map<String, dynamic>)).toList();
      }
      _failedLoginAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
      final lockTs = prefs.getInt(_lockUntilKey);
      _loginLockUntil = lockTs != null ? DateTime.fromMillisecondsSinceEpoch(lockTs) : null;
      if (_loginLockUntil != null && DateTime.now().isAfter(_loginLockUntil!)) {
        _loginLockUntil = null;
        _failedLoginAttempts = 0;
        await prefs.remove(_lockUntilKey);
        await prefs.setInt(_failedAttemptsKey, 0);
      }
      // Efface un ancien verrou enregistré si la fonctionnalité est désactivée
      if (!enableLoginCooldown && (_loginLockUntil != null || _failedLoginAttempts > 0)) {
        _loginLockUntil = null;
        _failedLoginAttempts = 0;
        await prefs.remove(_lockUntilKey);
        await prefs.remove(_failedAttemptsKey);
      }
    } catch (_) {}
    notifyListeners();
  }

  void touchActivity() {
    _lastActivity = DateTime.now();
  }

  /// Vérifie si la session a expiré.
  bool get isSessionExpired {
    if (_timeoutMinutes <= 0) return false;
    return DateTime.now().difference(_lastActivity).inMinutes >= _timeoutMinutes;
  }

  Future<void> setPinEnabled(bool enabled) async {
    _pinEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, enabled);
    if (!enabled) await _storage.delete(key: _pinKey);
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    if (pin.length < 4) return;
    final hash = _simpleHash(pin);
    await _storage.write(key: _pinKey, value: hash);
    _pinEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, true);
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;
    return stored == _simpleHash(pin);
  }

  Future<void> changePin(String oldPin, String newPin) async {
    final ok = await verifyPin(oldPin);
    if (!ok) throw Exception('PIN actuel incorrect');
    if (newPin.length < 4) throw Exception('Le PIN doit contenir au moins 4 chiffres');
    await setPin(newPin);
  }

  static String _simpleHash(String s) {
    final bytes = s.codeUnits;
    int h = 0;
    for (final b in bytes) h = ((h << 5) - h) + b;
    return h.toString();
  }

  Future<void> setTimeoutMinutes(int minutes) async {
    _timeoutMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, minutes);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
    notifyListeners();
  }

  Future<void> setClipboardClearEnabled(bool enabled) async {
    _clipboardClearEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clipboardClearKey, enabled);
    notifyListeners();
  }

  void lock() {
    _isLocked = true;
    notifyListeners();
  }

  void unlock() {
    _isLocked = false;
    touchActivity();
    notifyListeners();
  }

  Future<void> addLog(String type, String description) async {
    _log.insert(0, SecurityEvent(type: type, description: description, date: DateTime.now()));
    if (_log.length > _maxLogEntries) _log = _log.take(_maxLogEntries).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_logKey, jsonEncode(_log.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> clearLog() async {
    _log = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
    notifyListeners();
  }

  /// Enregistre une tentative de connexion échouée. Retourne true si le compte est maintenant verrouillé.
  Future<bool> recordFailedLogin() async {
    if (!enableLoginCooldown) {
      notifyListeners();
      return false;
    }
    _failedLoginAttempts++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_failedAttemptsKey, _failedLoginAttempts);

    if (_failedLoginAttempts >= _maxFailedAttempts) {
      _loginLockUntil = DateTime.now().add(const Duration(minutes: _lockoutMinutes));
      await prefs.setInt(_lockUntilKey, _loginLockUntil!.millisecondsSinceEpoch);
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  /// Réinitialise les tentatives après une connexion réussie.
  Future<void> resetFailedAttempts() async {
    _failedLoginAttempts = 0;
    _loginLockUntil = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lockUntilKey);
    notifyListeners();
  }

  /// Débloque les tentatives sur **cet appareil** (protection locale uniquement).
  /// Utile si vous êtes sûr de votre mot de passe ou en cas de faux positif.
  Future<void> clearLoginLockOnDevice() async {
    await resetFailedAttempts();
  }
}
