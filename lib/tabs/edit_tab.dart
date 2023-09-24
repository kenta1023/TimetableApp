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
  late TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  late TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 0);
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController classroomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final db = DatabaseHelper.instance;
    final List<Timetable> timetables = await db.getAllTimetables();
    final List<ClassPeriod> classPeriods = await db.getAllClassPeriods();
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
      return result != 0;
    } catch (e) {
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
      return result != 0;
    } catch (e) {
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
                        // Process the information when the registration button is pressed
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
            margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                    String startTimeString = '${startTime.hour.toString().padLeft(2, "0")}:${startTime.minute.toString().padLeft(2, "0")}';
                    String endTimeString = '${endTime.hour.toString().padLeft(2, "0")}:${endTime.minute.toString().padLeft(2, "0")}';
                    _updateClassPeriod(
                            int.parse(selectedPeriodSetTime[0]),
                            startTimeString,
                            endTimeString)
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
