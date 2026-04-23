import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canvas/widgets/markdown_input_helpers.dart';

TextEditingValue _v(String text, int cursor) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    );

void main() {
  group('applyEnterHelper', () {
    test('continues dash bullet', () {
      final before = _v('- foo', 5);
      final after = _v('- foo\n', 6);
      final result = applyEnterHelper(before, after);
      expect(result.text, '- foo\n- ');
      expect(result.selection.baseOffset, 8);
    });

    test('continues asterisk bullet', () {
      final before = _v('* foo', 5);
      final after = _v('* foo\n', 6);
      final result = applyEnterHelper(before, after);
      expect(result.text, '* foo\n* ');
    });

    test('continues numbered list incrementing the counter', () {
      final before = _v('1. apple', 8);
      final after = _v('1. apple\n', 9);
      final result = applyEnterHelper(before, after);
      expect(result.text, '1. apple\n2. ');
      expect(result.selection.baseOffset, 12);
    });

    test('continues unchecked checkbox as empty checkbox', () {
      final before = _v('- [ ] task', 10);
      final after = _v('- [ ] task\n', 11);
      final result = applyEnterHelper(before, after);
      expect(result.text, '- [ ] task\n- [ ] ');
    });

    test('continues checked checkbox as empty checkbox', () {
      final before = _v('- [x] done', 10);
      final after = _v('- [x] done\n', 11);
      final result = applyEnterHelper(before, after);
      expect(result.text, '- [x] done\n- [ ] ');
    });

    test('empty bullet exits the list', () {
      final before = _v('- ', 2);
      final after = _v('- \n', 3);
      final result = applyEnterHelper(before, after);
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('empty numbered marker exits the list', () {
      final before = _v('1. ', 3);
      final after = _v('1. \n', 4);
      final result = applyEnterHelper(before, after);
      expect(result.text, '');
    });

    test('non-list line is untouched', () {
      final before = _v('plain line', 10);
      final after = _v('plain line\n', 11);
      final result = applyEnterHelper(before, after);
      expect(result, after);
    });

    test('multi-char insert is untouched', () {
      final before = _v('- foo', 5);
      final after = _v('- foo bar', 9);
      expect(applyEnterHelper(before, after), after);
    });

    test('preserves indent on nested bullet', () {
      final before = _v('  - nested', 10);
      final after = _v('  - nested\n', 11);
      final result = applyEnterHelper(before, after);
      expect(result.text, '  - nested\n  - ');
    });
  });
}
