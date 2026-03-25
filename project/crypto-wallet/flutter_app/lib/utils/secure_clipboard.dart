import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';

/// Copie du texte de manière sécurisée : efface le presse-papiers après 30 s si l'option est activée.
Future<void> secureCopy(BuildContext context, String text, {String? logDescription}) async {
  await Clipboard.setData(ClipboardData(text: text));

  try {
    final sec = context.read<SecurityProvider>();
    if (logDescription != null) sec.addLog('copy', logDescription);
    final shouldClear = sec.clipboardClearEnabled;
    if (shouldClear) {
      Future.delayed(const Duration(seconds: 30), () => Clipboard.setData(const ClipboardData(text: '')));
    }
  } catch (_) {}
}
