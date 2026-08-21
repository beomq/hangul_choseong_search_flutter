## 0.1.0

### Source-compatible additions

- Added `matchesByChoseong` for checking one candidate without creating a list.
- Added `filterByChoseongKey` for filtering typed domain objects through a string key.
- Kept the package name, import URI, `getChoseong(String)`, and `filterByChoseong(List<String>, String)` signatures unchanged.
- Removed the Flutter SDK dependency. The package now runs as pure Dart and remains usable from Flutter applications.
- Added support for equivalent valid modern Hangul written as precomposed syllables, conjoining jamo, compatibility jamo, or halfwidth jamo.

### Intentional semantic changes

- Complete modern Hangul syllables in a query now match literally. For example, `filterByChoseong(['라면', '리모컨'], '라')` returns `['라면']`. Use the standalone initial query `ㄹ` to match both values.
- Case-insensitive matching now folds only ASCII `A` through `Z`. Non-ASCII, non-Hangul characters compare literally. For example, `strasse` doesn't match `Straße`, and ASCII `abc` doesn't match fullwidth `ＡＢＣ`.
- An empty query still selects every item, but filtering now returns a new growable list instead of the original list. Code that relied on result identity must retain the source list explicitly.
- Search remains contiguous and unranked. Spaces, punctuation, digits, emoji, and unmatched characters aren't skipped.

### Migration examples

```dart
// 0.0.4 could treat a complete syllable as only its initial.
// 0.1.0 uses a complete syllable literally.
filterByChoseong(['라면', '리모컨'], '라'); // ['라면']

// Use a standalone choseong for initial-consonant wildcard matching.
filterByChoseong(['라면', '리모컨'], 'ㄹ'); // ['라면', '리모컨']

// The result of an empty query is an independent, growable copy.
final source = ['라면'];
final result = filterByChoseong(source, '');
result.add('리모컨');
// source is still ['라면'].
```

## 0.0.4

- Fixed bugs.

## 0.0.3

- Enhanced mixed query search functionality to support combinations of Korean choseong and English, such as `ㅅㄱa` matching `사과apple`.
- Improved accuracy of partial matches for mixed Korean and English strings.
- Fixed incorrect filtering of mixed-character input.

## 0.0.2

- Added partial choseong matching, such as `라ㅁ` matching `라면`.
- Improved mixed-query search.

## 0.0.1

- Initial release.
