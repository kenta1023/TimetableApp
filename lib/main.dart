import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ホーム',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CardData> cardListData = [];

  @override
  void initState() {
    super.initState();
    _loadClassPeriodData();
    _loadTimetableData();
  }

  _loadClassPeriodData() async {
    final db = DatabaseHelper.instance;
    final List<ClassPeriod> classPeriods = await db.getAllClassPeriods();

    // ここでClassPeriodのデータを適切な形式に変換して、UIで表示することができます
  }

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: '時間割表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.draw),
            label: '追加・削除',
          ),
        ],
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
