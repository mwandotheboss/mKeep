import 'package:flutter/material.dart';
import 'package:mkeep/screens/note_details.dart';

class NotesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotesListState();
  }
}

class NotesListState extends State<NotesList> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notes'),
        ),
        body: getNoteListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
//            debugPrint("Fab clicked");
            navigateToNoteDetails("Add Note");
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
              backgroundColor: Colors.lightGreen,
              child: Icon(Icons.arrow_forward_ios),
            ),
            title: Text(
              'Note title',
              style: titleStyle,
            ),
            trailing: Icon(
              Icons.delete_outline,
              color: Colors.lightGreenAccent,
            ),
            onTap: () {
             // debugPrint("You tapped the card");
              navigateToNoteDetails("Edit Note");
            },
          ),
        );
      },
    );
  }

  //Function for navigation to Note details
  void navigateToNoteDetails(String title) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(title);
    }));
  }
}
