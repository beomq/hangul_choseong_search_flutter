import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  const places = [
    '서울역 2번 출구',
    '부산 해운대-시장',
    '전주 한옥마을',
    'Jeju 카페 101',
  ];

  final withPunctuation = filterByChoseong(places, 'ㅂㅅ ㅎㅇㄷ-ㅅㅈ');
  final withoutPunctuation = filterByChoseong(places, 'ㅂㅅ ㅎㅇㄷㅅㅈ');
  final literalSyllable = filterByChoseong(places, '서울');

  print('Exact spaces and hyphen: $withPunctuation');
  print('Missing the literal hyphen: $withoutPunctuation');
  print('Literal syllables "서울": $literalSyllable');
}
