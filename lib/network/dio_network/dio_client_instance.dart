import 'package:dio/dio.dart';
import 'package:executive/config/session_manager/session_manager.dart';
import 'network_info.dart';
import 'dio_client.dart';

class DioClientInstance {
  static DioClient? _instance;

  static DioClient getInstance() {
    if (_instance == null) {
      _instance = DioClient(
        dio: Dio(),
        networkInfo: NetworkInfo(),
        tokenProvider: () async => await SessionManager.getToken(),
      );
    }
    return _instance!;
  }
}