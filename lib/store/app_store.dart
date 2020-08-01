class AppState {
  String path;
  dynamic pathArgs;

  AppState({this.path, this.pathArgs});
}

AppState appReducer(AppState state, DispatchAction action) {
  switch (action?.type) {
    case ActionType.ChangePage:
      {
        ChangePageAction cpa = action;
        return AppState(
          path: cpa.path,
          pathArgs: cpa.arguments,
        );
      }
    default:
  }
  return state;
}

enum ActionType {
  ChangePage,
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
