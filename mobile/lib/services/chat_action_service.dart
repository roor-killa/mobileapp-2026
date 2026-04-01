import 'supabase_service.dart';

class ChatActionService {
  ChatActionService({SupabaseService? api}) : _api = api ?? SupabaseService();

  final SupabaseService _api;
  Map<String, dynamic>? _pendingTransfer;

  Future<String?> handleMessage(String message) async {
    final text = message.trim();
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();

    // Step 1: confirmation / cancellation for pending transfer
    if (_pendingTransfer != null) {
      if (_isConfirm(lower)) {
        final pending = _pendingTransfer!;
        _pendingTransfer = null;

        final res = await _api.transferToUserId(
          toUserId: pending['toUserId'] as String,
          amount: pending['amount'] as double,
        );

        final ok = res['success'] == true || res['ok'] == true;
        final msg = (res['message'] ?? (ok ? 'Transfert réussi.' : 'Transfert échoué.')).toString();
        final name = (pending['displayName'] ?? 'le destinataire').toString();
        return ok ? '✅ $msg\nTransfert de ${_formatAmount(pending['amount'] as double)} BKN vers $name.' : '❌ $msg';
      }

      if (_isCancel(lower)) {
        _pendingTransfer = null;
        return 'Transfert annulé.';
      }

      final pending = _pendingTransfer!;
      final displayName = (pending['displayName'] ?? 'le destinataire').toString();
      return 'Un transfert de ${_formatAmount(pending['amount'] as double)} BKN vers $displayName est en attente. Réponds "oui" pour confirmer ou "non" pour annuler.';
    }

    // Step 2: detect transfer request intent
    if (!_looksLikeTransfer(lower)) return null;

    final parsed = _parseTransferMessage(text);
    if (parsed == null) {
      return 'Je peux lancer un transfert. Exemple : "Envoie 10 BKN à majd@email.com".';
    }

    final amount = parsed.amount;
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0.';
    }

    final recipientText = parsed.recipient;
    final me = _api.currentUserId;

    String? toUserId;
    String displayName = recipientText;

    if (_looksLikeEmail(recipientText)) {
      toUserId = await _api.userIdByEmail(recipientText);
      if (toUserId == null || toUserId.isEmpty) {
        return 'Utilisateur introuvable pour cet email.';
      }

      final prof = await _api.getPublicProfileByUserId(toUserId);
      displayName = _displayNameFromProfile(prof) ?? recipientText;
    } else {
      final users = await _api.searchUsersByName(recipientText);
      if (users.isEmpty) {
        return 'Aucun utilisateur trouvé pour "$recipientText".';
      }
      if (users.length > 1) {
        final names = users.take(3).map((u) => _displayNameFromProfile(u) ?? 'Utilisateur').join(', ');
        return 'Plusieurs utilisateurs correspondent : $names. Sois plus précis (nom complet ou email).';
      }
      final user = users.first;
      toUserId = user['id']?.toString();
      displayName = _displayNameFromProfile(user) ?? recipientText;
    }

    if (toUserId == null || toUserId.isEmpty) {
      return 'Impossible de résoudre le destinataire.';
    }

    if (me != null && toUserId == me) {
      return "Tu ne peux pas t'envoyer de BKN à toi-même.";
    }

    _pendingTransfer = {
      'toUserId': toUserId,
      'amount': amount,
      'displayName': displayName,
    };

    return 'Je suis prêt à envoyer ${_formatAmount(amount)} BKN à $displayName. Réponds "oui" pour confirmer ou "non" pour annuler.';
  }

  bool _looksLikeTransfer(String lower) {
    return lower.contains('transfer') ||
        lower.contains('send') ||
        lower.contains('envoyer') ||
        lower.contains('envoie') ||
        lower.contains('payer') ||
        lower.contains('paie ');
  }

  bool _isConfirm(String lower) {
    const words = {'yes', 'oui', 'confirm', 'confirmer', 'ok', 'okay', 'vas-y', 'go'};
    return words.contains(lower);
  }

  bool _isCancel(String lower) {
    const words = {'no', 'non', 'cancel', 'annuler', 'stop'};
    return words.contains(lower);
  }

  bool _looksLikeEmail(String text) => text.contains('@');

  _ParsedTransfer? _parseTransferMessage(String text) {
    final amountMatch = RegExp(r'(\d+(?:[\.,]\d+)?)').firstMatch(text);
    if (amountMatch == null) return null;

    final amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', '.'));
    if (amount == null) return null;

    String recipient = text;
    // Dart RegExp does NOT support inline flags like (?i).
    // Use caseSensitive:false instead.
    recipient = recipient.replaceAll(
      RegExp(r'\b(send|transfer|envoyer|envoie|payer|paie|bkn|to|à|a)\b', caseSensitive: false),
      ' ',
    );
    recipient = recipient.replaceFirst(RegExp(r'(\d+(?:[\.,]\d+)?)'), ' ');
    recipient = recipient.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (recipient.isEmpty) return null;
    return _ParsedTransfer(amount: amount, recipient: recipient);
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
  }

  String? _displayNameFromProfile(Map<String, dynamic>? profile) {
    if (profile == null) return null;
    final prenom = (profile['prenom'] ?? '').toString().trim();
    final nom = (profile['nom'] ?? '').toString().trim();
    final full = '$prenom $nom'.trim();
    if (full.isNotEmpty) return full;
    final tel = (profile['telephone'] ?? '').toString().trim();
    if (tel.isNotEmpty) return tel;
    return null;
  }
}

class _ParsedTransfer {
  const _ParsedTransfer({required this.amount, required this.recipient});

  final double amount;
  final String recipient;
}
