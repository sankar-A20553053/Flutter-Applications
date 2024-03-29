import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataStore {
  static const String _databaseName = 'Assignment3san.db';

  DataStore._();

  static final DataStore _store = DataStore._();

  factory DataStore() => _store;

  Database? _database;

  // initialize the database when it's first requested

  Future<Database> _initialData() async {
    var Dir = await getLibraryDirectory();

    var Path = path.join(Dir.path, _databaseName);

    // open the database
    var database = await openDatabase(Path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
          CREATE TABLE study_decks(
            id INTEGER PRIMARY KEY,
            title TEXT
          )
        ''');

      await db.execute('''
          CREATE TABLE study_flashcards(
            id INTEGER PRIMARY KEY,
            question TEXT,
            answer REAL,
            deck_id INTEGER,
            FOREIGN KEY (deck_id) REFERENCES deck(id)
          )
        ''');
    });

    return database;
  }

  get data async {
    _database ??= await _initialData();
    return _database;
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where}) async {
    final datab = await data;
    return where == null
        ? datab.query(table)
        : datab.query(table, where: where);
  }

  // insert a record into a table
  Future<int> addRecord(String table, Map<String, dynamic> rowData) async {
    final Database dbRec = await data;
    return dbRec.insert(
      table,
      rowData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // update a record in a table
  Future<void> modifyRecord(String table, Map<String, dynamic> rowData) async {
    final Database dbRec = await data;
    int rowId = rowData['id'];
    await dbRec.update(
      table,
      rowData,
      where: 'id = ?',
      whereArgs: [rowId],
    );
  }

  // delete a record from a table
  Future<void> removeRecord(String table, int itemId) async {
    final Database dbRec = await data;
    await dbRec.delete(
      table,
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> removeAllRecordsFromDeck(String table, int deckId) async {
    final Database dbRec = await data;
    await dbRec.delete(
      table,
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
  }
}
