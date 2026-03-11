import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:bonsoir/bonsoir.dart';

class ApiHelper {
  static String? _discoveredIp;
  
  // L'IP de ton PC sur le réseau actuel
  static const String _manualFallbackIp = '172.26.174.112'; // TON IP
  static const String _defaultPort = '8000';  // ← CORRIGÉ À 8000

  /// Récupère l'URL de base dynamique
  static String get baseUrl {
    if (_discoveredIp != null) {
      return 'http://$_discoveredIp:$_defaultPort';
    } 
    
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
      
      final discovery = BonsoirDiscovery(type: '_bkn._tcp.local.');
      
      await discovery.initialize();

      final subscription = discovery.eventStream?.listen((event) {
        if (event is BonsoirDiscoveryServiceFoundEvent) {
          log('Service trouvé, résolution de l\'IP...');
          event.service.resolve(discovery.serviceResolver);
        } 
        else if (event is BonsoirDiscoveryServiceResolvedEvent) {
          final host = event.service.host;
          
          if (host != null && !host.contains(':') && _discoveredIp == null) {
            _discoveredIp = host;
            log('Serveur découvert via Bonsoir: $_discoveredIp');
          }
        }
      });

      await discovery.start();
      
      await Future.delayed(timeout);
      
      await discovery.stop();
      await subscription?.cancel();

      if (_discoveredIp == null) {
        log('Serveur non trouvé via Bonsoir après ${timeout.inSeconds}s.');
        log('Utilisation de l\'adresse de secours : $baseUrl');
      }
    } catch (e) {
      log('Erreur lors de la découverte : $e');
      log('Repli sur l\'adresse : $baseUrl');
    }
  }
}