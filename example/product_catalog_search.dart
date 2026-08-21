import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  const products = [
    '삼성 Galaxy S24',
    'LG gram 16',
    '무선 마우스-2세대',
    'Apple Watch 10',
  ];

  for (final query in ['ㅅㅅ g', 'S24', 'ㅁㅅ ㅁㅇㅅ-2', 'Pixel 9']) {
    print('Product query "$query": ${filterByChoseong(products, query)}');
  }
}
