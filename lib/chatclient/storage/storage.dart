import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Storage {
  Database _database;

  Future<Database> getDB() async {
    if (_database != null) {
      return _database;
    }
    _database = await openDatabase(
      join(await getDatabasesPath(), "blabber.db"),
      onCreate: (db, version) {
        List<Future> arr = [
          db.execute(
            "CREATE TABLE server_settings ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "host TEXT,"
            "port TEXT"
            ")",
          ),
          db.execute(
            "CREATE TABLE user ("
            "username TEXT PRIMARY KEY,"
            "password TEXT"
            ")",
          ),
          db.execute(
            "CREATE TABLE buddy ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "username TEXT UNIQUE"
            ")",
          )
        ];
        return Future.wait(arr);
      },
      version: 1,
    );
    return _database;
  }

  Storage._pvtConstructor();
  static final Storage _instance = Storage._pvtConstructor();
  factory Storage() => _instance;
}
