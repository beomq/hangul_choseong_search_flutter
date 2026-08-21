/// Choseong extraction and contiguous search for modern Korean Hangul text.
///
/// A complete modern Hangul syllable in a query is matched literally. A
/// standalone modern choseong, such as `ㄹ`, matches a syllable with that
/// initial consonant. Valid precomposed, conjoining-jamo, compatibility-jamo,
/// and halfwidth-jamo spellings of modern Hangul are treated equivalently.
/// ASCII letters are compared without case, while other characters remain
/// literal.
library;

import 'src/choseong_matcher.dart';
import 'src/hangul_normalizer.dart';

const _compatibilityInitials = [
  0x3131,
  0x3132,
  0x3134,
  0x3137,
  0x3138,
  0x3139,
  0x3141,
  0x3142,
  0x3143,
  0x3145,
  0x3146,
  0x3147,
  0x3148,
  0x3149,
  0x314a,
  0x314b,
  0x314c,
  0x314d,
  0x314e,
];

/// Extracts compatibility choseong characters from [text].
///
/// Each valid modern Hangul syllable becomes its compatibility initial. A
/// standalone modern initial is converted to the same form. Valid modern
/// Hangul written with precomposed syllables, conjoining jamo, compatibility
/// jamo, or halfwidth jamo is recognized.
///
/// ASCII `A` through `Z` is folded to lowercase. Whitespace, punctuation,
/// digits, emoji, and other characters are kept literally. This function does
/// not perform general Unicode normalization or locale-aware case folding.
String getChoseong(String text) {
  final buffer = StringBuffer();

  for (final unit in normalizeHangulUnits(text)) {
    switch (unit) {
      case ModernSyllableUnit(:final initialIndex):
      case ModernInitialUnit(:final initialIndex):
        buffer.writeCharCode(_compatibilityInitials[initialIndex]);
      case LiteralScalarUnit(:final value):
        buffer.writeCharCode(value);
    }
  }

  return buffer.toString();
}

/// Whether [query] matches a contiguous range in [candidate].
///
/// Complete modern Hangul syllables match literally. Standalone modern
/// choseong characters match syllables with the same initial consonant. ASCII
/// matching ignores case, but whitespace, punctuation, digits, emoji, and
/// non-ASCII non-Hangul characters remain literal. An empty query matches
/// every string.
bool matchesByChoseong(String candidate, String query) =>
    matchesChoseong(candidate, query);

/// Returns the values from [items] whose selected key matches [query].
///
/// [keyOf] is called once for every item. Matching follows
/// [matchesByChoseong], and the result preserves source order and duplicates.
/// The returned list is a new growable list, including when [query] is empty
/// or no item matches.
List<T> filterByChoseongKey<T>(
  Iterable<T> items,
  String query,
  String Function(T item) keyOf,
) =>
    items.where((item) => matchesByChoseong(keyOf(item), query)).toList();

/// Returns the strings from [items] that match [userInput].
///
/// Matching follows [matchesByChoseong]. Source order and duplicates are
/// preserved. The returned value is always a new growable list, including for
/// an empty [userInput].
List<String> filterByChoseong(List<String> items, String userInput) =>
    filterByChoseongKey(items, userInput, (item) => item);
