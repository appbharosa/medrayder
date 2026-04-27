import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/routes/app_url.dart';
import '../../network/dio_network/dio_client.dart';

class UserPostRepository {
  final DioClient dioClient;

  UserPostRepository(this.dioClient);

  Future<void> postUser({
    required int userId,
    required String name,
    required String email,
    required String mobile,
    required String gender,
    required String dob,
    required int bloodGroupId,
    required int coverageCategoryId,

    // Address
    required String hno,
    required String buildingNo,
    required String landmark,
    required String address,
    required String pincode,
    required String state,
    required String city,
    required String addressType,
    required bool isDefault,

    File? image,

    // Nominee
    required String nomineeFullName,
    required String nomineeMobile,
    required String nomineeDateOfBirth,
    required String nomineeRelationship,
    required String nomineeGender,
  }) async {
    FormData formData = FormData.fromMap({
      "user_id": userId,
      "name": name,
      "email": email,
      "mobile": mobile,
      "gender": gender,
      "dob": dob,
      "blood_group": bloodGroupId,
      "coverage_category": coverageCategoryId,

      // Address
      "hno": hno,
      "building_no": buildingNo,
      "landmark": landmark,
      "address": address,
      "pincode": pincode,
      "state": state,
      "city": city,
      "address_type": addressType,
      "default_address": isDefault ? 1 : 0,

      // Nominee
      "nominee_full_name": nomineeFullName,
      "nominee_mobile": nomineeMobile,
      "nominee_date_of_birth": nomineeDateOfBirth,
      "nominee_relationship": nomineeRelationship,
      "nominee_gender": nomineeGender,

      if (image != null)
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split("/").last,
        ),
    });

    final response = await dioClient.post(AppUrl.getUsers, data: formData);
    if (response["status"] != 200) {
      throw response["message"];
    }
  }
}