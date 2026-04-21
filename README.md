# Canvas

Canvas is a lightweight notes app built with Flutter. It syncs notes in real time through Cloud Firestore, uses anonymous Firebase authentication so users can start writing immediately, and runs on Android, iOS, web, and desktop from a single codebase.

## Features

- Real-time sync across devices via Cloud Firestore
- Cross-platform: Android, iOS, web, Windows, macOS
- Dark UI
- Offline-capable through Firestore's built-in persistence
- Anonymous authentication so there is no sign-up friction

## Getting Started

```
flutter pub get
flutter run
```

## Project Structure

| Path | Purpose |
| --- | --- |
| `lib/screens` | Top-level UI screens (note list, editor). |
| `lib/providers` | Riverpod state providers wiring UI to services. |
| `lib/services` | Firebase/Firestore clients and app-level services. |
| `lib/models` | Plain data models (e.g. `Note`). |

## License

See [LICENSE](LICENSE).
