import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

const _sizes = [100, 1000, 10000];

final class _SearchRecord {
  const _SearchRecord(this.id, this.text);

  final int id;
  final String text;
}

final class _Corpus {
  const _Corpus(this.name, this.query, this.items, this.records);

  final String name;
  final String query;
  final List<String> items;
  final List<_SearchRecord> records;
}

enum _Operation {
  getChoseong,
  matchesByChoseong,
  filterByChoseong,
  filterByChoseongKey,
}

int _resultSink = 0;

final class _SearchBenchmark extends BenchmarkBase {
  _SearchBenchmark(this.operation, this.corpus)
      : super('${operation.name}/${corpus.name}/${corpus.items.length}');

  final _Operation operation;
  final _Corpus corpus;

  @override
  void setup() {
    if (corpus.items.isEmpty || corpus.items.length != corpus.records.length) {
      throw StateError(
          'Benchmark fixture ${corpus.name} is missing or invalid.');
    }
  }

  @override
  void run() {
    var consumed = 0;

    switch (operation) {
      case _Operation.getChoseong:
        for (final item in corpus.items) {
          consumed += getChoseong(item).length;
        }
      case _Operation.matchesByChoseong:
        for (final item in corpus.items) {
          if (matchesByChoseong(item, corpus.query)) {
            consumed++;
          }
        }
      case _Operation.filterByChoseong:
        final matches = filterByChoseong(corpus.items, corpus.query);
        consumed = matches.fold(0, (total, item) => total + item.length);
      case _Operation.filterByChoseongKey:
        final matches = filterByChoseongKey(
          corpus.records,
          corpus.query,
          (record) => record.text,
        );
        consumed = matches.fold(0, (total, record) => total + record.id);
    }

    _resultSink = consumed;
  }
}

void main() {
  // Fixture generation intentionally happens before BenchmarkBase starts any
  // warmup or measured run. Reported timings are observational only and are
  // never pass/fail thresholds.
  final corpora = [
    for (final size in _sizes) ...[
      _buildCorpus('ascii', size, 'ta', _asciiValue),
      _buildCorpus('korean', size, 'ㄱㅁ', _koreanValue),
      _buildCorpus('mixed', size, 'ㅅㄱa', _mixedValue),
    ],
  ];

  print('Benchmark values are observational; no timing threshold is applied.');
  for (final operation in _Operation.values) {
    for (final corpus in corpora) {
      _SearchBenchmark(operation, corpus).report();
    }
  }
  print('Result consumer: $_resultSink');
}

_Corpus _buildCorpus(
  String name,
  int size,
  String query,
  String Function(int index) valueAt,
) {
  final items = List<String>.generate(size, valueAt, growable: false);
  final records = List<_SearchRecord>.generate(
    size,
    (index) => _SearchRecord(index + 1, items[index]),
    growable: false,
  );
  return _Corpus(name, query, items, records);
}

String _asciiValue(int index) {
  const values = [
    'ContactAlpha',
    'CatalogBeta',
    'DeltaTeam',
    'GammaStore',
    'SearchTarget',
  ];
  return '${values[index % values.length]}${index + 1}';
}

String _koreanValue(int index) {
  const values = ['김민지', '김민수', '박서준', '서울식당', '한강공원'];
  return '${values[index % values.length]}${_koreanSuffix(index)}';
}

String _mixedValue(int index) {
  const values = ['사과Apple', '서울Cafe', '라면Shop', '부산Market', '한강Park'];
  return '${values[index % values.length]}${index + 1}';
}

String _koreanSuffix(int index) {
  const syllableCount = 11172;
  final first = String.fromCharCode(0xac00 + (index % syllableCount));
  final second =
      String.fromCharCode(0xac00 + ((index ~/ syllableCount) % syllableCount));
  return '$first$second';
}
