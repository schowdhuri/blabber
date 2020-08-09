part of blabber_app_store;

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
