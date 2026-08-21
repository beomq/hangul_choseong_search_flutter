import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  const contact = '김민지 / Minji Kim';

  print('Contact: $contact');
  print('Initials "ㄱㅁ": ${matchesByChoseong(contact, 'ㄱㅁ')}');
  print('ASCII "MINJI": ${matchesByChoseong(contact, 'MINJI')}');
  print('Unmatched "ㅂㅅ": ${matchesByChoseong(contact, 'ㅂㅅ')}');
  print('Empty query: ${matchesByChoseong(contact, '')}');

  const nonAsciiContact = 'Große Market 2';
  print(
    'Non-ASCII case stays literal: '
    '${matchesByChoseong(nonAsciiContact, 'grosse')}',
  );
}
