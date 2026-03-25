import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Même logique que le backend Laravel (`NodexUser::syntheticIbanForAppwriteId` /
/// `EnsureNodexUser`) : IBAN et pseudonyme déterministes à partir de l’id Appwrite.
/// Permet d’afficher un RIB immédiatement, même si l’API n’est pas joignable.

String nodexSyntheticIban(String appwriteId) {
  final hash = sha256.convert(utf8.encode('${appwriteId}iban')).toString();
  final digits = hash.replaceAll(RegExp(r'\D'), '');
  var d = digits;
  if (d.length < 11) {
    d = d.padRight(11, '0');
  }
  return 'FR76 3000 6000 01${d.substring(0, 11)}00';
}

String nodexSyntheticPseudonym(String appwriteId) {
  final h = md5.convert(utf8.encode(appwriteId)).toString();
  return 'nodex_${h.substring(0, 12)}';
}
