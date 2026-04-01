import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  const CheckoutWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  bool _looksLikeSuccess(String url) {
    final u = url.toLowerCase();
    return u.contains('success') || u.contains('payment_intent') || u.contains('checkout/session');
  }

  bool _looksLikeCancel(String url) {
    final u = url.toLowerCase();
    return u.contains('cancel');
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _loading = false);
            if (_looksLikeSuccess(url) && mounted) {
              Navigator.of(context).pop(true);
            } else if (_looksLikeCancel(url) && mounted) {
              Navigator.of(context).pop(false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Stripe'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Vérifier le paiement"),
          ),
        ),
      ),
    );
  }
}
