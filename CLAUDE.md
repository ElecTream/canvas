# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Canvas — Flutter notes app. Firestore-backed, anonymous-auth only, single flat note list. Dark-only UI. Targets Android, iOS, web, macOS, Linux, Windows (all platform folders present).

## Commands

```bash
flutter pub get                   # install deps
flutter run                       # run on default device
flutter run -d chrome             # run web
flutter run -d windows            # run desktop
flutter analyze                   # lint (uses flutter_lints)
flutter test                      # run all tests
flutter test test/widget_test.dart  # single file
flutter build apk                 # android release
flutter build ios                 # ios release
flutter build web                 # web release

flutter pub run flutter_launcher_icons   # regen app icons from assets/icon.png
flutter pub run flutter_native_splash:create  # regen splash from assets/splash.png
```

Version bump: edit `pubspec.yaml` `version:` field, commit as `Version vX.Y.Z`.

## Architecture

Three-layer Riverpod stack. Read top-to-bottom when tracing a feature:

1. **Service layer** (`lib/services/`) — wraps Firebase SDK directly.
   - `AuthService`: anonymous sign-in, exposes `currentUser` + `authStateChanges`.
   - `NoteService`: Firestore CRUD under `users/{uid}/notes/{noteId}`. Uses `withConverter<Note>` so reads/writes are typed. `_userId` getter throws if no auth — stream subscribers see this as error state.

2. **Provider layer** (`lib/providers/`) — Riverpod providers wrapping services.
   - `initializationProvider` (FutureProvider) in `auth_provider.dart` — drives app boot. Returns `User?`. Signs in anonymously if no current user.
   - `notesStreamProvider` (StreamProvider<List<Note>>) — real-time note list ordered by `updatedAt` desc.
   - `packageInfoProvider` lives inline in `settings_screen.dart` (anomaly — move if expanding).

3. **Screen layer** (`lib/screens/`) — `ConsumerWidget` / `ConsumerStatefulWidget`.
   - `main.dart` watches `initializationProvider.when()` → shows `SplashScreen` on loading, `HomeScreen` on data. **Null user in `data` branch still routes to HomeScreen** — `NoteService` will then throw at stream subscription.
   - `HomeScreen` → `NoteEditorScreen` via `Navigator.push` (no named routes).
   - `NoteEditorScreen` has dual-mode (new vs edit) keyed on nullable `widget.note`. Save on check-icon tap, delete-on-empty if editing.

## Data model

`Note` (`lib/models/note.dart`): `id` (uuid v4), `title`, `content`, `createdAt`, `updatedAt` — last two are Firestore `Timestamp`. Serialized via hand-written `toJson`/`fromJson`. Fields mutable.

`lib/models/note.g.dart` is a stale Hive `TypeAdapter` — **not wired in, not compiled, references non-existent `DateTime` fields**. Safe to delete; ignore if present.

## Firebase

- Config generated into `lib/firebase_options.dart` (committed). Project id: `canvas-elec`.
- `firebase.json` at root drives FlutterFire CLI regen (`flutterfire configure`).
- Firestore path convention: `users/{uid}/notes/{noteId}`. Security rules are **not** in repo — verify in Firebase console before shipping.
- No Crashlytics, no App Check, no Remote Config wired.

## Theming

Dark-only. `ColorScheme.fromSeed(Colors.deepPurple, dark)` but AppBar + Card hard-code `Colors.blueGrey[800/900]` — palette is inconsistent. Scaffold bg `#1A1A1A`. Fonts: Google Fonts Lato fetched at runtime (not bundled).

## Tests

`test/widget_test.dart` is the default Flutter counter template — **it does not match the app** and will fail if run against `MyApp` (no `ProviderScope`, no Firebase init). Treat as placeholder.

## Gotchas

- `NoteService._userId` evaluated lazily at stream subscription — auth change mid-session leaves stale stream.
- `Timestamp.now()` is set client-side in `saveNote`; clock skew affects list order.
- `auth_service.dart` swallows sign-in errors (`print` + return null) → offline first launch silently lands on HomeScreen with broken stream.
- `flutter_markdown` listed in `pubspec.yaml` but not imported anywhere. Package is discontinued upstream.
- `google_fonts` loads font files over HTTP on first paint; add asset bundling if offline-first matters.
