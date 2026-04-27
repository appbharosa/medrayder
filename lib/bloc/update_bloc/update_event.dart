abstract class UpdateEvent {}

class CheckUpdateEvent extends UpdateEvent {}

class UserDismissedUpdateEvent extends UpdateEvent {}

class UserClickedUpdateEvent extends UpdateEvent {
  final String updateUrl;

  UserClickedUpdateEvent(this.updateUrl);
}