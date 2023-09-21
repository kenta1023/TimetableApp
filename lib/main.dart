import 'package:flutter/material.dart';
import 'package:timetable_app/tabs/home_tab.dart';
import 'package:timetable_app/tabs/timetable_tab.dart';
import 'package:timetable_app/tabs/edit_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // super.keyをKey? keyに変更しました

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomeTab();
      case 1:
        return const TimetableTab();
      case 2:
        return const EditTab();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _buildBody(), // タイポを修正しました。'Body' は 'body' でなければなりません。
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
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
