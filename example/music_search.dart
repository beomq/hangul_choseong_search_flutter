import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  const tracks = [
    'NewJeans - Super Shy',
    'BTS - 봄날',
    '아이유 (IU) - 밤편지',
    'DAY6 - 한 페이지가 될 수 있게',
  ];

  print('Search keys generated with getChoseong:');
  for (final track in tracks) {
    print('$track => ${getChoseong(track)}');
  }
}
