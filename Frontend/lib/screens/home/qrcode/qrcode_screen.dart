import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('QR Code'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Recevoir'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scanner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GenerateTab(),
          _ScanTab(),
        ],
      ),
    );
  }
}

// ─── Onglet Générer QR ──────────────────────────────────────────────────────

class _GenerateTab extends StatefulWidget {
  const _GenerateTab();

  @override
  State<_GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<_GenerateTab> {
  final _amountCtrl = TextEditingController();
  String? _qrData;
  Timer?  _refreshTimer;
  bool    _loading = false;
  int     _secondsLeft = 10;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final text = _amountCtrl.text.trim().replaceAll(',', '.');
    final euros = double.tryParse(text);
    if (euros == null || euros < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide (min 1,00 €)'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final cents = (euros * 100).round();
      final data = await context.read<TransactionProvider>().generateQr(cents);
      _refreshTimer?.cancel();
      setState(() {
        _qrData      = data['token'];
        _secondsLeft = 10;
      });
      // Compte à rebours + auto-regénération
      _refreshTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) {
          t.cancel();
          _generate(); // regénère automatiquement
        }
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Montant à recevoir (€)',
              prefixIcon: Icon(Icons.euro_outlined),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loading ? null : _generate,
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Générer le QR Code'),
          ),
          const SizedBox(height: 28),
          if (_qrData != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20)
                ],
              ),
              child: Column(
                children: [
                  QrImageView(data: _qrData!, size: 220),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, size: 18, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Expire dans $_secondsLeft secondes',
                        style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _secondsLeft / 10,
                    color: AppColors.warning,
                    backgroundColor: Colors.orange.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Onglet Scanner QR ──────────────────────────────────────────────────────

class _ScanTab extends StatefulWidget {
  const _ScanTab();

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  final _pinCtrl       = TextEditingController();
  final _cameraCtrl    = MobileScannerController();
  String? _scannedToken;
  bool    _processing  = false;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _cameraCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scannedToken != null || _processing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      setState(() => _scannedToken = barcode!.rawValue);
      _cameraCtrl.stop();
      _showPinDialog();
    }
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entrez votre PIN pour valider'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(
                  labelText: 'PIN à 6 chiffres', counterText: ''),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _scannedToken = null);
              _pinCtrl.clear();
              _cameraCtrl.start();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _processing ? null : _confirmPayment,
            child: const Text('Payer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment() async {
    if (_pinCtrl.text.length != 6) return;
    setState(() => _processing = true);
    try {
      final txProvider   = context.read<TransactionProvider>();
      final authProvider = context.read<AuthProvider>();
      await txProvider.scanQr(
            token: _scannedToken!,
            pin:   _pinCtrl.text,
          );
      await authProvider.refreshUser();
      await txProvider.loadHistory();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Paiement effectué !'),
              backgroundColor: AppColors.success),
        );
        setState(() { _scannedToken = null; _processing = false; });
        _pinCtrl.clear();
        _cameraCtrl.start();
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
        setState(() { _scannedToken = null; _processing = false; });
        _pinCtrl.clear();
        _cameraCtrl.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: MobileScanner(
              controller: _cameraCtrl,
              onDetect: _onDetect,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              _scannedToken == null
                  ? 'Pointez la caméra vers un QR Code'
                  : 'QR Code détecté !',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

