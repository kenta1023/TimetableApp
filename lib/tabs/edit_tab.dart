import 'package:flutter/material.dart';
import '../db_helper.dart';

class EditTab extends StatefulWidget {
  const EditTab({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditTabState createState() => _EditTabState();
}

class _EditTabState extends State<EditTab> {
  late String selectedDayOfWeek = '月曜日';
  late String selectedPeriod = '1時限';
  late String selectedPeriodSetTime = '1時限';
  late TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  late TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController classroomNameController = TextEditingController();
  late List<Timetable> timetables;
  late List<ClassPeriod> classPeriods;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // データベースからデータを取得(この関数はinitState()内のみで呼び出されます）
  void _fetchData() async {
    final db = DatabaseHelper.instance;
    timetables = await db.getAllTimetables();
    classPeriods = await db.getAllClassPeriods();
    _setTimetableDataIfExist();
    _setClassPeriodsDataIfExist();
  }

  void _setTimetableDataIfExist() async {
    // データベースの中から、`dayOfWeek`と`period`が一致するデータを取得
    Timetable? matchedTimetable;
    try {
      matchedTimetable = timetables.firstWhere((table) =>
          table.dayOfWeek == selectedDayOfWeek[0] &&
          table.period.toString() == selectedPeriod[0]);
    } catch (e) {
      matchedTimetable = null;
    }
    if (matchedTimetable != null) {
      // もし該当するデータがあれば、テキストをセット
      classNameController.text = matchedTimetable.subject;
      classroomNameController.text = matchedTimetable.classroom;
    } else {
      // もし該当するデータがなければ、テキストをクリア
      classNameController.text = "";
      classroomNameController.text = "";
    }
  }

  void _setClassPeriodsDataIfExist() async {
    // データベースから取得したデータの中から、`period`が一致するデータを取得
    ClassPeriod? matchedClassPeriod;
    try {
      matchedClassPeriod = classPeriods.firstWhere(
          (table) => table.period.toString() == selectedPeriodSetTime[0]);
    } catch (e) {
      matchedClassPeriod = null;
    }
    if (matchedClassPeriod != null) {
      // もし該当するデータがあれば、startTimeとendTimeをセット
      final List<String> startParts = matchedClassPeriod.startTime.split(':');
      final List<String> endParts = matchedClassPeriod.endTime.split(':');
      setState(() {
        startTime = TimeOfDay(
            hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
        endTime = TimeOfDay(
            hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
      });
    } else {
      // 該当するデータがなければ、デフォルトのstartTimeとendTimeをセット（オプション、必要に応じて調整）
      setState(() {
        startTime = const TimeOfDay(hour: 0, minute: 0);
        endTime = const TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
      });
    }
  }

  Future<bool> _updateTimetable(
      String subject, String classroom, String dayOfWeek, int period) async {
    final db = DatabaseHelper.instance;
    final newTimetable = Timetable(
      subject: subject,
      classroom: classroom,
      dayOfWeek: dayOfWeek,
      period: period,
    );
    try {
      int result = await db.insertTimetable(newTimetable);
      if (result != 0) {
        // データベースからデータを再取得
        timetables = await db.getAllTimetables();
      }
      _setTimetableDataIfExist();
      return result != 0;
    } catch (e) {
      _setTimetableDataIfExist();
      return false;
    }
  }

  Future<bool> _deleteTimetable(String dayOfWeek, int period) async {
    final db = DatabaseHelper.instance;
    try {
      int result = await db.deleteByDayAndPeriod(dayOfWeek, period);
      if (result != 0) {
        // データベースからデータを再取得
        timetables = await db.getAllTimetables();
      }
      _setTimetableDataIfExist();
      return result != 0;
    } catch (e) {
      _setTimetableDataIfExist();
      return false;
    }
  }

  Future<bool> _updateClassPeriod(
      int period, String startTime, String endTime) async {
    final db = DatabaseHelper.instance;
    final newClassPeriod = ClassPeriod(
      period: period,
      startTime: startTime,
      endTime: endTime,
    );
    try {
      int result = await db.insertClassPeriod(newClassPeriod);
      if (result != 0) {
        // データベースからデータを再取得
        classPeriods = await db.getAllClassPeriods();
      }
      _setClassPeriodsDataIfExist();
      return result != 0;
    } catch (e) {
      _setClassPeriodsDataIfExist();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.blue[100], // Container color
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Column(
              children: [
                const Text("授業情報登録",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        value: selectedDayOfWeek,
                        decoration: const InputDecoration(
                          labelText: '曜日',
                        ),
                        items: ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日']
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedDayOfWeek = newValue as String;
                          });
                          _setTimetableDataIfExist();
                        },
                      ),
                    ),
                    Flexible(
                      child: DropdownButtonFormField(
                        value: selectedPeriod,
                        decoration: const InputDecoration(
                          labelText: '時限',
                        ),
                        items: [
                          '1時限',
                          '2時限',
                          '3時限',
                          '4時限',
                          '5時限',
                          '6時限',
                          '7時限',
                          '8時限'
                        ]
                            .map((time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedPeriod = newValue as String;
                          });
                          _setTimetableDataIfExist();
                        },
                      ),
                    )
                  ],
                ),
                TextFormField(
                  controller: classNameController,
                  decoration: const InputDecoration(
                    labelText: '授業名',
                  ),
                ),
                TextFormField(
                  controller: classroomNameController,
                  decoration: const InputDecoration(
                    labelText: '教室名',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // ウィジェットを中央に配置
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _updateTimetable(
                                classNameController.text,
                                classroomNameController.text,
                                selectedDayOfWeek[0],
                                int.parse(selectedPeriod[0]))
                            .then((success) {
                          if (success == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content: Text(
                                  '$selectedDayOfWeek曜日${int.parse(selectedPeriod[0])}限${classNameController.text} \n登録/更新しました',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text('登録/更新に失敗しました',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            );
                          }
                        });
                      },
                      child: const Text('登録/更新'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _deleteTimetable(selectedDayOfWeek[0],
                                int.parse(selectedPeriod[0]))
                            .then((success) {
                          if (success == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content: Text(
                                  '$selectedDayOfWeek曜日${int.parse(selectedPeriod[0])}限${classNameController.text} \n削除しました',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text('削除に失敗しました',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            );
                          }
                        });
                      },
                      child: const Text('　削除　'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.symmetric(vertical: 32.0),
            decoration: BoxDecoration(
              color: Colors.green[100], // Container color
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Column(
              children: [
                const Text("授業時間設定",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Flexible(
                      child: DropdownButtonFormField(
                        value: selectedPeriodSetTime,
                        decoration: const InputDecoration(
                          labelText: '時限',
                        ),
                        items: [
                          '1時限',
                          '2時限',
                          '3時限',
                          '4時限',
                          '5時限',
                          '6時限',
                          '7時限',
                          '8時限'
                        ]
                            .map((time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedPeriodSetTime = newValue as String;
                          });
                          _setClassPeriodsDataIfExist();
                        },
                      ),
                    ),
                    Flexible(
                      child: TextButton(
                          onPressed: () => _selectStartTime(context),
                          child: Column(
                            children: [
                              const Text(
                                "開始",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black),
                              ),
                              Text(
                                '${startTime.hour.toString().padLeft(2, "0")}:${startTime.minute.toString().padLeft(2, "0")}',
                                style: const TextStyle(fontSize: 25),
                              )
                            ],
                          )),
                    ),
                    Flexible(
                      child: TextButton(
                          onPressed: () => _selectEndTime(context),
                          child: Column(
                            children: [
                              const Text(
                                "終了",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black),
                              ),
                              Text(
                                '${endTime.hour.toString().padLeft(2, "0")}:${endTime.minute.toString().padLeft(2, "0")}',
                                style: const TextStyle(fontSize: 25),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    String startTimeString =
                        '${startTime.hour.toString().padLeft(2, "0")}:${startTime.minute.toString().padLeft(2, "0")}';
                    String endTimeString =
                        '${endTime.hour.toString().padLeft(2, "0")}:${endTime.minute.toString().padLeft(2, "0")}';
                    _updateClassPeriod(int.parse(selectedPeriodSetTime[0]),
                            startTimeString, endTimeString)
                        .then((success) {
                      if (success == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.greenAccent,
                            content: Text(
                              '${selectedPeriodSetTime[0]}限目($startTimeString ~ $endTimeString) \n登録/更新しました',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text('登録/更新に失敗しました',
                                style: TextStyle(color: Colors.black)),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text('授業時間を登録'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
