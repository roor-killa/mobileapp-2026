import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/pin_dialog.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_rounded), text: 'Générer'),
            Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Scanner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [_GenerateTab(), _ScanTab()],
      ),
    );
  }
}

// ─── Onglet Générer ──────────────────────────────────────────────────────────
class _GenerateTab extends StatefulWidget {
  const _GenerateTab();

  @override
  State<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<_GenerateTab> {
  final _amountCtrl = TextEditingController();
  Map<String, dynamic>? _qrData;
  Timer? _refreshTimer;
  int _countdown = 30;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez un montant valide'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    _refreshTimer?.cancel();

    final result = await context.read<TransactionProvider>().generateQr(amount);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _qrData = result;
      _countdown = result?['expires_in'] ?? 30;
    });

    if (result != null) {
      _startCountdown(amount);
    }
  }

  void _startCountdown(double amount) {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        _generate(); // Auto-refresh
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Champ montant
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}'))],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Montant à recevoir (€)',
                    prefixIcon: const Icon(Icons.euro_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // QR Code
          if (_qrData != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  // Timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: _countdown <= 10 ? AppColors.error : AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Expire dans $_countdown s',
                        style: TextStyle(
                          color: _countdown <= 10 ? AppColors.error : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // QR Image
                  QrImageView(
                    data: jsonEncode(_qrData!['qr_payload']),
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Montant
                  Text(
                    '${(_qrData!['qr_payload']['amount'] as num).toStringAsFixed(2)} €',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  const Text('Faites scanner ce QR pour recevoir ce montant',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center),

                  // Progress bar
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _countdown / 30,
                    backgroundColor: AppColors.border,
                    color: _countdown <= 10 ? AppColors.error : AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 80, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('Entrez un montant et générez votre QR Code',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Onglet Scanner ──────────────────────────────────────────────────────────
class _ScanTab extends StatefulWidget {
  const _ScanTab();

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  final _scannerCtrl = MobileScannerController();
  bool _scanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _scanned = true);
    _scannerCtrl.stop();

    try {
      final payload = jsonDecode(barcode!.rawValue!) as Map<String, dynamic>;
      final token  = payload['token'] as String?;
      final amount = (payload['amount'] as num?)?.toDouble();
      final owner  = payload['owner_name'] as String? ?? 'Inconnu';

      if (token == null || !mounted) return;

      // Confirmer le paiement
      final confirmed = await _showConfirmDialog(amount ?? 0, owner);
      if (!mounted) return;

      if (confirmed == true) {
        final pin = await PinDialog.show(context, title: 'Paiement QR');
        if (pin == null || !mounted) { setState(() => _scanned = false); _scannerCtrl.start(); return; }

        final result = await context.read<TransactionProvider>().scanQr(token, pin);
        if (!mounted) return;

        if (result != null) {
          context.read<AuthProvider>().updateBalance(result['new_balance']?.toDouble() ?? 0);
          _showSuccess(result['message'] ?? 'Paiement effectué !');
        } else {
          _showError(context.read<TransactionProvider>().error ?? 'Erreur');
          setState(() => _scanned = false);
          _scannerCtrl.start();
        }
      } else {
        setState(() => _scanned = false);
        _scannerCtrl.start();
      }
    } catch (_) {
      setState(() => _scanned = false);
      _scannerCtrl.start();
    }
  }

  Future<bool?> _showConfirmDialog(double amount, String owner) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Payer ${amount.toStringAsFixed(2)}€ à $owner',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Payer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            Text(msg, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            CustomButton(label: 'OK', onPressed: () { Navigator.pop(context); setState(() => _scanned = false); _scannerCtrl.start(); }),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MobileScanner(controller: _scannerCtrl, onDetect: _onDetect),
              // Overlay
              Center(
                child: Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Contrôles
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () { setState(() => _torchOn = !_torchOn); _scannerCtrl.toggleTorch(); },
                icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: AppColors.primary, size: 28),
              ),
              const Text('Scannez le QR Code', style: TextStyle(color: AppColors.textSecondary)),
              IconButton(
                onPressed: () => _scannerCtrl.switchCamera(),
                icon: const Icon(Icons.flip_camera_ios_rounded, color: AppColors.primary, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
