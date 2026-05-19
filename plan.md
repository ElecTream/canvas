# Canvas Editor — Selection Bleed Resolution Plan

## The problem

Inside a multi-line Flutter `TextField`, every line's selection rect is sized to the paragraph's longest line, not to the line's own glyph width. Tapping a short word on a short line produces a selection that visually extends across whitespace to the longest line's right edge. This is intrinsic to how `RenderEditable` paints selection in multi-line text; `BoxWidthStyle.tight` and any selection-range trimming cannot reach the painter from outside.

Investigation already exhausted these dead-ends in earlier sessions of this conversation:
- `IntrinsicWidth` per `TextField` — shrinks the field, doesn't fix per-line selection.
- Listener-based selection trim (drop trailing `\n` / whitespace) — no effect because the cause is painter behavior, not selection content.
- Setting `selectionWidthStyle: BoxWidthStyle.tight` explicitly — already the default; no change.

## Choices

1. **Live with it.** Flutter behavior, present in most Flutter notes apps. Cost: 0. Trade: visual polish gap vs. Keep.
2. **Per-line `TextField` restructure.** Each visual source line becomes a single-line `TextField`. Cost: medium. Trade: breaks multi-line drag-select across lines.
3. **Migrate to `super_editor`.** Replace the block editor with a real document model. Cost: high. Trade: ~20–30 hours work, keyboard stack revalidation, possible new regressions.
4. **Native `EditText` via PlatformView.** Cost: very high. Android-only; breaks multi-platform parity. Crossed off.

Sections below detail the work required for option 3 if chosen. Option 2 is sketched at the end.

---

## Option 3: super_editor migration

### Currently in place (TextField stack)

| Concern | Current implementation | Files |
|---|---|---|
| Per-line text input | One `TextField` per `_Entry`, controller = `MarkdownInputController`, focus = `FocusNode` | `lib/widgets/block_editor.dart` |
| Bullet / numbered / checkbox continuation on Enter | `applyEnterHelper` regex in controller `set value` | `lib/widgets/markdown_input_helpers.dart` |
| Inline image blocks | `_Entry.image` with width fraction, newRow flag, custom resize handle | `lib/widgets/block_editor.dart:614-775` |
| Image row layout | `_ImageRow` `Wrap` with `newRow` breaks | `lib/widgets/block_editor.dart:614` |
| Image menu (edit / size / move / remove) | `_showImageMenu` bottom sheet | `lib/widgets/block_editor.dart:316` |
| Save serialization | `_serialize()` → `List<NoteBlock>` (TextBlock / ImageBlock) | `lib/widgets/block_editor.dart:111` |
| Initial load deserialization | `_buildEntries(initialBlocks)` | `lib/widgets/block_editor.dart:80` |
| Focus across structural changes | `focusLastTextBlock`, `focusTextBlockAt`, post-frame requestFocus | `lib/widgets/block_editor.dart:440-471` |
| Tap-to-edit from preview mode | `GlobalKey<BlockEditorState>` → `focusTextBlockAt(idx, charOffset)` | `lib/screens/note_editor_screen.dart:89-101` |
| Preview rendering | `MarkdownBlock` per text entry, `Image.file` per image | `lib/screens/note_editor_screen.dart:505-625` |
| Lifecycle keyboard fix (just shipped) | `FocusManager.instance.primaryFocus?.unfocus()` on background | `lib/main.dart:62-69` |
| Dangling `_activeText` fix (just shipped) | Null-out on entry disposal | `lib/widgets/block_editor.dart:219` |
| Post-image-menu refocus fix (just shipped) | `addPostFrameCallback` instead of `microtask` | `lib/widgets/block_editor.dart:423` |

### What needs to be built / rewritten

#### A. Dependency + bootstrapping

