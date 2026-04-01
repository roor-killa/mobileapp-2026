import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';

enum PinMode { setup, verify, change }

/// Écran de saisie/vérification du code PIN à 4 chiffres.
class PinScreen extends StatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;

  const PinScreen({super.key, required this.mode, this.onSuccess});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMsg = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  static const _pinLength = 4;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin += digit;
      _errorMsg = '';
    });
    if (_pin.length == _pinLength) {
      _validate();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _validate() async {
    await Future.delayed(const Duration(milliseconds: 150));

    switch (widget.mode) {
      case PinMode.verify:
        final stored = await PreferencesService.instance.getPin();
        if (_pin == stored) {
          widget.onSuccess?.call();
        } else {
          _shake('Code PIN incorrect');
        }
        break;

      case PinMode.setup:
        if (!_isConfirming) {
          setState(() {
            _confirmPin = _pin;
            _pin = '';
            _isConfirming = true;
          });
        } else {
          if (_pin == _confirmPin) {
            await PreferencesService.instance.setPin(_pin);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code PIN activé avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          } else {
            _shake('Les codes ne correspondent pas');
            setState(() => _isConfirming = false);
          }
        }
        break;

      case PinMode.change:
        final stored = await PreferencesService.instance.getPin();
        if (!_isConfirming) {
          if (_pin == stored || stored == null) {
            setState(() {
              _confirmPin = '';
              _pin = '';
              _isConfirming = true;
            });
          } else {
            _shake('Code PIN actuel incorrect');
          }
        } else {
          await PreferencesService.instance.setPin(_pin);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code PIN modifié avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        }
        break;
    }
  }

  void _shake(String msg) {
    setState(() {
      _errorMsg = msg;
      _pin = '';
    });
    _shakeCtrl.forward(from: 0);
  }

  String get _title {
    switch (widget.mode) {
      case PinMode.verify:
        return 'Entrez votre code PIN';
      case PinMode.setup:
        return _isConfirming ? 'Confirmez votre code PIN' : 'Créer un code PIN';
      case PinMode.change:
        return _isConfirming ? 'Nouveau code PIN' : 'Code PIN actuel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 56, color: Colors.white70),
                  const SizedBox(height: 12),
                  const Text(
                    'VLT Bank',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _title,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Indicateurs de points
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (_, child) {
                      final offset =
                          (_shakeAnim.value * 10 * (1 - _shakeAnim.value)).toInt();
                      return Transform.translate(
                        offset: Offset(offset.toDouble(), 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pinLength, (i) {
                        final filled = i < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled ? Colors.white : Colors.transparent,
                            border: Border.all(color: Colors.white70, width: 2),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMsg,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),

            // Clavier numérique
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeyRow(['1', '2', '3']),
                      _buildKeyRow(['4', '5', '6']),
                      _buildKeyRow(['7', '8', '9']),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bouton annuler (si mode verify)
                          if (widget.mode == PinMode.verify)
                            _buildKeyButton('', icon: Icons.close, onTap: () {})
                          else
                            const SizedBox(width: 72),
                          _buildKeyButton('0'),
                          _buildKeyButton('', icon: Icons.backspace_outlined, onTap: _onDelete),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildKeyButton).toList(),
    );
  }

  Widget _buildKeyButton(String digit, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _onKey(digit),
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 26, color: AppColors.primary)
              : Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}
