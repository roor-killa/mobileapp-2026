import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bonsoir/bonsoir.dart';

class ApiHelper {
  static String? _discoveredIp;
  
  // L'IP de ton PC sur le réseau actuel (10.53.87.211)
  static const String _manualFallbackIp = '10.53.87.211';
  static const String _defaultPort = '8001';  // ← CHANGÉ À 8001

  /// Récupère l'URL de base dynamique
  static String get baseUrl {
    if (_discoveredIp != null) {
      return 'http://$_discoveredIp:$_defaultPort';
    } 
    
    // Si on est sur un émulateur Android, on peut tenter 10.0.2.2, 
    // sinon on utilise l'IP de ton PC.
    if (!kIsWeb && Platform.isAndroid && _manualFallbackIp == '127.0.0.1') {
      return 'http://10.0.2.2:$_defaultPort';
    }

    return 'http://$_manualFallbackIp:$_defaultPort';
  }

  static void log(String message) {
    if (kDebugMode) print('📱 API: $message');
  }

  /// Tente de découvrir le serveur BKN sur le réseau local
  static Future<void> discoverServer({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      log('Recherche du serveur via Bonsoir (_bkn._tcp)...');
      
      // On utilise le type défini dans ton server.py
      final discovery = BonsoirDiscovery(type: '_bkn._tcp.local.');
      
      await discovery.initialize();

      final subscription = discovery.eventStream?.listen((event) {
        if (event is BonsoirDiscoveryServiceFoundEvent) {
          log('🔍 Service trouvé, résolution de l\'IP...');
          event.service.resolve(discovery.serviceResolver);
        } 
        else if (event is BonsoirDiscoveryServiceResolvedEvent) {
          final host = event.service.host;
          
          // On s'assure de récupérer une adresse IPv4 valide
          if (host != null && !host.contains(':') && _discoveredIp == null) {
            _discoveredIp = host;
            log('✅ Serveur découvert via Bonsoir: $_discoveredIp');
          }
        }
      });

      await discovery.start();
      
      // On laisse le temps à la découverte de s'exécuter
      await Future.delayed(timeout);
      
      await discovery.stop();
      await subscription?.cancel();

      if (_discoveredIp == null) {
        log('⚠️ Serveur non trouvé via Bonsoir après ${timeout.inSeconds}s.');
        log('🔗 Utilisation de l\'adresse de secours : $baseUrl');
      }
    } catch (e) {
      log('❌ Erreur lors de la découverte : $e');
      log('🔗 Repli sur l\'adresse : $baseUrl');
    }
  }
}