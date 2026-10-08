// Guards the two translation files against drifting apart: a key added to
// English but forgotten in Nepali would silently show a blank or crash at
// build time; a dead key is just clutter that translators still have to
// translate.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> _messages(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

Set<String> _placeholders(String message) =>
    RegExp(r'\{(\w+)\}').allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = _messages('lib/l10n/app_en.arb');
  final ne = _messages('lib/l10n/app_ne.arb');

  test('English and Nepali have exactly the same keys', () {
    expect(
      ne.keys.toSet().difference(en.keys.toSet()),
      isEmpty,
      reason: 'in Nepali but not English',
    );
    expect(
      en.keys.toSet().difference(ne.keys.toSet()),
      isEmpty,
      reason: 'in English but not Nepali',
    );
  });

  test('every message uses the same {placeholders} in both languages', () {
    for (final key in en.keys.where(ne.containsKey)) {
      expect(_placeholders(ne[key]!), _placeholders(en[key]!), reason: key);
    }
  });

  test('no message is empty', () {
    for (final entry in [...en.entries, ...ne.entries]) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('every key is used somewhere in the app (no dead translations)', () {
    // Everything under lib/ except the generated localization classes.
    final source = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('app_localizations'))
        .map((f) => f.readAsStringSync())
        .join('\n');

    final unused = en.keys
        .where((key) => !RegExp('\\.$key\\b').hasMatch(source))
        .toList();
    expect(unused, isEmpty, reason: 'unused translation keys');
  });
}
