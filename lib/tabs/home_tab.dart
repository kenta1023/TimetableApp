import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<CardData> cardListData = [];
  List<ClassPeriod> classPeriods = [];
  List<Timetable> timetables = [];
  DateTime _currentDate = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja');
    _loadData();
    _startTimer();
  }

  // initStateで読み込み時に一回だけ呼ばれる
  _loadData() async {
    final db = DatabaseHelper.instance;
    classPeriods = await db.getAllClassPeriods();
    timetables = await db.getTimetablesToday();
    _setCardData();
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      if (now.day != _currentDate.day) {
        // 日付が変わったらデータベースからデータを再取得
        _loadData();
      }
      _currentDate = now;
      _setCardData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _setCardData() async {
    getClassPeriodByPeriod(int period) {
      // classPeriods から引数で受け取ったperiodのデータを取り出す
      ClassPeriod? targetPeriod;
      try {
        targetPeriod = classPeriods.firstWhere((p) => p.period == period);
      } catch (e) {
        targetPeriod = null;
      }
      return targetPeriod;
    }

    Map<String, int> getCountdownTimeFromPeriod(int period) {
      ClassPeriod? targetPeriod = getClassPeriodByPeriod(period);
      if (targetPeriod == null) {
        // 引数で受け取ったperiodのデータがない場合
        return {'hours': 0, 'minutes': 0, 'seconds': 0};
      }
      // startTimeを今日のDateTime形式に変換
      List<String> startTimes = targetPeriod.startTime.split(':');
      DateTime startTimeToday = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          int.parse(startTimes[0]),
          int.parse(startTimes[1]));
      Duration difference = startTimeToday.difference(DateTime.now());
      int totalSeconds = difference.inSeconds;
      return {
        'hours': totalSeconds ~/ 3600,
        'minutes': (totalSeconds % 3600) ~/ 60,
        'seconds': totalSeconds % 60
      };
    }

    // cardListDataを初期化
    cardListData.clear();
    for (var timetable in timetables) {
      // カウントダウンの情報を取得
      var countdown = getCountdownTimeFromPeriod(timetable.period);
      // 時限の情報を取得
      var periodDetails = getClassPeriodByPeriod(timetable.period);
      String timeDetails = periodDetails != null
          ? "${periodDetails.startTime}~${periodDetails.endTime}"
          : "時間が設定されていません";
      cardListData.add(
        CardData(
            countdown['hours']!,
            countdown['minutes']!,
            countdown['seconds']!,
            timetable.subject,
            "教室:${timetable.classroom}",
            "${timetable.period}限:($timeDetails)"),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Text(
                  DateFormat.yMMMMEEEEd('ja').format(DateTime.now()),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('HH:mm:ss').format(DateTime.now()),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: cardListData.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            cardListData[index].className,
                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cardListData[index].location),
                              Text(cardListData[index].classTime),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
                              children: <TextSpan>[
                                const TextSpan(text: 'あと',style: TextStyle(fontSize: 10.0)),
                                if (cardListData[index].countdownHour != 0) ...[
                                  TextSpan(text: cardListData[index].countdownHour.toString()),
                                  const TextSpan(text: '時間', style: TextStyle(fontSize: 10.0)),
                                ],
                                TextSpan(text: cardListData[index].countdownMinute.toString()),
                                const TextSpan(text: '分', style: TextStyle(fontSize: 10.0)),
                                TextSpan(text: cardListData[index].countdownSecond.toString()),
                                const TextSpan(text: '秒', style: TextStyle(fontSize: 10.0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CardData {
  final int countdownHour;
  final int countdownMinute;
  final int countdownSecond;
  final String className;
  final String location;
  final String classTime;

  CardData(this.countdownHour, this.countdownMinute, this.countdownSecond,
      this.className, this.location, this.classTime);
}
