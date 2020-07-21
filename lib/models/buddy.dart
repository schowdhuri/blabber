import 'package:chat/storage/storage.dart';
import 'package:sqflite/sqflite.dart';

class Buddy {
  String username;
  Buddy({this.username});

  static Buddy fromMap(Map<String, dynamic> data) {
    return Buddy(
      username: data["username"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
    };
  }
}

class BuddyProvider {
  Storage _storage = Storage();
  final String _tableName = "buddy";

  Future<List<Buddy>> getAll() async {
    Database db = await _storage.getDB();
    List result = await db.query(_tableName, columns: ["username"]);
    return List<Buddy>.generate(
      result.length,
      (index) => Buddy.fromMap(result[index]),
    );
  }

  Future<Buddy> add(Buddy buddy) async {
    Database db = await _storage.getDB();
    await db.insert(
      _tableName,
      buddy.toMap(),
    );
    return buddy;
  }

  Future<void> remove(Buddy buddy) async {
    Database db = await _storage.getDB();
    await db.delete(
      _tableName,
      where: "username=?",
      whereArgs: [buddy.username],
    );
  }
}
