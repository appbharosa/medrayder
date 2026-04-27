import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/routes/app_url.dart';
import '../../network/dio_network/dio_client.dart';

class UserSendOtpRepository {
  final DioClient dioClient;

  UserSendOtpRepository(this.dioClient);

  Future<void> sendOtp({
    required String email,
  }) async {
    FormData formData = FormData.fromMap({
      "email": email,
    });

    final response =
    await dioClient.post(AppUrl.sendUserOtp, data: formData);

    if (response["status"] != 200) {
      throw response["message"];
    }
  }
}