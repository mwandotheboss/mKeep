import 'package:flutter/material.dart';
import 'package:mkeep/screens/note_details.dart';
import 'package:mkeep/screens/notes_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mNotekeeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: NotesList(),
    );
  }
}
