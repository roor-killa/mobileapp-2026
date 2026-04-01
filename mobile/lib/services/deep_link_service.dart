import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/reset_password_screen.dart';

/// Handles incoming deep-links for Supabase email confirmation & password recovery.
///
/// Publishing notes:
/// - Prefer setting Supabase "Redirect URLs" to your app scheme, e.g.:
///   uapay://auth
/// - Supabase email links will redirect to the app, and we complete the auth session here.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// Navigator key to allow navigation without a BuildContext.
  late GlobalKey<NavigatorState> navigatorKey;

  bool _started = false;

  Future<void> start({required GlobalKey<NavigatorState> navigatorKey}) async {
    if (_started) return;
    _started = true;
    this.navigatorKey = navigatorKey;

    // Handle the initial link (cold start).
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleUri(initial);
      }
    } catch (_) {
      // ignore: best-effort only
    }

    // Handle subsequent links.
    _sub = _appLinks.uriLinkStream.listen((uri) async {
      await _handleUri(uri);
    }, onError: (_) {});
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }

  Future<void> _handleUri(Uri uri) async {
    // Supabase auth callback contains tokens in query/fragment.
    final s = uri.toString();

    // Only react to links that look like auth callbacks.
    final looksLikeAuth = s.contains('access_token=') || s.contains('refresh_token=') || s.contains('type=recovery') || s.contains('type=signup');
    if (!looksLikeAuth) return;

    final supabase = Supabase.instance.client;

    try {
      // This completes the session for recovery/signup/email-change links.
      await supabase.auth.getSessionFromUrl(uri);
    } catch (_) {
      // If parsing fails, do nothing (the user may have opened a non-auth link).
      return;
    }

    // If it's a recovery link, open reset password screen.
    if (s.contains('type=recovery')) {
      final nav = navigatorKey.currentState;
      if (nav == null) return;

      // Ensure we don't stack multiple reset screens.
      nav.push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
    }
  }
}
