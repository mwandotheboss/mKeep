import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mkeep/models/note.dart';
import 'package:mkeep/utils/database_helper.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.note, this.appBarTitle);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  final String appBarTitle;
  final Note note;

  DatabaseHelper databaseHelper = DatabaseHelper();

  static var _priorities = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailsState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          //Control for when user press back button
          moveToPreviousScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                //Custom AppBar Icon
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToPreviousScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(children: <Widget>[
              ListTile(
                title: DropdownButton(
                    items: _priorities.map((String dropdownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropdownStringItem,
                        child: Text(dropdownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint("User selected $valueSelectedByUser");
                        updatePriorityAsInteger(valueSelectedByUser);
                      });
                    }),
              ),

              //Second element on screen
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Something changed in Title textfield");
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: "Note Title",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              //Third element on screen
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint("Something changed in Description textfield");
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //Fourth element on screen
              Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                "SAVE",
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  debugPrint("SAVE button clicked");
                                  _save();
                                });
                              })),

                      //Space between the buttons
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                          child: RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              child: Text(
                                "DELETE",
                                textScaleFactor: 1.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  debugPrint("DELETE button clicked");
                                  _delete();
                                });
                              })),
                    ],
                  ))
            ]),
          ),
        ));
  }

  void moveToPreviousScreen() {
    Navigator.pop(context, true);
  }

//Convert String to integer to save to database for priority
  void updatePriorityAsInteger(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;

      case 'Low':
        note.priority = 2;
        break;
    }
  }

//Convert integer to String
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //High
        break;

      case 2:
        priority = _priorities[1]; //Low
        break;
    }
    return priority;
  }

//        Update Title and Description functions
//    Title
  void updateTitle() {
    note.title = titleController.text;
  }

//    Description
  void updateDescription() {
    note.description = descriptionController.text;
  }

  //Function to save data to Database
  void _save() async {
    moveToPreviousScreen();

    //Add date using date format
    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      //Case 1 : Update Operation
      result = await databaseHelper.updateNote(note);
    } else {
      //Case 2:  Insert Operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      //Success
      _showAlertDialog("Status: ", "Note saved successfully");
    } else {
      //Failure
      _showAlertDialog("Status: ", "Problem saving note");
    }
  }

  //Delete function
  void _delete() async {
    moveToPreviousScreen();

    //      Two cases
    //Case 1: User trying to delete a new note on note details page
    if (note.id == null) {
      _showAlertDialog("Status: ", "There was no note to delete");
    }
    //Case 2: Deleting a note with a valid ID
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog("Status", "Note deleted successfully");
    } else {
      _showAlertDialog(
          "Status", 'An error occurered while trying to delete note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
