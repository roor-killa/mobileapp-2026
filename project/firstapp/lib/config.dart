import 'package:flutter/foundation.dart';

/// URL de base de l'API.
/// - Web (Chrome)       → localhost (même machine)
/// - Émulateur Android  → 10.0.2.2 (loopback hôte via QEMU)
///                        ⚠ Si timeout, remplacer par l'IP LAN du Mac :
///                          const _androidUrl = 'http://172.26.159.22:8001/api';
/// - Appareil physique  → IP LAN du Mac (ex. 172.26.159.22)
const String _webUrl     = 'http://localhost:8001/api';
// const String _androidUrl = 'http://10.0.2.2:8001/api';      // ← émulateur QEMU standard
const String _androidUrl = 'http://172.26.159.22:8001/api';   // ← IP LAN du Mac (actuelle)

String get apiBaseUrl => kIsWeb ? _webUrl : _androidUrl;