- Add `super_editor` to `pubspec.yaml`. Pin to a known-good version; the API has churned across minor versions.
- Add `super_editor_markdown` for markdown serialization (optional but reduces custom work).
- Audit the resulting transitive dependency tree against current deps (especially anything that touches `flutter/services`).

#### B. Data model translation

`Note.blocks` (`List<NoteBlock>`) stays as the persisted shape. We add a translation boundary:

- `documentFromNoteBlocks(List<NoteBlock>)` → `MutableDocument` with:
  - `TextBlock` → `ParagraphNode` (with `AttributedText`). Heading / list / checkbox info needs to be recognized from markdown markers in the text and either:
    - kept as inline markers (simpler, keeps current "what you see is what you save" round-trip), or
    - promoted to `header1Node` / `ListItemNode` / `TaskNode` (cleaner long-term, but changes the round-trip — heading-level info now lives in node type, not in `#` prefix).
  - `ImageBlock` → custom `ImageBlockNode` (see C).
- `noteBlocksFromDocument(MutableDocument)` → reverse direction for save.
- Both functions need round-trip property tests so we don't lose data on save/load cycles.
- Decision needed: do we keep markdown as the source of truth in the text, or migrate to node-type-driven structure? The first is incremental, the second is a real schema change.

#### C. Custom image component

super_editor has no built-in image-with-row-layout-and-resize component, so we author one:

- `ImageBlockNode extends DocumentNode` with: `name`, `width` (0..1 fraction), `newRow` (bool). Mirrors `ImageBlock`.
- `ImageComponentBuilder` returning a widget that renders the image via `imageServiceProvider`, listens to revision (per the existing `revisionFor` ChangeNotifier pattern), supports:
  - Tap → open viewer (`openImageViewer` from `image_viewer.dart`).
  - Long-press → image menu sheet (port `_showImageMenu`).
  - Right-edge drag handle → width fraction update.
- Multi-image row layout: super_editor renders one node per row by default. To preserve the current `_ImageRow` `Wrap` behavior (adjacent images on the same row unless `newRow`), we either:
  - Author a custom row-grouping layout that consumes consecutive `ImageBlockNode`s with `newRow == false` and lays them side-by-side, or
  - Drop the multi-per-row feature and put each image on its own row (visual regression — confirm before committing).
- Hero animation tag (`image-${file.path}`) preserved for tap-to-viewer transition.

#### D. List continuation behavior

`MarkdownInputController.applyEnterHelper` handles:
- Empty checkbox / bullet / numbered line on Enter → exit list (strip marker).
- Non-empty list line on Enter → insert continuation marker.

Two paths:

1. **Keep markdown markers inline.** Hook into super_editor's input pipeline (`SuperEditorImePolicy` or a custom `DocumentKeyboardAction`) to intercept Enter and run the same regex logic against the current paragraph's text. Reuses the existing `applyEnterHelper` function almost verbatim. Lowest risk.
2. **Promote to node types.** Use super_editor's `ListItemNode` (bullet / ordered) and `TaskNode` (checkbox). Configure their Enter behavior via super_editor's built-in actions. Schema change for persistence (see B).

Recommend path 1 unless we're also doing the schema migration in B.

#### E. Focus + cursor positioning

Currently `NoteEditorScreen` calls `_blockEditorKey.currentState?.focusTextBlockAt(idx, charOffset)` to deep-link from preview-mode tap → source-mode caret position.

With super_editor:
- One `DocumentEditor` per note instead of N `TextField`s. One selection.
- `focusTextBlockAt(idx, charOffset)` becomes "find the Nth `ParagraphNode`, set `DocumentSelection.collapsed(position: DocumentPosition(nodeId: id, nodePosition: TextNodePosition(offset: charOffset)))`".
- `focusLastTextBlock()` becomes the same against the last `ParagraphNode`.
- `_activeText` tracking is no longer needed — super_editor maintains selection.

#### F. Autosave + dirty tracking

