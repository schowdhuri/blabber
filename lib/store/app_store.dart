library blabber_app_store;

import '../models/buddy.dart';
import '../models/chat_message.dart';

part 'actions.dart';
part 'app_state.dart';

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
