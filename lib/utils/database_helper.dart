import 'package:mkeep/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //Singleton DataBase Helper
  static Database _database; //Singleton Database

  //Define all columns of database table along with table name
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      //Only executed once
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  //Create Getter for our database
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both Android and IOS to store database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //Now create database at the given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database database, int newVersion) async {
    await database.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,'
        ' $colTitle TEXT,$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

//          Defining Functions for CRUD operations
//    Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNotesMapList() async {
    Database database = await this.database;

//Either RAW QUERY or HELPER FUNCTION are same, my choice to use one
//  USING RAW QUERY
//    var result = await database
//        .rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');

//  USING HELPER FUNCTION
    var result = await database.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

//    Insert Operation: Insert a note object into the database
  Future<int> insertNote(Note note) async {
    Database database = await this.database;
    var result = await database.insert(noteTable, note.toMap());
    return result;
  }

//    Update Operation: Update a note to the database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

//    Delete Operation: Delete a note object from the database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

//    Get Operation: To get the number of Note objects in the database
  Future<int> getCount() async {
    Database database = await this.database;
    List<Map<String, dynamic>> mapObjectsList =
        await database.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(mapObjectsList);
    return result;
  }

//    Get Map List from database and convert to noteList object
  Future<List<Note>> getNotesList() async {
    var noteMapList = await getNotesMapList(); //Get from database
    int count = noteMapList.length;
    List<Note> notesList = List<Note>();

    //For loop to create a Mote List from the Map List
    for (int i = 0; i < count; i++) {
      notesList.add(Note.fromMapObject(noteMapList[i]));
    }
    return notesList;
  }
}
