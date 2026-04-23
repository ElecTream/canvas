import 'package:flutter/widgets.dart';

/// Markdown-flavored input helpers: bullet / numbered / checkbox
/// continuation on Enter, and exit-on-empty when the user hits Enter on a
/// line that has only the list marker.
///
/// Pure logic lives in [applyEnterHelper] so it can be unit-tested without a
/// TextField. [MarkdownInputController] is a drop-in
/// [TextEditingController] that applies the helper on every value change.
TextEditingValue applyEnterHelper(
    TextEditingValue oldValue, TextEditingValue newValue) {
  // We only care about single-character inserts that were newlines. Anything
  // else (paste, multi-char composition, backspace, selection delete) falls
  // through untouched.
  final grew = newValue.text.length == oldValue.text.length + 1;
  if (!grew) return newValue;

  final cursor = newValue.selection.baseOffset;
  if (cursor <= 0) return newValue;
  if (newValue.text[cursor - 1] != '\n') return newValue;

  final before = newValue.text.substring(0, cursor - 1);
  final lineStart = before.lastIndexOf('\n') + 1;
  final line = before.substring(lineStart);

  final checkbox = RegExp(r'^(\s*)([-*+])\s\[([ xX])\]\s(.*)$');
  final bullet = RegExp(r'^(\s*)([-*+])\s(.*)$');
  final numbered = RegExp(r'^(\s*)(\d+)\.\s(.*)$');

  final mCheck = checkbox.firstMatch(line);
  if (mCheck != null) {
    final indent = mCheck.group(1)!;
    final marker = mCheck.group(2)!;
    final content = mCheck.group(4)!;
    if (content.isEmpty) {
      return _exitList(newValue, lineStart, cursor);
    }
    return _insertAtCursor(newValue, cursor, '$indent$marker [ ] ');
  }

  final mBullet = bullet.firstMatch(line);
  if (mBullet != null) {
    final indent = mBullet.group(1)!;
    final marker = mBullet.group(2)!;
    final content = mBullet.group(3)!;
    if (content.isEmpty) {
      return _exitList(newValue, lineStart, cursor);
    }
    return _insertAtCursor(newValue, cursor, '$indent$marker ');
  }

  final mNum = numbered.firstMatch(line);
  if (mNum != null) {
    final indent = mNum.group(1)!;
    final num = int.tryParse(mNum.group(2)!) ?? 1;
    final content = mNum.group(3)!;
    if (content.isEmpty) {
      return _exitList(newValue, lineStart, cursor);
    }
    return _insertAtCursor(newValue, cursor, '$indent${num + 1}. ');
  }

  return newValue;
}

TextEditingValue _insertAtCursor(
    TextEditingValue value, int cursor, String insertion) {
  final newText = value.text.substring(0, cursor) +
      insertion +
      value.text.substring(cursor);
  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: cursor + insertion.length),
    composing: TextRange.empty,
  );
}

// Empty list marker on Enter → strip the marker line entirely so the cursor
// lands on a clean blank line at the same indent level. The inserted newline
// is also dropped because the marker was the only content on that line.
TextEditingValue _exitList(
    TextEditingValue value, int lineStart, int cursor) {
  final newText =
      value.text.substring(0, lineStart) + value.text.substring(cursor);
  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: lineStart),
    composing: TextRange.empty,
  );
}

/// TextEditingController that runs [applyEnterHelper] on every assignment.
class MarkdownInputController extends TextEditingController {
  MarkdownInputController({super.text});

  TextEditingValue _last = TextEditingValue.empty;

  @override
  set value(TextEditingValue newValue) {
    final transformed = applyEnterHelper(_last, newValue);
    _last = transformed;
    super.value = transformed;
  }
}
