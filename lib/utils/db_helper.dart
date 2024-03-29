import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// DBHelper is a Singleton class (only one instance)
class DataStore {
  static const String _databaseName = 'Assignment3san.db';


  DataStore._(); // private constructor (can't be called from outside)

  // the single instance
  static final DataStore _store = DataStore._();

  // factory constructor that always returns the single instance
  factory DataStore() => _store;

  // the singleton will hold a reference to the database once opened
  Database? _database;

  // initialize the database when it's first requested

  Future<Database> _initialData() async {
    // where should databases live? this is platform specific;
    // on iOS, it is the Documents directory
    var Dir = await getLibraryDirectory();

    // path.join joins two paths together, and is platform aware
    var Path = path.join(Dir.path, _databaseName);

    print(Path);

     //await deleteDatabase(dbPath); // nuke the database (for testing)

    // open the database
    var database = await openDatabase(Path,
        version: 1,

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
    _database ??= await _initialData(); // if null, initialize it
    return _database;
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where}) async {
    final datab = await data;
    return where == null ? datab.query(table) : datab.query(table, where: where);
  }

  // insert a record into a table
  Future<int> addRecord(String table, Map<String, dynamic> rowData) async {
    final Database dbRec = await data;
    return dbRec.insert(
      table,
      rowData,
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Ensures updates if the row already exists based on primary key
    );
  }

  // update a record in a table
  Future<void> modifyRecord(String table, Map<String, dynamic> rowData) async {
    final Database dbRec = await data;
    int rowId = rowData['id'];
    await dbRec.update(
      table,
      rowData,
      where: 'id = ?', // Uses parameter substitution for security
      whereArgs: [rowId], // Provides the actual value for the substitution
    );
  }

  // delete a record from a table
  Future<void> removeRecord(String table, int itemId) async {
    final Database dbRec = await data;
    await dbRec.delete(
      table,
      where: 'id = ?', // Parameterized where clause to prevent SQL injection
      whereArgs: [itemId], // Argument for where clause
    );
  }

  Future<void> removeAllRecordsFromDeck(String table, int deckId) async {
    final Database dbRec = await data;
    await dbRec.delete(
      table,
      where:
          'deck_id = ?', // Ensures that all cards associated with a deck are removed
      whereArgs: [deckId],
    );
  }
}
