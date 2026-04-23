/// OAuth client configuration for Drive sync.
///
/// Fill these in before Phase 3 sign-in will work. Create OAuth clients in
/// Google Cloud Console (https://console.cloud.google.com/apis/credentials)
/// under the same `canvas-elec` project Firebase already uses:
///
/// 1. **Android** — "OAuth client ID" → Android. Fingerprint = SHA-1 of the
///    debug/release keystore (`gradlew signingReport`). Package = the
///    applicationId in android/app/build.gradle.kts. No value needed here;
///    this is picked up automatically via google-services.json.
///
/// 2. **Desktop** — "OAuth client ID" → Desktop app. Paste the Client ID
///    into [desktopClientId]. (Desktop "installed app" clients don't use
///    a client secret; leave [desktopClientSecret] empty.)
///
/// 3. **Web** (optional, only if you build for web) — paste Client ID into
///    [webClientId] and add it to the web entrypoint.
///
/// Enable the Google Drive API on the same project:
/// https://console.cloud.google.com/apis/library/drive.googleapis.com
class OAuthConfig {
  static const String desktopClientId = '';
  static const String desktopClientSecret = '';
  static const String webClientId = '';

  /// Drive scope: app-scoped access only. App can only see files it creates.
  static const String driveFileScope =
      'https://www.googleapis.com/auth/drive.file';
  static const String emailScope = 'email';

  static const List<String> scopes = [emailScope, driveFileScope];

  static bool get isDesktopConfigured => desktopClientId.isNotEmpty;
}
