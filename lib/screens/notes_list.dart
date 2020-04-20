import 'package:flutter/material.dart';
import 'package:mkeep/screens/note_details.dart';
import 'package:mkeep/utils/database_helper.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:mkeep/models/note.dart';

class NotesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotesListState();
  }
}

class NotesListState extends State<NotesList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> notesList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (notesList == null) {
      notesList = List<Note>();

      updateListView();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('mKeep Notes'),
        ),
        body: getNoteListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToNoteDetails(Note('', '', 2), "Add Note");
          },
          tooltip: "Create a Note.",
          child: Icon(Icons.add),
        ));
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 5.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  getPriorityColor(this.notesList[position].priority),
              child: getPriorityIcon(this.notesList[position].priority),
            ),
            title: Text(
              this.notesList[position].title,
              style: titleStyle,
            ),
            subtitle: Text(this.notesList[position].date),
            trailing: GestureDetector(
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.orange,
                ),
                onTap: () {
                  _delete(context, notesList[position]);
                }),
            onTap: () {
              // debugPrint("You tapped the card");
              navigateToNoteDetails(this.notesList[position], "Edit Note");
            },
          ),
        );
      },
    );
  }

  //Returning priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;

      case 2:
        return Colors.lightGreen;
        break;

      default:
        return Colors.lightGreen;
    }
  }

  //Returning Priority Icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.star);
        break;

      case 2:
        return Icon(Icons.arrow_forward_ios);
        break;

      default:
        return Icon(Icons.arrow_forward_ios);
    }
  }

  //Delete Function for Delete Icon
  void _delete(BuildContext buildContext, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, "Successfully Deleted Note!!");
      updateListView();
    }
  }

  //Display a SnackBar
  void _showSnackBar(BuildContext buildContext, String snackBarMessage) {
    final snackBar = SnackBar(content: Text(snackBarMessage));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  //Function for navigation to Note details
  void navigateToNoteDetails(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> databaseFuture = databaseHelper.initializeDatabase();
    databaseFuture.then((database) {
      Future<List<Note>> notesListFuture = databaseHelper.getNotesList();
      notesListFuture.then((notesList) {
        setState(() {
          this.notesList = notesList;
          this.count = notesList.length;
        });
      });
    });
  }
}
