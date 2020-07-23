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
            "host TEXT NOT NULL,"
            "port TEXT NOT NULL"
            ")",
          ),
          db.execute(
            "CREATE TABLE user ("
            "username TEXT PRIMARY KEY,"
            "password TEXT NOT NULL"
            ")",
          ),
          db.execute(
            "CREATE TABLE buddy ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "username TEXT UNIQUE NOT NULL"
            ")",
          ),
          db.execute(
            "CREATE TABLE chat_history ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "buddy TEXT NOT NULL,"
            "FOREIGN KEY (buddy) REFERENCES buddy(username)"
            ")",
          ),
          db.execute(
            "CREATE TABLE chat_history_message ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "history_id INTEGER NOT NULL,"
            "sender TEXT,"
            "message TEXT NOT NULL,"
            "timestamp DATE NOT NULL,"
            "FOREIGN KEY (history_id) REFERENCES chat_history(id)"
            ")",
          ),
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
