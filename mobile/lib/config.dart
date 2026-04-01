import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Supabase
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Stripe (public key) - only needed if you later use Stripe SDK client-side.
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'YOUR_STRIPE_PUBLISHABLE_KEY',
  );

  // App constants
  static const initialBalanceBkn = 1500.0;
  static const rateEurPerBkn = 1.0;

  /// Stripe backend (Docker)
  /// - Android emulator: http://10.0.2.2:4000
  /// - Web/Desktop: http://localhost:4000
  /// - Real phone: use --dart-define=STRIPE_BACKEND_BASE_URL=http://<PC_IP>:4000
  static String get stripeBackendBaseUrl {
    const override = String.fromEnvironment('STRIPE_BACKEND_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://localhost:4000';
    if (Platform.isAndroid) return 'http://10.0.2.2:4000';
    return 'http://localhost:4000';
  }

  // =====================
  // On-chain (EVM) config
  // =====================
  /// RPC URL for an EVM testnet/mainnet.
  /// Example Base Sepolia: https://sepolia.base.org
  static const evmRpcUrl = String.fromEnvironment(
    'EVM_RPC_URL',
    defaultValue: '',
  );

  /// Human-readable chain id / name used only for display & logging.
  /// Examples: base-sepolia, polygon-amoy, ethereum-mainnet
  static const evmChain = String.fromEnvironment(
    'EVM_CHAIN',
    defaultValue: 'base-sepolia',
  );

  /// ERC-20 token contract address for BKN on the selected chain.
  /// Keep empty until you deploy on testnet.
  static const bknTokenAddress = String.fromEnvironment(
    'BKN_TOKEN_ADDRESS',
    defaultValue: '',
  );
}
