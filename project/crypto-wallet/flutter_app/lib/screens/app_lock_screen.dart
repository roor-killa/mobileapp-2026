import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/security_provider.dart';

/// Écran de verrouillage par PIN.
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _pinController = TextEditingController();
  String _enteredPin = '';
  bool _wrongPin = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_enteredPin.length >= 6) return;
    setState(() {
      _enteredPin += digit;
      _wrongPin = false;
      _pinController.text = _enteredPin;
    });
    if (_enteredPin.length >= 4) _verifyPin();
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _pinController.text = _enteredPin;
      _wrongPin = false;
    });
  }

  Future<void> _verifyPin() async {
    final sec = context.read<SecurityProvider>();
    final ok = await sec.verifyPin(_enteredPin);
    if (ok) {
      sec.unlock();
    } else {
      setState(() {
        _wrongPin = true;
        _enteredPin = '';
        _pinController.clear();
      });
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, size: 56, color: AppTheme.primary),
                ),
                const SizedBox(height: 24),
                const Text(
                  'NodEX verrouillé',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  _wrongPin ? 'PIN incorrect' : 'Entrez votre code PIN',
                  style: TextStyle(color: _wrongPin ? Colors.redAccent : AppTheme.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _enteredPin.length
                          ? (_wrongPin ? Colors.redAccent : AppTheme.primary)
                          : AppTheme.border,
                    ),
                  )),
                ),
                const SizedBox(height: 48),
                _buildKeypad(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'back'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: digits.map((d) {
        if (d == '') return const SizedBox();
        if (d == 'back') {
          return _keypadButton(
            icon: Icons.backspace_outlined,
            onTap: _onBackspace,
          );
        }
        return _keypadButton(
          label: d,
          onTap: () => _onDigit(d),
        );
      }).toList(),
    );
  }

  Widget _keypadButton({String? label, IconData? icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppTheme.textPrimary, size: 28)
                : Text(label!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ),
        ),
      ),
    );
  }
}
