import 'dart:io';

abstract class UserEvent {}

class FetchUsers extends UserEvent {
  final bool reset;
  final String? search;
  FetchUsers({this.reset = false, this.search});
}

class AddUser extends UserEvent {
  final String name, email, mobile, gender, dob;
  final int bloodGroupId, coverageCategoryId, userId;
  final File? image;
  final String hno;
  final String buildingNo;
  final String landmark;
  final String address;
  final String pincode;
  final String state;
  final String city;
  final String addressType;
  final bool isDefault;

  AddUser({
    required this.name,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.dob,
    required this.bloodGroupId,
    required this.coverageCategoryId,
    required this.userId,
    this.image,
    required this.hno,
    required this.buildingNo,
    required this.landmark,
    required this.address,
    required this.pincode,
    required this.state,
    required this.city,
    required this.addressType,
    required this.isDefault,
  });
}