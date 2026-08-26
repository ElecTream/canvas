# Canvas

A clean notes app. Local-first on device; Google Sign-In and leftover Firebase still live in the tree.

| | |
| --- | --- |
| **Brand** | ElecTream |
| **Listing** | Canvas |
| **Package** | `com.electream.canvas` |
| **Version** | 0.9.17 (add `+build` before Play; GitHub release lag is v0.5.1) |
| **Platforms** | Android + iOS folders; Play is the first ship |
| **License** | GPL-3.0 |

## What it does

- Notes with a dark UI, markdown, and images (camera / picker / crop)
- Local storage via Drift/SQLite and the sibling `local_sync` package (`path: ../local_sync` — that package is **not** inside this repo)
- Google Sign-In is wired; Firebase Auth/Firestore remain as a legacy import path

The old README described anonymous Firestore sync. That is not the current `pubspec.yaml`.

## Run

Needs `../local_sync` checked out next to this repo:

```sh
flutter pub get
flutter run
```

## Docs

| File | What it is |
| --- | --- |
| [PRIVACY.md](PRIVACY.md) | Privacy policy (host a public copy for Play) |
| [STORE.md](STORE.md) | Play listing copy, Data safety, upload checklist |
| [CHANGELOG.md](CHANGELOG.md) | Version history (stale vs 0.9.17) |
