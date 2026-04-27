
import 'dart:io';

import 'package:dio/dio.dart';

import '../../config/routes/app_url.dart';
import '../../model/profile_model/profile_update_response.dart';
import '../../network/dio_network/dio_client.dart';

class UpdateProfileRepository {
  final DioClient dioClient;

  UpdateProfileRepository(this.dioClient);

  Future<UpdateProfileResponse> updateProfile({
    required String name,
    required String gender,
    required String occupation,
    required String dob,
    File? image,
  }) async {

    FormData formData = FormData.fromMap({
      "name": name,
      "gender": gender,
      "occupation": occupation,
      "dob": dob,
      if (image != null)
        "image": await MultipartFile.fromFile(image.path),
    });

    final response = await dioClient.post(
      AppUrl.updateProfile,
      data: formData,
    );

    if (response["status"] == 200) {
      return UpdateProfileResponse.fromJson(response);
    } else {
      throw response["message"];
    }
  }
}