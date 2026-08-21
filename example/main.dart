import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  const items = ['라면', '리모컨', '로마', '사과Apple'];

  print('Quick contract:');
  for (final query in ['ㄹ', '라', '라ㅁ', 'ㅅㄱa']) {
    print('  "$query" => ${filterByChoseong(items, query)}');
  }

  print('\nFocused runnable examples:');
  print('  dart run example/contact_search.dart');
  print('  dart run example/product_catalog_search.dart');
  print('  dart run example/music_search.dart');
  print('  dart run example/place_restaurant_search.dart');
  print('  dart run example/typed_domain_search.dart');
}
