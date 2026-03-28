import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'new_password_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});
  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpCtrl = TextEditingController();

  @override
  void dispose() { _otpCtrl.dispose(); super.dispose(); }

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Le code doit contenir 8 chiffres.'),
          backgroundColor: Colors.orange));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(otp);
    if (!mounted) return;
    if (ok) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const NewPasswordScreen()));
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.error!), backgroundColor: Colors.red.shade700));
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    if (auth.resetEmail == null) return;
    final ok = await auth.sendPasswordResetOtp(auth.resetEmail!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Code renvoyé à ${auth.resetEmail}' : (auth.error ?? 'Erreur')),
      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du code'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.mark_email_read_outlined, size: 64, color: Color(0xFF1565C0)),
              const SizedBox(height: 24),
              const Text('Code envoyé !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Un code à 8 chiffres a été envoyé à ${auth.resetEmail ?? 'votre email'}.\n\nOuvrez votre email et saisissez le code ci-dessous.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 8,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 16),
                decoration: InputDecoration(
                  hintText: '--------',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),
              auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Vérifier le code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _verify,
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: auth.isLoading ? null : _resend,
                child: const Text('Renvoyer le code'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}