import 'hangul_normalizer.dart';

/// Matches [query] against a contiguous range of normalized [candidate] units.
bool matchesChoseong(String candidate, String query) {
  final candidateUnits = normalizeHangulUnits(candidate);
  final queryUnits = normalizeHangulUnits(query);

  for (var start = 0;
      start <= candidateUnits.length - queryUnits.length;
      start++) {
    var matches = true;
    for (var offset = 0; offset < queryUnits.length; offset++) {
      if (!_matchesUnit(candidateUnits[start + offset], queryUnits[offset])) {
        matches = false;
        break;
      }
    }
    if (matches) return true;
  }

  return false;
}

bool _matchesUnit(HangulUnit candidate, HangulUnit query) {
  if (query is ModernSyllableUnit) {
    return candidate is ModernSyllableUnit &&
        candidate.codePoint == query.codePoint;
  }

  if (query is ModernInitialUnit) {
    return switch (candidate) {
      ModernSyllableUnit(:final initialIndex) ||
      ModernInitialUnit(:final initialIndex) =>
        initialIndex == query.initialIndex,
      LiteralScalarUnit() => false,
    };
  }

  return candidate is LiteralScalarUnit &&
      candidate.value == (query as LiteralScalarUnit).value;
}
