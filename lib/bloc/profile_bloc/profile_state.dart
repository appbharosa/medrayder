import '../../model/profile_model/profile_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final bool isEditable;
  final String? message;

  ProfileLoaded(
      this.profile, {
        this.isEditable = false,
        this.message,
      });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}