import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/routes/app_url.dart';
import '../../network/dio_network/dio_client.dart';

class UserOtpVerifyRepository {
  final DioClient dioClient;

  UserOtpVerifyRepository(this.dioClient);

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    FormData formData = FormData.fromMap({
      "email_id": email,
      "otp": otp,
    });

    final response =
    await dioClient.post(AppUrl.userOtpVerify, data: formData);

    if (response["status"] != 200) {
      throw response["message"];
    }
  }
}