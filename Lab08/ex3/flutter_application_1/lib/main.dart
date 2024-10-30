import 'package:flutter/material.dart';
import 'NoteListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NoteListScreen(),
    );
  }
}
