import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Timetable {
  int? id;
  String subject;
  String classroom;
  String dayOfWeek;
  int period;

  Timetable(
      {required this.subject,
      required this.classroom,
      required this.dayOfWeek,
      required this.period,
      this.id});

  Timetable.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        subject = map['subject'],
        classroom = map['classroom'],
        dayOfWeek = map['day_of_week'],
        period = map['period'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'classroom': classroom,
      'day_of_week': dayOfWeek,
      'period': period,
    };
  }
}

class ClassPeriod {
  int period;
  String startTime; // Format: 'HH:mm'
  String endTime; // Format: 'HH:mm'

  ClassPeriod(
      {required this.period, required this.startTime, required this.endTime});

  ClassPeriod.fromMap(Map<String, dynamic> map)
      : period = map['period'],
        startTime = map['start_time'],
        endTime = map['end_time'];

  Map<String, dynamic> toMap() {
    return {
      'period': period,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class DatabaseHelper {
  static const _databaseName = "classes.db";
  static const _databaseVersion = 1;

  // For Timetable table
  static const timetableTable = 'Timetable';
  static const timetableId = 'id';
  static const timetableSubject = 'subject';
  static const timetableClassroom = 'classroom';
  static const timetableDayOfWeek = 'day_of_week';
  static const timetablePeriod = 'period';

  // For ClassPeriod table
  static const classPeriodTable = 'ClassPeriod';
  static const classPeriodId = 'id';
  static const classPeriodPeriod = 'period';
  static const classPeriodStartTime = 'start_time';
  static const classPeriodEndTime = 'end_time';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    var db = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    await db.execute('PRAGMA foreign_keys = ON');
    return db;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $classPeriodTable (
      $classPeriodPeriod INTEGER PRIMARY KEY NOT NULL CHECK ($classPeriodPeriod BETWEEN 1 AND 8),
      $classPeriodStartTime TEXT NOT NULL,
      $classPeriodEndTime TEXT NOT NULL
    )
  ''');
    await db.execute('''
      CREATE TABLE $timetableTable (
       $timetableId INTEGER PRIMARY KEY AUTOINCREMENT,
       $timetableSubject TEXT NOT NULL,
       $timetableClassroom TEXT NOT NULL,
       $timetableDayOfWeek TEXT NOT NULL,
       $timetablePeriod INTEGER NOT NULL,
       UNIQUE ($timetableDayOfWeek, $timetablePeriod),
       FOREIGN KEY ($timetablePeriod) REFERENCES $classPeriodTable($classPeriodPeriod) ON DELETE RESTRICT
      )
    ''');
    // サンプルデータを追加
    await db.insert(classPeriodTable,
        {'period': 1, 'start_time': '09:00', 'end_time': '10:00'});
    await db.insert(classPeriodTable,
        {'period': 2, 'start_time': '10:10', 'end_time': '11:10'});
    await db.insert(timetableTable,
        {'subject': '数学', 'classroom': '101', 'day_of_week': '月', 'period': 1});
    await db.insert(timetableTable,
        {'subject': '英語', 'classroom': '102', 'day_of_week': '火', 'period': 2});
  }

  Future<int> insertTimetable(Timetable timetable) async {
    Database db = await database;
    return await db.insert(timetableTable, timetable.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteByDayAndPeriod(String dayOfWeek, int period) async {
    Database db = await database;
    return await db.delete(
      timetableTable,
      where: '$timetableDayOfWeek = ? AND $timetablePeriod = ?',
      whereArgs: [dayOfWeek, period],
    );
  }

  Future<int> insertClassPeriod(ClassPeriod classPeriod) async {
    Database db = await database;
    // まず、同じ 'period' を持つレコードが存在するかを確認します。
    var res = await db.query(classPeriodTable,
        where: '$classPeriodPeriod = ?', whereArgs: [classPeriod.period]);
    if (res.isNotEmpty) {
      // レコードが存在する場合、UPDATE文を使用してレコードを更新します。
      return await db.update(
        classPeriodTable,
        classPeriod.toMap(),
        where: '$classPeriodPeriod = ?',
        whereArgs: [classPeriod.period],
      );
    } else {
      // レコードが存在しない場合、新しいレコードを挿入します。
      return await db.insert(classPeriodTable, classPeriod.toMap());
    }
  }

  Future<List<Timetable>> getAllTimetables() async {
    Database db = await database;
    var res = await db.query(timetableTable);
    return res.isNotEmpty ? res.map((c) => Timetable.fromMap(c)).toList() : [];
  }

  Future<List<Timetable>> getTimetablesToday() async {
    initializeDateFormatting('ja');
    Database db = await database;
    var now = DateTime.now();
    final dateFormatForDayOfWeek = DateFormat.E('ja');
    final formatStrForDayOfWeek = dateFormatForDayOfWeek.format(now);
    var res = await db.query(timetableTable,
        where: '$timetableDayOfWeek = ?',
        whereArgs: [formatStrForDayOfWeek],
        orderBy: '$timetablePeriod ASC');
    return res.isNotEmpty ? res.map((c) => Timetable.fromMap(c)).toList() : [];
  }

  Future<List<ClassPeriod>> getAllClassPeriods() async {
    Database db = await database;
    var res = await db.query(classPeriodTable);
    return res.isNotEmpty
        ? res.map((c) => ClassPeriod.fromMap(c)).toList()
        : [];
  }
}
