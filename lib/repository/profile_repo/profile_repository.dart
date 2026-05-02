
import 'package:flutter/cupertino.dart';

import '../../config/routes/app_url.dart';
import '../../model/profile_model/profile_model.dart';
import '../../network/dio_network/dio_client.dart';

class ProfileRepository {
  final DioClient dioClient;

  ProfileRepository(this.dioClient);

  Future<ProfileModel> getProfile() async {
    final response = await dioClient.get(AppUrl.getProfile);

    // ✅ Print the entire response for debugging
    print("Profile API Response: $response");

    // Or pretty-print using debugPrint (avoids truncation in some consoles)
    debugPrint("Profile Response: ${response.toString()}");

    if (response["status"] == 200) {
      // Optionally print only the result part
      print("Profile data: ${response["result"]}");
      return ProfileModel.fromJson(response);
    } else {
      print("Profile API Error: ${response["message"]}");
      throw Exception(response["message"]);
    }
  }
}