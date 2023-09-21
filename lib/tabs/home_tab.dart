import 'package:flutter/material.dart';
import '../db_helper.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<CardData> cardListData = [];

  @override
  void initState() {
    super.initState();
    // _loadClassPeriodData();
    _loadTimetableData();
  }

  // _loadClassPeriodData() async {
  //   final db = DatabaseHelper.instance;
  //   final List<ClassPeriod> classPeriods = await db.getAllClassPeriods();

  //   // ここでClassPeriodのデータを適切な形式に変換して、UIで表示することができます
  // }

  _loadTimetableData() async {
    final db = DatabaseHelper.instance;
    final List<Timetable> timetables = await db.getAllTimetables();
    // 取得したデータをcardListDataに変換
    for (var timetable in timetables) {
      cardListData.add(
        CardData(
          timetable.subject,
          timetable.subject,
          timetable.classroom,
          timetable.period.toString(),
        ),
      );
    }
    // 状態を更新
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: cardListData.length,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("授業までのカウントダウン: ${cardListData[index].countdown}"),
                  Text("授業名: ${cardListData[index].className}"),
                  Text("授業場所: ${cardListData[index].location}"),
                  Text("授業時間: ${cardListData[index].classTime}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CardData {
  final String countdown;
  final String className;
  final String location;
  final String classTime;

  CardData(this.countdown, this.className, this.location, this.classTime);
}
