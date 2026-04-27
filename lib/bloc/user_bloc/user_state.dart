import '../../model/user_model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  final int currentPage;
  final int lastPage;

  UserLoaded({
    required this.users,
    required this.currentPage,
    required this.lastPage,
  });
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}

///  ACTION STATES (DO NOT BREAK UI)
abstract class UserActionState extends UserState {}

class UserAdding extends UserActionState {}

class UserAdded extends UserActionState {}

class UserAddError extends UserActionState {
  final String message;
  UserAddError(this.message);
}
class UserOtpSending extends UserState {}
class UserOtpSent extends UserState {}
class UserOtpVerifying extends UserState {}
class UserOtpVerified extends UserState {}

class UserOtpError extends UserState {
  final String message;
  UserOtpError(this.message);
}