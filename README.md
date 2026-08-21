# Hangul Choseong Search

`hangul_choseong_search` is a pure Dart package for choseong (initial consonant) search in Korean text. It works in Dart and Flutter apps and has no runtime dependencies.

## What is choseong search?

A modern Hangul syllable is a block built from an initial consonant, a vowel, and sometimes a final consonant. For example, `라` starts with `ㄹ`, while `면` starts with `ㅁ`. A choseong query can search for those initials without spelling the full syllables.

This package treats a complete syllable and a standalone initial differently:

* `라` is literal. It matches the syllable `라`, not every syllable beginning with `ㄹ`.
* `ㄹ` is an initial-consonant wildcard. It matches `라`, `리`, `로`, and other modern syllables whose initial is `ㄹ`.
* `라ㅁ` combines both rules. It matches a literal `라` followed by a syllable beginning with `ㅁ`, such as `라면`.
* `ㅅㄱa` mixes initials and ASCII text. It matches `사과Apple` because its normalized units begin with `ㅅ`, `ㄱ`, and `a`.

Matching is contiguous and unranked. The package doesn't skip characters between query units.

## Installation

Version 0.1.0 requires Dart 3.5.3 or later, before Dart 4.0.0.

For a Dart package or application:

```console
dart pub add hangul_choseong_search:^0.1.0
```

For a Flutter application:

```console
flutter pub add hangul_choseong_search:^0.1.0
```

You can also edit `pubspec.yaml` directly:

```yaml
dependencies:
  hangul_choseong_search: ^0.1.0
```

## Quick start

```dart
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  final items = ['라면', '리모컨', '로마', '사과Apple'];

  print(filterByChoseong(items, 'ㄹ'));
  print(filterByChoseong(items, '라'));
  print(filterByChoseong(items, '라ㅁ'));
  print(filterByChoseong(items, 'ㅅㄱa'));
}
```

Output:

```text
[라면, 리모컨, 로마]
[라면]
[라면]
[사과Apple]
```

## API

The package exposes four functions.

### `getChoseong`

Extract initial consonants from modern Hangul syllables. ASCII uppercase letters are converted to lowercase. Other characters stay literal.

```dart
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  print(getChoseong('사과Apple')); // ㅅㄱapple
}
```

### `matchesByChoseong`

Check whether one candidate matches a query.

```dart
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  print(matchesByChoseong('라면', '라ㅁ')); // true
  print(matchesByChoseong('리모컨', '라')); // false
}
```

### `filterByChoseong`

Filter a list of strings. Input order and duplicates are preserved.

```dart
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  final names = ['김민수', '박서준', '김민수'];
  print(filterByChoseong(names, 'ㄱㅁㅅ')); // [김민수, 김민수]
}
```

### `filterByChoseongKey`

Filter typed objects by a selected string key. The selector runs once for each item.

```dart
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

class Contact {
  const Contact(this.name, this.phone);

  final String name;
  final String phone;

  @override
  String toString() => name;
}

void main() {
  final contacts = [
    const Contact('김민수', '010-1000-1000'),
    const Contact('박서준', '010-2000-2000'),
  ];

  final result = filterByChoseongKey(
    contacts,
    'ㄱㅁㅅ',
    (contact) => contact.name,
  );
  print(result); // [김민수]
}
```

Both filter functions return a new growable list, including for an empty query. An empty query matches every item.

## Matching rules

### Supported modern Hangul forms

Equivalent valid modern Hangul input is normalized locally by the package:

* Precomposed syllables, such as `가` in U+AC00 through U+D7A3
* Conjoining jamo sequences, such as `가`
* Compatibility jamo sequences, such as `ㄱㅏ`
* Halfwidth jamo sequences, such as `ﾡￂ`

For valid modern sequences, all four examples above behave as the syllable `가`. Standalone modern leading consonants in the supported jamo forms behave as choseong wildcards. Double initials stay distinct, so `ㄱ` doesn't match `까` and `ㄲ` doesn't match `가`.

Normalization is limited to modern Hangul composition and ASCII uppercase letters. It isn't global NFC or NFKC normalization.

### ASCII case

