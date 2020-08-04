import 'dart:typed_data';
import 'package:chat/models/chat_history.dart';
import 'package:sqflite/sqflite.dart';

import '../storage/storage.dart';
import 'user.dart';

class Buddy extends User {
  Buddy({
    String username,
    Uint8List imageData,
    String name,
  }) : super(
          username: username,
          imageData: imageData,
          name: name,
        );

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

  Future<Buddy> get(String username) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "username=?",
      whereArgs: [username],
    );
    if (result.isEmpty) {
      return null;
    }
    return Buddy.fromMap(result[0]);
  }

  Future<List<Buddy>> getAll() async {
    Database db = await _storage.getDB();
    List result = await db.query(_tableName);
    List<Buddy> buddies = List<Buddy>.generate(
      result.length,
      (index) => Buddy.fromMap(result[index]),
    );
    return buddies;
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
    // remove chat history
    ChatHistoryProvider chatHistoryProvider = ChatHistoryProvider();
    await chatHistoryProvider.clear(buddy);
    // remove buddy
    Database db = await _storage.getDB();
    await db.delete(
      _tableName,
      where: "username=?",
      whereArgs: [buddy.username],
    );
  }
}
