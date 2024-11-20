library hangul_choseong_search;

/// 초성을 추출하는 함수
String getChoseong(String text) {
  const List<String> choseongList = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ'
  ];

  StringBuffer buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    int codeUnit = text.codeUnitAt(i);
    if (codeUnit >= 0xAC00 && codeUnit <= 0xD7A3) {
      int choseongIndex = ((codeUnit - 0xAC00) / (21 * 28)).floor();
      buffer.write(choseongList[choseongIndex]);
    } else {
      // 한글이 아닌 경우 그대로 추가 (소문자로 변환)
      buffer.write(String.fromCharCode(codeUnit).toLowerCase());
    }
  }

  return buffer.toString();
}

/// 리스트에서 초성 + 영문 혼합 검색을 지원하는 필터링 함수
List<String> filterByChoseong(List<String> items, String userInput) {
  if (userInput.isEmpty) return items;

  // 입력값에서 초성 및 비한글(영문, 숫자 등) 추출
  final String queryMixed = getChoseong(userInput.toLowerCase());

  return items.where((item) {
    final String itemMixed = getChoseong(item.toLowerCase());

    // 초성과 영문 혼합 문자열 매칭
    return itemMixed.contains(queryMixed);
  }).toList();
}
