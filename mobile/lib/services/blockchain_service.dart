import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

/// Minimal on-chain scaffold.
///
/// This class is intentionally dependency-free (no web3 libs) so your Flutter
/// build stays stable. It provides a clean interface so you can later plug in:
/// - WalletConnect / Metamask signing on-device, OR
/// - a trusted backend signer for demo/testnet.
///
/// Current implementation supports an OPTIONAL backend endpoint.
/// If you do not have an on-chain backend yet, calls will throw with a clear
/// message (so your app can fallback to internal Supabase transfers).
class BlockchainService {
  const BlockchainService();

  /// Optional backend that performs on-chain signing + broadcast (demo mode).
  ///
  /// Provide it with:
  /// flutter run --dart-define=EVM_BACKEND_BASE_URL=http://<PC_IP>:5005
  static const evmBackendBaseUrl = String.fromEnvironment(
    'EVM_BACKEND_BASE_URL',
    defaultValue: '',
  );

  bool get isConfigured =>
      AppConfig.evmRpcUrl.isNotEmpty && AppConfig.bknTokenAddress.isNotEmpty;

  /// Sends an ERC-20 transfer using a backend signer.
  ///
  /// Expected backend API (you can implement later):
  /// POST {EVM_BACKEND_BASE_URL}/evm/erc20/transfer
  /// Body:
  /// {
  ///   "rpc_url": "...",
  ///   "chain": "base-sepolia",
  ///   "token_address": "0x...",
  ///   "from_private_key": "...",   // demo only
  ///   "to": "0x...",
  ///   "amount": "2.5"
  /// }
  /// Response:
  /// { "tx_hash": "0x..." }
  Future<String> transferErc20ViaBackend({
    required String fromPrivateKey,
    required String toWallet,
    required double amount,
  }) async {
    if (!isConfigured) {
      throw Exception(
        'On-chain not configured. Set EVM_RPC_URL and BKN_TOKEN_ADDRESS first.',
      );
    }
    if (evmBackendBaseUrl.isEmpty) {
      throw Exception(
        'No EVM backend configured. Set EVM_BACKEND_BASE_URL or use internal transfers.',
      );
    }

    final uri = Uri.parse('${evmBackendBaseUrl}/evm/erc20/transfer');

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'rpc_url': AppConfig.evmRpcUrl,
            'chain': AppConfig.evmChain,
            'token_address': AppConfig.bknTokenAddress,
            'from_private_key': fromPrivateKey,
            'to': toWallet,
            'amount': amount.toString(),
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'EVM backend error (${res.statusCode}): ${res.body}',
      );
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final txHash = data['tx_hash']?.toString();
    if (txHash == null || txHash.isEmpty) {
      throw Exception('EVM backend response invalid: ${res.body}');
    }
    return txHash;
  }
}
