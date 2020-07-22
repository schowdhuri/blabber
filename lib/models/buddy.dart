import 'package:chat/models/user.dart';
import 'package:chat/storage/storage.dart';
import 'package:sqflite/sqflite.dart';

class Buddy extends User {
  Buddy({String username}) : super(username: username);

  static Buddy fromMap(Map<String, dynamic> data) {
    return Buddy(
      username: data["username"],
    );
  }

  @override
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