Currently `controller.addListener(_notifyChanged)` per `TextField` → `onChanged(_serialize())` → `_onBlocksChanged` → `_recomputeDirty` → 2s debounce → `_silentSave`.

With super_editor:
- Listen to `DocumentEditor`'s document change stream.
- Re-serialize to `List<NoteBlock>` via `noteBlocksFromDocument`.
- Reuse existing debounce + `_silentSave` in `note_editor_screen.dart`.
- Verify `_persistedId` duplicate-row guard still holds — should, since it's keyed on save callback, not on the editor.

#### G. Preview mode

Two paths:

1. **Keep the toggle.** Preview renders `MarkdownBlock` from serialized text per node, edit renders super_editor. Same UX as today.
2. **Drop the toggle.** Use super_editor in read-only mode for preview (no caret, no IME). Cleaner UX, less code. Requires that super_editor's read-only rendering matches the current markdown_widget output visually — needs a side-by-side comparison before committing.

#### H. Tag chips

Lives outside the editor (`TagChipInput` in the column above). Unaffected by the migration. Verify focus behavior still works (tag chip focus → editor focus transitions).

#### I. Lifecycle + keyboard regressions

The lifecycle fix shipped this session (`FocusManager.instance.primaryFocus?.unfocus()` on background) is `TextField`-agnostic — it operates on the FocusManager, not on TextField specifically. Should still work, but **must be verified** on the super_editor stack: background the app with the editor focused, return, attempt to type. If super_editor's IME re-attach behavior differs, may need to adjust.

Dangling-pointer fix and post-frame refocus fix are `block_editor.dart`-internal and get deleted with the rewrite. Their underlying concerns (don't dispose focused state without clearing references; don't `requestFocus` during a frame in flight) are super_editor's problem to handle; verify by running the same repros.

#### J. Hero animation between list and editor

`HomeScreen` → `NoteEditorScreen` uses Hero with `heroTag: 'note-${id}'` on `GlassCard`. This wraps the entire editor body. Should be unaffected as long as the GlassCard layout remains. Verify there's no measurable rebuild jank when super_editor mounts inside a Hero.

#### K. Image-related side effects

- `ImageService` `ChangeNotifier` + per-name revision counter (`revisionFor`) — keep as-is, custom image component subscribes to it.
- `attachment_strip.dart` (carousel below editor) — unaffected, lives outside the editor.
- Desktop drag-drop (`_onDesktopDrop` in `note_editor_screen.dart`) — unaffected, adds to attachments via `_attachName`, no editor coupling.
- `insertImageAtCursor` / `removeAllImages` API on `BlockEditorState` — replaced by super_editor document mutations.

#### L. Cross-platform validation

- **Android phone** — primary device, most important. Repro the original IME bug (background → resume), test selection on short/long/wrapped lines.
- **iOS** — super_editor's iOS history is rockier than Android. If iOS isn't a near-term target, defer; otherwise budget extra time.
- **Web** — super_editor web rendering is functional but has different IME handling. Verify text input + selection.
- **Desktop (Windows / macOS / Linux)** — keyboard shortcuts, mouse selection, drag handles for images.

#### M. Bundle size + perf

- Web bundle grows; check with `flutter build web --analyze-size`. Probably tolerable; note the delta.
- Mobile APK growth; check with `flutter build apk --analyze-size`. Likely small.
- Mount cost of super_editor on note open — measure first-paint latency on a 100-block note before merging.

### Effort estimate

| Phase | Hours |
|---|---|
| Spike: drop super_editor into a throwaway screen, load a sample note, test selection + keyboard + IME-on-resume | 3–4 |
| Dependency add, transitive audit, basic editor instantiation | 1–2 |
| Document ↔ NoteBlock translation + round-trip tests | 3–4 |
| Custom image component (no row grouping yet) | 3–4 |
| Image row grouping (or decision to drop) | 2–3 |
| List continuation (path 1, port existing regex) | 2–3 |
| Focus / cursor positioning rewire | 2 |
| Autosave + dirty tracking rewire | 1–2 |
| Preview mode decision + implementation | 1–3 |
| Lifecycle keyboard regression verification + fixes | 2–4 |
| Cross-platform smoke tests + bugfixes | 3–5 |
| Regression sweep against existing repros | 2–3 |
| **Total** | **25–39** |

