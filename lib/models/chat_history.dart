import 'package:sqflite/sqflite.dart';

import '../storage/storage.dart';
import 'buddy.dart';
import 'chat_message.dart';

class ChatHistory {
  final int id;
  final String buddy;
  final List<_ChatHistoryMessage> messages;
  ChatHistory({this.id, this.buddy, this.messages});

  List<ChatMessage> getChatMessages(Buddy buddy) {
    return List<ChatMessage>.generate(messages.length, (int index) {
      bool isReceived = messages[index].sender == buddy.username;
      return ChatMessage(
        timestamp: messages[index].timestamp,
        text: messages[index].message,
        from: isReceived ? buddy : null,
        to: isReceived ? null : buddy,
      );
    });
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "buddy": buddy,
    };
  }

  static ChatHistory fromMap(Map<String, dynamic> data) {
    return ChatHistory(
      buddy: data["buddy"],
      id: data["id"],
      messages: data["messages"] ?? [],
    );
  }
}

class _ChatHistoryMessage {
  final int id;
  final int historyId;
  final String sender;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  _ChatHistoryMessage({
    this.id,
    this.historyId,
    this.sender,
    this.message,
    this.timestamp,
    this.isRead = false,
  });

  static _ChatHistoryMessage fromMap(Map<String, dynamic> data) {
    return _ChatHistoryMessage(
      id: data["id"],
      historyId: data["history_id"],
      sender: data["sender"],
      message: data["message"],
      isRead: data["is_read"] == 0 ? false : true,
      timestamp: DateTime.parse(data["timestamp"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "history_id": historyId,
      "sender": sender,
      "message": message,
      "is_read": isRead ? 1 : 0,
      "timestamp": timestamp.toIso8601String(),
    };
  }
}

class ChatHistoryProvider {
  final Storage _storage = Storage();
  final String _tableName = "chat_history";
  final _ChatHistoryMessageProvider chmProvider = _ChatHistoryMessageProvider();

  Future<ChatHistory> get(Buddy buddy) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "buddy=?",
      whereArgs: [buddy.username],
    );
    if (result.length != 1) {
      return null;
    }
    List<_ChatHistoryMessage> _chatHistoryMessages =
        await chmProvider.get(result[0]["id"]);
    return ChatHistory(
      id: result[0]["id"],
      buddy: buddy.username,
      messages: _chatHistoryMessages,
    );
  }

  Future<ChatMessage> getLatestMessage(Buddy buddy) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "buddy=?",
      whereArgs: [buddy.username],
    );
    if (result.length != 1) {
      return null;
    }
    _ChatHistoryMessage _chatHistoryMessage =
        await chmProvider.getLatest(result[0]["id"]);
    if (_chatHistoryMessage == null) {
      return null;
    }
    return ChatMessage(
      from: _chatHistoryMessage.sender == buddy.username ? buddy : null,
      to: _chatHistoryMessage.sender == buddy.username ? null : buddy,
      timestamp: _chatHistoryMessage.timestamp,
      text: _chatHistoryMessage.message,
    );
  }

  Future<int> getUnreadCount(Buddy buddy) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "buddy=?",
      whereArgs: [buddy.username],
    );
    if (result.length != 1) {
      return null;
    }
    return chmProvider.getUnreadCount(result[0]["id"]);
  }

  Future<void> add(Buddy buddy, ChatMessage msg) async {
    Database db = await _storage.getDB();
    bool isSent = msg.from == null;
    int chatHistoryId;
    ChatHistory chatHistory = await get(buddy);
    if (chatHistory == null) {
      ChatHistory chatHistory = ChatHistory(buddy: buddy.username);
      chatHistoryId = await db.insert(
        _tableName,
        chatHistory.toMap(),
      );
    } else {
      chatHistoryId = chatHistory.id;
      await chmProvider.add(
        _ChatHistoryMessage(
          historyId: chatHistoryId,
          timestamp: DateTime.now(),
          message: msg.text,
          sender: isSent ? null : msg.from.username,
          isRead: msg.isRead,
        ),
      );
    }
  }

  Future<void> markAllRead(Buddy buddy) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "buddy=?",
      whereArgs: [buddy.username],
    );
    if (result.length != 1) {
      return;
    }
    await chmProvider.markAllRead(result[0]["id"]);
  }
}

class _ChatHistoryMessageProvider {
  Storage _storage = Storage();
  final String _tableName = "chat_history_message";

  Future<List<_ChatHistoryMessage>> get(int chatHistoryId) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "history_id=?",
      whereArgs: [chatHistoryId],
    );
    return List<_ChatHistoryMessage>.generate(
      result.length,
      (index) => _ChatHistoryMessage.fromMap(result[index]),
    );
  }

  Future<_ChatHistoryMessage> getLatest(int chatHistoryId) async {
    Database db = await _storage.getDB();
    List result = await db.query(
      _tableName,
      where: "history_id=?",
      whereArgs: [chatHistoryId],
      orderBy: "timestamp desc",
      limit: 1,
    );
    return _ChatHistoryMessage.fromMap(result[0]);
  }

  Future<int> getUnreadCount(int chatHistoryId) async {
    Database db = await _storage.getDB();
    return Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) "
          "FROM $_tableName "
          "WHERE is_read=0"),
    );
  }

  Future<void> add(_ChatHistoryMessage chatHistoryMessage) async {
    Database db = await _storage.getDB();
    await db.insert(
      _tableName,
      chatHistoryMessage.toMap(),
    );
  }

  Future<void> markAllRead(int chatHistoryId) async {
    Database db = await _storage.getDB();
    await db.update(
      _tableName,
      {"is_read": 1},
      where: "history_id=?",
      whereArgs: [chatHistoryId],
    );
  }
}
