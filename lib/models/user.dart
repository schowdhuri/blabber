import 'package:chat/chatclient/storage/storage.dart';
import 'package:sqflite/sqflite.dart';

class User {
  String username;
  String password;

  User({
    this.username,
    this.password,
  });

  static User fromMap(Map<String, dynamic> data) {
    return User(
      username: data["username"],
      password: data["password"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
    };
  }
}

class UserProvider {
  final Storage _storage = Storage();
  final String _tableName = "user";

  Future<User> get() async {
    Database db = await _storage.getDB();
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      columns: ["username", "password"],
    );
    if (result.length == 0) {
      print("no users found");
      return null;
    }
    return User.fromMap(result[0]);
  }

  Future<User> save(User user) async {
    Database db = await _storage.getDB();
    User _existing = await get();
    if (_existing == null) {
      print("Saving a new user...");
      await db.insert(
        _tableName,
        user.toMap(),
      );
      return user;
    }
    print("Updating user...");
    await db.update(
      _tableName,
      user.toMap(),
      where: "username=?",
      whereArgs: [user.username],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return user;
  }
}
