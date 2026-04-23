import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart' as gauth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/oauth_config.dart';

/// Auth for Phase 3: primary identity is Google, with scopes sufficient for
/// Drive sync. Two code paths:
///
/// * **Mobile + web** → `google_sign_in`; token piped to googleapis via
///   `extension_google_sign_in_as_googleapis_auth`.
/// * **Desktop** (Win/Mac/Linux) → `googleapis_auth.clientViaUserConsent`
///   loopback flow. Requires [OAuthConfig.desktopClientId].
///
/// Firebase anon remains as an internal bridge for the legacy Firestore
/// importer; unrelated to Drive auth.
class AuthService {
  AuthService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: OAuthConfig.scopes);

  // Desktop state (kept in-memory; refresh token persisted in prefs).
  gauth.AccessCredentials? _desktopCredentials;
  // ignore: close_sinks
  final _desktopController = _LatestValueController<SignedInUser?>();

  static const _prefsKeyRefreshToken = 'canvas.desktop.refreshToken';
  static const _prefsKeyEmail = 'canvas.desktop.email';

  bool get isDesktopPlatform {
    if (kIsWeb) return false;
    final p = defaultTargetPlatform;
    return p == TargetPlatform.windows ||
        p == TargetPlatform.linux ||
        p == TargetPlatform.macOS;
  }

  /// Unified signed-in summary used by UI. Resolves to the Google account on
  /// mobile/web, or the desktop-fetched profile on desktop.
  Stream<SignedInUser?> watchSignedInUser() async* {
    if (isDesktopPlatform) {
      yield _desktopController.value;
      yield* _desktopController.stream;
    } else {
      yield _googleSignIn.currentUser == null
          ? null
          : SignedInUser.fromGoogleSignIn(_googleSignIn.currentUser!);
      yield* _googleSignIn.onCurrentUserChanged.map(
        (a) => a == null ? null : SignedInUser.fromGoogleSignIn(a),
      );
    }
  }

  SignedInUser? get currentUser {
    if (isDesktopPlatform) return _desktopController.value;
    final a = _googleSignIn.currentUser;
    return a == null ? null : SignedInUser.fromGoogleSignIn(a);
  }

  /// Returns an authenticated HTTP client usable with `googleapis`. Caller
  /// must close it. Throws if not signed in.
  Future<http.Client> authenticatedHttpClient() async {
    if (isDesktopPlatform) {
      final creds = await _ensureFreshDesktopCredentials();
      if (creds == null) {
        throw StateError('Not signed in (desktop).');
      }
      return gauth.authenticatedClient(http.Client(), creds);
    }

    GoogleSignInAccount? account = _googleSignIn.currentUser;
    account ??=
        await _googleSignIn.signInSilently(suppressErrors: true);
    if (account == null) {
      throw StateError('Not signed in.');
    }
    // Ensure required scopes are granted. Drive scope may be missing on
    // accounts that signed in under Phase 2 (email-only). `canAccessScopes`
    // is not implemented on every platform (e.g. some Android plugin builds
    // throw UnimplementedError); on that path fall back to requestScopes,
    // which is a no-op if already granted at sign-in time.
    bool needsRequest;
    try {
      needsRequest = !await _googleSignIn.canAccessScopes(OAuthConfig.scopes);
    } on UnimplementedError {
      needsRequest = false;
    }
    if (needsRequest) {
      final granted = await _googleSignIn.requestScopes(OAuthConfig.scopes);
      if (!granted) {
        throw StateError('Drive scope denied.');
      }
    }
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw StateError('Failed to obtain authenticated client.');
    }
    return client;
  }

  // --------------------------- sign in / out ---------------------------

  Future<SignedInUser?> signIn() async {
    if (isDesktopPlatform) return _signInDesktop();
    final account = await _googleSignIn.signIn();
    return account == null ? null : SignedInUser.fromGoogleSignIn(account);
  }

  Future<SignedInUser?> signInSilently() async {
    if (isDesktopPlatform) {
      final creds = await _ensureFreshDesktopCredentials();
      return creds == null ? null : _desktopController.value;
    }
    try {
      final account =
          await _googleSignIn.signInSilently(suppressErrors: true);
      return account == null
          ? null
          : SignedInUser.fromGoogleSignIn(account);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    if (isDesktopPlatform) {
      _desktopCredentials = null;
      _desktopController.add(null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKeyRefreshToken);
      await prefs.remove(_prefsKeyEmail);
      return;
    }
    await _googleSignIn.signOut();
  }

  // --------------------------- desktop flow ---------------------------

  Future<SignedInUser?> _signInDesktop() async {
    if (!OAuthConfig.isDesktopConfigured) {
      throw StateError(
        'Desktop OAuth client not configured. See lib/config/oauth_config.dart.',
      );
    }
    final clientId = gauth.ClientId(
      OAuthConfig.desktopClientId,
      OAuthConfig.desktopClientSecret.isEmpty
          ? null
          : OAuthConfig.desktopClientSecret,
    );
    final client = await gauth.clientViaUserConsent(
      clientId,
      OAuthConfig.scopes,
      (url) async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          debugPrint('Could not launch $url');
        }
      },
    );
    try {
      _desktopCredentials = client.credentials;
      final email = await _fetchEmailFromTokenInfo(client);
      final prefs = await SharedPreferences.getInstance();
      final refresh = client.credentials.refreshToken;
      if (refresh != null) {
        await prefs.setString(_prefsKeyRefreshToken, refresh);
      }
      if (email != null) {
        await prefs.setString(_prefsKeyEmail, email);
      }
      final user = SignedInUser.desktop(email: email ?? 'unknown');
      _desktopController.add(user);
      return user;
    } finally {
      client.close();
    }
  }

  Future<gauth.AccessCredentials?> _ensureFreshDesktopCredentials() async {
    if (_desktopCredentials != null &&
        _desktopCredentials!.accessToken.hasExpired == false) {
      return _desktopCredentials;
    }
    if (_desktopCredentials?.refreshToken != null) {
      final refreshed = await gauth.refreshCredentials(
        gauth.ClientId(
          OAuthConfig.desktopClientId,
          OAuthConfig.desktopClientSecret.isEmpty
              ? null
              : OAuthConfig.desktopClientSecret,
        ),
        _desktopCredentials!,
        http.Client(),
      );
      _desktopCredentials = refreshed;
      return refreshed;
    }
    // Try restoring from shared_preferences.
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(_prefsKeyRefreshToken);
    final email = prefs.getString(_prefsKeyEmail);
    if (refresh == null || !OAuthConfig.isDesktopConfigured) return null;
    try {
      final seed = gauth.AccessCredentials(
        gauth.AccessToken('Bearer', '', DateTime.now().toUtc()),
        refresh,
        OAuthConfig.scopes,
      );
      final refreshed = await gauth.refreshCredentials(
        gauth.ClientId(
          OAuthConfig.desktopClientId,
          OAuthConfig.desktopClientSecret.isEmpty
              ? null
              : OAuthConfig.desktopClientSecret,
        ),
        seed,
        http.Client(),
      );
      _desktopCredentials = refreshed;
      _desktopController.add(SignedInUser.desktop(email: email ?? 'unknown'));
      return refreshed;
    } catch (e) {
      debugPrint('Desktop credential refresh failed: $e');
      return null;
    }
  }

  Future<String?> _fetchEmailFromTokenInfo(gauth.AuthClient client) async {
    try {
      final r = await client.get(Uri.parse(
          'https://openidconnect.googleapis.com/v1/userinfo'));
      if (r.statusCode != 200) return null;
      final body = r.body;
      final match = RegExp(r'"email"\s*:\s*"([^"]+)"').firstMatch(body);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  // --------------------------- legacy bridge ---------------------------

  Future<fb.User?> ensureLegacyFirebaseUser() async {
    // Phase-6 gate: Firebase is torn down post-migration. If no app is
    // registered, the importer has nothing to bridge — bail quietly.
    if (Firebase.apps.isEmpty) return null;
    final auth = fb.FirebaseAuth.instance;
    if (auth.currentUser != null) return auth.currentUser;
    try {
      final cred = await auth.signInAnonymously();
      return cred.user;
    } catch (e) {
      debugPrint('legacy Firebase anon sign-in failed: $e');
      return null;
    }
  }
}

// ---------------------------------------------------------------------------

class SignedInUser {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isDesktop;

  const SignedInUser({
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isDesktop = false,
  });

  factory SignedInUser.fromGoogleSignIn(GoogleSignInAccount a) => SignedInUser(
        email: a.email,
        displayName: a.displayName,
        photoUrl: a.photoUrl,
      );

  factory SignedInUser.desktop({required String email}) =>
      SignedInUser(email: email, isDesktop: true);
}

/// Broadcast controller that remembers the last value so late subscribers
/// can catch up immediately (the signed-in user rarely changes; new widget
/// builds shouldn't have to wait for the next event).
class _LatestValueController<T> {
  final _ctrl = StreamController<T?>.broadcast();
  T? _value;

  T? get value => _value;
  Stream<T?> get stream => _ctrl.stream;
  void add(T? v) {
    _value = v;
    _ctrl.add(v);
  }
}
