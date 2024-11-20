import 'package:flutter/material.dart';
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

void main() {
  runApp(ChoseongSearchExample());
}

class ChoseongSearchExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChoseongSearchScreen(),
    );
  }
}

class ChoseongSearchScreen extends StatefulWidget {
  @override
  _ChoseongSearchScreenState createState() => _ChoseongSearchScreenState();
}

class _ChoseongSearchScreenState extends State<ChoseongSearchScreen> {
  List<String> items = ['라면', '김치', '사과', '감자'];
  List<String> filteredItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = items;
    searchController.addListener(() {
      setState(() {
        filteredItems = filterByChoseong(items, searchController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('초성 검색 예제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '초성 입력...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredItems[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
