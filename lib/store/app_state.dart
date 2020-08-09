part of blabber_app_store;

class AppState {
  String _path;
  dynamic _pathArgs;
  List<Buddy> _buddies;
  Map<String, ChatMessage> _latestMessage;
  Map<String, int> _unreadCounts;

  String get path => _path;
  dynamic get pathArgs => _pathArgs;
  List<Buddy> get buddies => _buddies ?? [];
  Map<String, ChatMessage> get latestMessage => _latestMessage ?? {};
  Map<String, int> get unreadCounts => _unreadCounts ?? {};

  AppState({
    String path,
    dynamic pathArgs,
    List<Buddy> buddies,
    Map<String, ChatMessage> latestMessage,
    Map<String, int> unreadCounts,
  }) {
    _path = path;
    _pathArgs = pathArgs;
    _buddies = buddies;
    _latestMessage = latestMessage;
    _unreadCounts = unreadCounts;
  }

  set pathArgs(_pathArgs) {}

  AppState copy() {
    return AppState(
      path: _path,
      pathArgs: _pathArgs,
      buddies: _buddies,
      latestMessage: _latestMessage,
      unreadCounts: _unreadCounts,
    );
  }
}
