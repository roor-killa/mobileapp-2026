import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class PinDialog extends StatefulWidget {
  final String title;
  final String subtitle;

  const PinDialog({super.key, required this.title, this.subtitle = 'Entrez votre PIN pour confirmer'});

  static Future<String?> show(BuildContext context, {String title = 'Confirmation PIN', String subtitle = 'Entrez votre PIN pour confirmer'}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinDialog(title: title, subtitle: subtitle),
    );
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _pinCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de drag
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),

          Text(widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(widget.subtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),

          // Champ PIN
          TextFormField(
            controller: _pinCtrl,
            obscureText: _obscure,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            style: const TextStyle(
                fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              hintText: '● ● ● ●',
              hintStyle: const TextStyle(color: AppColors.textHint, letterSpacing: 8),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_pinCtrl.text.length >= 4) {
                      Navigator.pop(context, _pinCtrl.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
