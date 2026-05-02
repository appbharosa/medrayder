import 'dart:io';

abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class ToggleEditEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String gender;
  final String occupation;
  final String dob;
  final String panCard;
  final File? image;

  UpdateProfileEvent({
    required this.name,
    required this.gender,
    required this.occupation,
    required this.dob,
    required this.panCard,
    this.image,
  });
}