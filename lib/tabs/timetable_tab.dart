import 'package:flutter/material.dart';
import '../db_helper.dart';

class TimetableTab extends StatefulWidget {
  const TimetableTab({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TimetableTabState createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  final daysOfWeek = ["", "月", "火", "水", "木", "金", "土", "日"];
  late List<Timetable> timetables;
  late List<ClassPeriod> classPeriods;
  int maxPeriod = 0;
  int maxDayOfWeek = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final db = DatabaseHelper.instance;
    timetables = await db.getAllTimetables();
    classPeriods = await db.getAllClassPeriods();
    // 表作成時の大きさを決めるために、最大の曜日と時限を求める
    for (var timetable in timetables) {
      if (timetable.period > maxPeriod) {
        maxPeriod = timetable.period;
      }
      if (timetable.dayOfWeek == "土" && maxDayOfWeek < 6) {
        maxDayOfWeek = 6;
      }
      if (timetable.dayOfWeek == "日") {
        maxDayOfWeek = 7;
      }
    }
    setState(() {});
  }

  Timetable? getSubjectForDayAndPeriod(String dayOfWeek, int period) {
    try {
      return timetables.firstWhere((timetable) =>
          timetable.dayOfWeek == dayOfWeek && timetable.period == period);
    } catch (e) {
      return null;
    }
  }

  ClassPeriod? getClassTimeByPeriod(int period) {
    try {
      return classPeriods
          .firstWhere((classPeriod) => classPeriod.period == period);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
        },
        border: TableBorder.all(),
        children: List.generate(maxPeriod + 1, (period) {
          return TableRow(
            children: List.generate(maxDayOfWeek + 1, (dayIndex) {
              // 1列の表示
              if (dayIndex == 0) {
                if (period == 0) return const SizedBox(); // １行１列
                final classTime = getClassTimeByPeriod(period);
                return TableCell( // 1列2行~ の時限の表示
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                        child: Text(
                            '${classTime?.startTime}\n$period\n${classTime?.endTime}')),
                  ),
                );
              }

              // 1行2列~ の曜日の表示
              if (period == 0) {
                return TableCell(
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(child: Text(daysOfWeek[dayIndex])),
                  ),
                );
              }
              // 2行2列~ の授業の表示
              Timetable? subject =
                  getSubjectForDayAndPeriod(daysOfWeek[dayIndex], period);
              return Center(
                child: subject == null
                    ? const Text('')
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(subject.subject),
                          Text(subject.classroom),
                        ],
                      ),
              );
            }),
          );
        }),
      ),
    );
  }
}