Realistic calendar: 4–6 evening sessions if focused.

### Risk register

1. **super_editor IME / keyboard regressions** — historically rocky on mobile. The user has recalled keyboard issues with it from a prior context. This is the single biggest risk; the spike phase exists to surface it before committing.
2. **Image component complexity** — drag-resize handle + row grouping + revision-aware repaint is non-trivial inside super_editor's component system. Could be a 1–2x time overrun.
3. **API churn** — super_editor's API has shifted across minor versions. Pinning is mandatory; upgrading later costs.
4. **Round-trip data loss** — Document → NoteBlock → Document must be lossless. Need property tests.
5. **Web behavior divergence** — if web is a target, expect bugs not present on Android.
6. **1.0 delay** — Canvas is at 0.9.12 polishing for 1.0; this is a multi-evening detour from that goal. If 1.0 is on a deadline, this should wait.
7. **`MarkdownInputController` regex tests** — none exist yet; the existing logic is essentially untested. Migration would be a good time to add tests, but that's additional scope.

### Suggested execution order

1. **Spike first (3–4 hours, throwaway branch).** Drop super_editor into a new screen, load a real sample note, test:
   - Selection on short/long/wrapped lines.
   - IME-on-resume behavior (background-foreground cycle).
   - Multi-line drag-select.
   - Soft keyboard behavior (Gboard).
   - If any of these are broken in ways we can't fix from the outside, stop here.
2. **If spike passes:** translation layer + tests, then editor instantiation in the real screen behind a flag (`useSuperEditor: true`).
3. **Image component.** Build to feature parity with current. Decide row-grouping in/out.
4. **List continuation port.** Reuse `applyEnterHelper`.
5. **Focus, autosave, preview wire-up.**
6. **Lifecycle regression sweep.** Re-run the keyboard-IME repros from this session.
7. **Cross-platform sweep.**
8. **Remove the feature flag, delete `block_editor.dart`, delete `markdown_input_helpers.dart` if list logic moved.**

---

## Option 2: Per-line TextField restructure (alternative)

If super_editor is too big a swing, this is the in-between.

- `_Entry.text` invariant: text contains no `\n`. One TextField per source line.
- `_buildEntries` splits each `TextBlock.text` by `\n` into multiple text entries.
- `_serialize` groups consecutive text entries, joins with `\n`, emits one `TextBlock` per group.
- Enter handling: controller listener detects `\n` insertion; split current line at the position, create new entry below, focus it.
- Backspace at offset 0: `Focus` widget with `onKeyEvent` catches `LogicalKeyboardKey.backspace`; if cursor at 0, append current text to previous entry, dispose current.
- Arrow up/down: same `Focus` widget; arrow → focus prev/next entry at matching column.
- `MarkdownInputController.applyEnterHelper` retired — its job moves into the new Enter handler.
- Tap targets to the right of short lines: wrap each `TextField` row in a `GestureDetector` that `requestFocus`-es the line on tap.
- Multi-line drag-select: **broken** (no cross-field selection in Flutter without writing a custom selection coordinator). User has said multi-line bleed is acceptable, but losing the ability entirely is a different trade.

Effort: 8–12 hours.

Risk: medium. Soft-keyboard backspace handling is fiddly (some IMEs don't send a `KeyEvent` for backspace, only modify controller text).

---

## Option 1: Live with it

Cost: 0. Ship 1.0. Note in CHANGELOG that text selection has a known visual quirk on multi-line blocks; revisit post-1.0 if it bothers enough.
