/// An internal normalized unit used by choseong extraction and matching.
sealed class HangulUnit {
  const HangulUnit();
}

/// A normalized precomposed modern Hangul syllable.
final class ModernSyllableUnit extends HangulUnit {
  const ModernSyllableUnit(this.codePoint, this.initialIndex);

  final int codePoint;
  final int initialIndex;

  @override
  bool operator ==(Object other) =>
      other is ModernSyllableUnit &&
      codePoint == other.codePoint &&
      initialIndex == other.initialIndex;

  @override
  int get hashCode => Object.hash(codePoint, initialIndex);
}

/// A standalone modern Hangul leading consonant.
final class ModernInitialUnit extends HangulUnit {
  const ModernInitialUnit(this.initialIndex);

  final int initialIndex;

  @override
  bool operator ==(Object other) =>
      other is ModernInitialUnit && initialIndex == other.initialIndex;

  @override
  int get hashCode => initialIndex.hashCode;
}

/// A literal scalar (or an unpaired surrogate accepted by a Dart string).
final class LiteralScalarUnit extends HangulUnit {
  const LiteralScalarUnit(this.value);

  final int value;

  @override
  bool operator ==(Object other) =>
      other is LiteralScalarUnit && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Normalizes only modern Hangul representations and ASCII uppercase letters.
///
/// This function is internal to the package; it deliberately does not perform
/// general-purpose Unicode normalization or locale-sensitive case folding.
List<HangulUnit> normalizeHangulUnits(String text) =>
    const _HangulNormalizer().normalize(text);

final class _HangulNormalizer {
  const _HangulNormalizer();

  static const _syllableBase = 0xac00;
  static const _syllableEnd = 0xd7a3;
  static const _vowelCount = 21;
  static const _trailingCount = 28;

  static const Map<int, int> _compatibilityLeading = {
    0x3131: 0,
    0x3132: 1,
    0x3134: 2,
    0x3137: 3,
    0x3138: 4,
    0x3139: 5,
    0x3141: 6,
    0x3142: 7,
    0x3143: 8,
    0x3145: 9,
    0x3146: 10,
    0x3147: 11,
    0x3148: 12,
    0x3149: 13,
    0x314a: 14,
    0x314b: 15,
    0x314c: 16,
    0x314d: 17,
    0x314e: 18,
  };

  static const Map<int, int> _halfwidthLeading = {
    0xffa1: 0,
    0xffa2: 1,
    0xffa4: 2,
    0xffa7: 3,
    0xffa8: 4,
    0xffa9: 5,
    0xffb1: 6,
    0xffb2: 7,
    0xffb3: 8,
    0xffb5: 9,
    0xffb6: 10,
    0xffb7: 11,
    0xffb8: 12,
    0xffb9: 13,
    0xffba: 14,
    0xffbb: 15,
    0xffbc: 16,
    0xffbd: 17,
    0xffbe: 18,
  };

  static const Map<int, int> _halfwidthVowel = {
    0xffc2: 0,
    0xffc3: 1,
    0xffc4: 2,
    0xffc5: 3,
    0xffc6: 4,
    0xffc7: 5,
    0xffca: 6,
    0xffcb: 7,
    0xffcc: 8,
    0xffcd: 9,
    0xffce: 10,
    0xffcf: 11,
    0xffd2: 12,
    0xffd3: 13,
    0xffd4: 14,
    0xffd5: 15,
    0xffd6: 16,
    0xffd7: 17,
    0xffda: 18,
    0xffdb: 19,
    0xffdc: 20,
  };

  static const Map<int, int> _compatibilityTrailing = {
    0x3131: 1,
    0x3132: 2,
    0x3133: 3,
    0x3134: 4,
    0x3135: 5,
    0x3136: 6,
    0x3137: 7,
    0x3139: 8,
    0x313a: 9,
    0x313b: 10,
    0x313c: 11,
    0x313d: 12,
    0x313e: 13,
    0x313f: 14,
    0x3140: 15,
    0x3141: 16,
    0x3142: 17,
    0x3144: 18,
    0x3145: 19,
    0x3146: 20,
    0x3147: 21,
    0x3148: 22,
    0x314a: 23,
    0x314b: 24,
    0x314c: 25,
    0x314d: 26,
    0x314e: 27,
  };

  static const Map<int, int> _halfwidthTrailing = {
    0xffa1: 1,
    0xffa2: 2,
    0xffa3: 3,
    0xffa4: 4,
    0xffa5: 5,
    0xffa6: 6,
    0xffa7: 7,
    0xffa9: 8,
    0xffaa: 9,
    0xffab: 10,
    0xffac: 11,
    0xffad: 12,
    0xffae: 13,
    0xffaf: 14,
    0xffb0: 15,
    0xffb1: 16,
    0xffb2: 17,
    0xffb4: 18,
    0xffb5: 19,
    0xffb6: 20,
    0xffb7: 21,
    0xffb8: 22,
    0xffba: 23,
    0xffbb: 24,
    0xffbc: 25,
    0xffbd: 26,
    0xffbe: 27,
  };

  List<HangulUnit> normalize(String text) {
    final runes = text.runes.toList(growable: false);
    final units = <HangulUnit>[];

    var index = 0;
    while (index < runes.length) {
      final rune = runes[index];

      if (rune >= _syllableBase && rune <= _syllableEnd) {
        final initialIndex =
            (rune - _syllableBase) ~/ (_vowelCount * _trailingCount);
        units.add(ModernSyllableUnit(rune, initialIndex));
        index++;
        continue;
      }

      final leadingIndex = _leadingIndex(rune);
      final vowelIndex =
          index + 1 < runes.length ? _vowelIndex(runes[index + 1]) : null;
      if (leadingIndex != null && vowelIndex != null) {
        var trailingIndex = 0;
        var consumed = 2;
        if (index + 2 < runes.length) {
          final trailingRune = runes[index + 2];
          final possibleTrailing = _trailingIndex(trailingRune);
          final startsNextSyllable = _leadingIndex(trailingRune) != null &&
              index + 3 < runes.length &&
              _vowelIndex(runes[index + 3]) != null;
          if (possibleTrailing != null && !startsNextSyllable) {
            trailingIndex = possibleTrailing;
            consumed = 3;
          }
        }
        final syllable = _syllableBase +
            (leadingIndex * _vowelCount + vowelIndex) * _trailingCount +
            trailingIndex;
        units.add(ModernSyllableUnit(syllable, leadingIndex));
        index += consumed;
        continue;
      }

      if (leadingIndex != null) {
        units.add(ModernInitialUnit(leadingIndex));
      } else {
        units.add(LiteralScalarUnit(_foldAsciiUppercase(rune)));
      }
      index++;
    }

    return List<HangulUnit>.unmodifiable(units);
  }

  int? _leadingIndex(int rune) {
    if (rune >= 0x1100 && rune <= 0x1112) return rune - 0x1100;
    return _compatibilityLeading[rune] ?? _halfwidthLeading[rune];
  }

  int? _vowelIndex(int rune) {
    if (rune >= 0x1161 && rune <= 0x1175) return rune - 0x1161;
    if (rune >= 0x314f && rune <= 0x3163) return rune - 0x314f;
    return _halfwidthVowel[rune];
  }

  int? _trailingIndex(int rune) {
    if (rune >= 0x11a8 && rune <= 0x11c2) return rune - 0x11a7;
    return _compatibilityTrailing[rune] ?? _halfwidthTrailing[rune];
  }

  int _foldAsciiUppercase(int rune) =>
      rune >= 0x41 && rune <= 0x5a ? rune + 0x20 : rune;
}
