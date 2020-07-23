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
  final DateTime timestamp;
  _ChatHistoryMessage({
    this.id,
    this.historyId,
    this.sender,
    this.message,
    this.timestamp,
  });

  static _ChatHistoryMessage fromMap(Map<String, dynamic> data) {
    return _ChatHistoryMessage(
      id: data["id"],
      historyId: data["history_id"],
      sender: data["sender"],
      message: data["message"],
      timestamp: DateTime.parse(data["timestamp"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "history_id": historyId,
      "sender": sender,
      "message": message,
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
      print("chatHistoryId = $chatHistoryId");
    } else {
      chatHistoryId = chatHistory.id;
      await chmProvider.add(
        _ChatHistoryMessage(
          historyId: chatHistoryId,
          timestamp: DateTime.now(),
          message: msg.text,
          sender: isSent ? null : msg.from.username,
        ),
      );
    }
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

  Future<void> add(_ChatHistoryMessage chatHistoryMessage) async {
    Database db = await _storage.getDB();
    await db.insert(
      _tableName,
      chatHistoryMessage.toMap(),
    );
  }
}
