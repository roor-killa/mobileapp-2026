import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion des préférences utilisateur (dark mode, PIN, visibilité solde).
class PreferencesService {
  static final PreferencesService instance = PreferencesService._();
  PreferencesService._();

  static const _keyDarkMode = 'dark_mode';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyPin = 'pin_code';
  static const _keyBalanceVisible = 'balance_visible';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Dark Mode ---

  Future<bool> getDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDarkMode, value);
  }

  // --- PIN ---

  Future<bool> isPinEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyPinEnabled) ?? false;
  }

  Future<String?> getPin() async {
    final prefs = await _prefs;
    return prefs.getString(_keyPin);
  }

  Future<void> setPin(String pin) async {
    final prefs = await _prefs;
    await prefs.setString(_keyPin, pin);
    await prefs.setBool(_keyPinEnabled, true);
  }

  Future<void> disablePin() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyPinEnabled, false);
    await prefs.remove(_keyPin);
  }

  // --- Visibilité du solde ---

  Future<bool> getBalanceVisible() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyBalanceVisible) ?? true;
  }

  Future<void> setBalanceVisible(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyBalanceVisible, value);
  }

  // --- Seuil d'alerte solde bas (par utilisateur) ---

  String _keyAlerteSolde(String userId) => 'alerte_solde_$userId';

  Future<double> getAlerteSolde(String userId) async {
    final prefs = await _prefs;
    return prefs.getDouble(_keyAlerteSolde(userId)) ?? 100.0;
  }

  Future<void> setAlerteSolde(String userId, double valeur) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyAlerteSolde(userId), valeur);
  }

  // --- Budget mensuel (par utilisateur) ---

  String _keyBudgetMensuel(String userId) => 'budget_mensuel_$userId';

  /// Retourne le budget mensuel (0 = non défini).
  Future<double> getBudgetMensuel(String userId) async {
    final prefs = await _prefs;
    return prefs.getDouble(_keyBudgetMensuel(userId)) ?? 0.0;
  }

  Future<void> setBudgetMensuel(String userId, double valeur) async {
    final prefs = await _prefs;
    await prefs.setDouble(_keyBudgetMensuel(userId), valeur);
  }
}
