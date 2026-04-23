# Future work

Deferred items from prior passes. No order implied.

- **Remove `flutter_staggered_animations` dep.** Stagger was stripped from the UI in the perf pass; package still sits in `pubspec.yaml`. Drop once nothing else imports it.
- **Live in-place markdown rendering (Obsidian-style).** Current editor toggles between rendered preview and raw source. A true live-render editor (headings styled inline while typing) would replace `_PreviewBody` + `BlockEditor`'s `TextBlock` with a composite rich editor. Large scope.
- **Attachments embedded in backup export.** Export currently includes attachment metadata (name/width/row) only. Blobs live in drift + Drive. A full self-contained backup would need to bundle the blob bytes (base64 inside the JSON, or a zip alongside the .json).
- **Phase 7 Firebase package teardown.** `firebase_core` / `firebase_auth` / `cloud_firestore` stay in the binary for one-shot legacy Firestore import. Drop them entirely once telemetry shows no pre-migration installs remain.
- **Drift DateTime precision.** Drift stores `DateTime` at epoch-second precision by default. Drive's `modifiedTime` is milliseconds. We currently truncate to seconds at the adapter boundary to make both sides match; long-term, flip drift to millisecond or ISO-text storage so nothing downstream has to compensate. Schema migration required.
- **Incremental `listRemote` via Drive `changes.list`.** Today every sync paginates all of `/canvas/notes/` and `/canvas/tombstones/`. With a stored `startPageToken` we could fetch only the delta, cutting auth-to-ready time further. Needs token storage + first-run full list.
- **Remove `BlobCount` from `local_sync.UsageInfo`.** Internal label leaked into the UI until the usage-card rewrite; the type field stays unused now. Drop it in the next `local_sync` pass.
- **Rendered-markdown-aware tap hit-testing in preview.** v0.8.6 maps preview tap → caret in the source text via a `TextPainter` on the raw markdown source. Rendered layout diverges from raw layout when the block contains headings, lists, or bold — tap offset can land off by a line or two. A real fix needs hit-test hooks inside `markdown_widget` (or a renderer that exposes `TextSpan`-level hit tests) to map tap → rendered-char → source-char.
- **First-class tag registry.** Tags are currently derived from notes (expand → toSet). Deleting the last carrier of a tag makes the tag vanish from filter bars and autosuggest. If we ever want rename-everywhere, keep-tags-around-empty, or tag colors, introduce a drift `TagRows` table with explicit tag lifecycle.
