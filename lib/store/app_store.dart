import 'package:chat/models/buddy.dart';
import 'package:chat/models/chat_message.dart';

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

AppState appReducer(AppState state, DispatchAction action) {
  switch (action?.type) {
    case ActionType.ChangePage:
      {
        ChangePageAction cpa = action;
        return state.copy()
          .._path = cpa.path
          .._pathArgs = cpa.arguments;
      }

    case ActionType.AddBuddy:
      {
        AddBuddyAction _action = action;
        List<ChatMessage> messages = _action.messages ?? [];
        AppState nextState = state.copy()
          .._buddies = [
            ...state._buddies,
            _action.buddy,
          ];
        if (messages.isNotEmpty) {
          nextState._latestMessage = {
            ...nextState._latestMessage,
            _action.buddy.username: messages.last,
          };
          nextState._unreadCounts = {
            ...nextState._unreadCounts,
            _action.buddy.username: messages.length,
          };
        }
        return nextState;
      }

    case ActionType.UpdateBuddyProfiles:
      {
        UpdateBuddiesAction _action = action;
        AppState newState = state.copy();
        newState._buddies = _action.buddies.map((Buddy buddy) {
          try {
            Buddy match = state.buddies
                .firstWhere((Buddy b) => buddy.username == b.username);
            buddy.imageData = match.imageData;
            buddy.name = match.name;
          } catch (ex0) {}
          return buddy;
        }).toList();
        return newState;
      }

    case ActionType.UpdateBuddies:
      {
        UpdateBuddiesAction _action = action;
        AppState newState = state.copy();
        newState._buddies = _action.buddies;
        return newState;
      }

    case ActionType.RemoveBuddies:
      {
        RemoveBuddiesAction _action = action;
        AppState nextState = state.copy();
        _action.buddies.forEach((Buddy b) {
          nextState.buddies.remove(b);
          nextState._latestMessage.remove(b.username);
          nextState._unreadCounts.remove(b.username);
        });
        return nextState;
      }

    case ActionType.UpdateUnreadCounts:
      {
        UpdateUnreadCountsAction _action = action;
        return state.copy().._unreadCounts = _action.values;
      }

    case ActionType.UpdateLatestMessage:
      {
        UpdateLatestMessageAction _action = action;
        AppState nextState = state.copy();
        nextState._latestMessage = {
          ...nextState._latestMessage,
          _action.username: _action.chatMessage,
        };
        return nextState;
      }

    case ActionType.UpdateLatestMessages:
      {
        UpdateLatestMessagesAction _action = action;
        return state.copy().._latestMessage = _action.values;
      }

    default:
      return state;
  }
}

enum ActionType {
  ChangePage,
  AddBuddy,
  UpdateBuddyProfiles,
  UpdateBuddies,
  RemoveBuddies,
  UpdateUnreadCounts,
  UpdateLatestMessage,
  UpdateLatestMessages,
}

abstract class DispatchAction {
  ActionType type;
  DispatchAction(this.type);
}

class ChangePageAction extends DispatchAction {
  final String path;
  final dynamic arguments;
  ChangePageAction(this.path, this.arguments) : super(ActionType.ChangePage);
}

class AddBuddyAction extends DispatchAction {
  final Buddy buddy;
  final List<ChatMessage> messages;
  AddBuddyAction(this.buddy, {this.messages = const []})
      : super(ActionType.AddBuddy);
}

class UpdateBuddiesAction extends DispatchAction {
  final List<Buddy> buddies;
  UpdateBuddiesAction(this.buddies) : super(ActionType.UpdateBuddies);
}

class RemoveBuddiesAction extends DispatchAction {
  final List<Buddy> buddies;
  RemoveBuddiesAction(this.buddies) : super(ActionType.RemoveBuddies);
}

class UpdateUnreadCountsAction extends DispatchAction {
  final Map<String, int> values;
  UpdateUnreadCountsAction(this.values) : super(ActionType.UpdateUnreadCounts);
}

class UpdateLatestMessageAction extends DispatchAction {
  final String username;
  final ChatMessage chatMessage;

  UpdateLatestMessageAction(this.username, this.chatMessage)
      : super(ActionType.UpdateLatestMessage);
}

class UpdateLatestMessagesAction extends DispatchAction {
  final Map<String, ChatMessage> values;
  UpdateLatestMessagesAction(this.values)
      : super(ActionType.UpdateLatestMessages);
}
