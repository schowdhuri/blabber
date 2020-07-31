import 'package:sqflite/sqflite.dart';

import '../storage/storage.dart';

class ConnectionSettings {
  int id;
  int port;
  String host;

  ConnectionSettings({
    this.id,
    this.port,
    this.host,
  });

  static ConnectionSettings fromMap(Map<String, dynamic> data) {
    return ConnectionSettings(
      id: data["id"],
      host: data["host"],
      port: int.parse(data["port"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "host": host,
      "port": "$port",
    };
  }
}

class ConnectionSettingsProvider {
  final String _tableName = "server_settings";
  Storage _storage = Storage();

  Future<ConnectionSettings> get() async {
    Database db = await _storage.getDB();
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      columns: ["host", "port"],
    );
    if (result.length == 0) {
      return null;
    }
    return ConnectionSettings.fromMap(result[0]);
  }

  Future<ConnectionSettings> save(ConnectionSettings connectionSettings) async {
    ConnectionSettings _existing = await get();
    Database db = await _storage.getDB();
    Map<String, dynamic> data = connectionSettings.toMap();
    data.remove("id");
    print("To save ---> $data");
    if (_existing == null || _existing.id == null) {
      print("Adding connectionSettings....");
      await db.insert(
        _tableName,
        data,
      );
      return connectionSettings;
    }
    print("Updating connectionSettings....${_existing.toMap()}");
    await db.update(
      _tableName,
      data,
      where: "id=?",
      whereArgs: [_existing.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return connectionSettings;
  }
}