Case-insensitive matching applies only to ASCII `A` through `Z`. For example, `ㅅㄱa` matches `사과Apple`. Non-ASCII case pairs and fullwidth Latin letters remain literal, so `strasse` doesn't match `Straße`, and `abc` doesn't match `ＡＢＣ`.

### Separators and other characters

Whitespace, punctuation, digits, emoji, and non-Hangul Unicode characters are literal query units. They aren't trimmed, ignored, or treated as separators that may be skipped.

For example, `ㅅㄱa` matches `사과Apple` but not `사과 Apple`. Query `ㄱ-ㅁ` can match `김-민수`, while `ㄱㅁ` cannot cross the hyphen.

## Complexity

Let `n` be the number of normalized units in a candidate and `m` the number in the query.

* `getChoseong` takes O(n) time and O(n) space.
* `matchesByChoseong` takes O(nm) time in the worst case and O(n + m) normalization space.
* The filter functions apply that work to each item. They don't build or retain an index.

## Benchmark

Run the included deterministic workloads with:

```console
dart run benchmark/search_benchmark.dart
```

The benchmark covers all four APIs with ASCII, Korean, and mixed text at fixed corpus sizes. Its timings are observations for the current machine, not pass or fail thresholds.

## Limitations

This package doesn't provide fuzzy search, ranking, tokenization, transliteration, typo correction, morphological analysis, or highlighting. Matching is an in-memory contiguous scan, not a database or server search system.

Archaic Hangul and unsupported parts of invalid or incomplete composition sequences aren't broadened into modern choseong matches. They remain literal and don't cause an exception. A standalone supported modern leading consonant remains an intentional choseong wildcard. General Unicode normalization and locale-sensitive case folding are outside the package scope.

## Migrating from 0.0.4

Version 0.1.0 keeps the package name, import URI, and required positional signatures of `getChoseong(String)` and `filterByChoseong(List<String>, String)`. It also adds `matchesByChoseong` and `filterByChoseongKey`.

Three behavior changes may affect existing searches:

1. A complete syllable query is now literal. If 0.0.4 code used `라` to find every `ㄹ` initial, change the query to `ㄹ`. Use `라` only when that exact syllable is required.
2. An empty filter query now returns a new growable copy instead of returning the source list itself.
3. Case folding is now ASCII-only. Non-ASCII letters no longer receive Dart's general lowercase conversion during choseong extraction.

Version 0.1.0 is also a pure Dart package. Existing Flutter imports remain the same, but Flutter isn't a package runtime dependency.

## Contributing and issues

Bug reports and feature discussions belong in the [GitHub issue tracker](https://github.com/beomq/hangul_choseong_search_flutter/issues). Pull requests are welcome at the [GitHub repository](https://github.com/beomq/hangul_choseong_search_flutter). Include a small reproducible case and tests for behavior changes.

## 한국어 빠른 참고

`hangul_choseong_search` 0.1.0은 Dart와 Flutter에서 쓸 수 있는 순수 Dart 초성 검색 패키지입니다.

```dart
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  final items = ['라면', '리모컨', '로마', '사과Apple'];
  print(filterByChoseong(items, 'ㄹ')); // [라면, 리모컨, 로마]
  print(filterByChoseong(items, '라')); // [라면]
  print(filterByChoseong(items, '라ㅁ')); // [라면]
  print(filterByChoseong(items, 'ㅅㄱa')); // [사과Apple]
}
```

* `라` 같은 완성형 음절은 그대로 일치해야 합니다.
* `ㄹ` 같은 독립 초성은 해당 초성으로 시작하는 현대 한글 음절과 일치합니다.
* 검색은 연속 일치 방식입니다. 공백, 문장 부호, 숫자, 이모지는 건너뛰지 않습니다.
* 영문 대소문자 무시는 ASCII `A-Z`에만 적용됩니다.
* 완성형, 결합 자모, 호환 자모, 반각 자모로 된 유효한 현대 한글 조합을 같은 값으로 처리합니다.
* 문자열 목록은 `filterByChoseong`, 단일 문자열은 `matchesByChoseong`, 객체 목록은 `filterByChoseongKey`를 사용합니다. `getChoseong`은 초성 문자열을 추출합니다.

설치:

```console
dart pub add hangul_choseong_search:^0.1.0
```

Flutter 프로젝트에서는 `dart` 대신 `flutter` 명령을 사용하세요.
