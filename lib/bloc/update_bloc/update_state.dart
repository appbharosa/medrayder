import '../../model/update_response/update_response.dart';

abstract class UpdateState {}

class UpdateInitial extends UpdateState {}

class UpdateLoading extends UpdateState {}

class UpdateNotRequired extends UpdateState {}

class ForceUpdateRequired extends UpdateState {
  final UpdateResult result;

  ForceUpdateRequired(this.result);
}

class NewVersionAvailable extends UpdateState {
  final UpdateResult result;

  NewVersionAvailable(this.result);
}

class UpdateError extends UpdateState {
  final String message;

  UpdateError(this.message);
}

class NavigateToPlayStore extends UpdateState {
  final String updateUrl;

  NavigateToPlayStore(this.updateUrl);
}