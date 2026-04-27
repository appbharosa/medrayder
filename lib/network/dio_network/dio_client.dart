import 'dart:io';
import 'package:dio/dio.dart';
import 'package:executive/config/routes/app_url.dart';
import '../../config/routes/routes_name.dart';
import '../../config/session_manager/session_manager.dart';
import '../../main.dart';
import 'api_exception.dart';
import 'network_info.dart';

typedef TokenProvider = Future<String?> Function();

class DioClient {
  final Dio dio;
  final NetworkInfo networkInfo;
  final TokenProvider tokenProvider;
  static bool isLoggingOut = false; //

  DioClient({
    required this.dio,
    required this.networkInfo,
    required this.tokenProvider,
  }) {
    dio.options = BaseOptions(
      baseUrl: AppUrl.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {


          if (!await networkInfo.isConnected) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "No Internet Connection",
              ),
            );
          }

          ///  TOKEN ADD
          if (!_isPublicApi(options.path)) {
            final token = await tokenProvider();

            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          ///  BODY FIX
          if (options.data != null && options.data is Map) {
            options.data = Map<String, dynamic>.from(options.data);
          }

          handler.next(options);
        },

        ///  ERROR HANDLING
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          final path = error.requestOptions.path;


          if (_isPublicApi(path)) {
            return handler.next(error);
          }

          bool isTokenExpired = false;

          if (statusCode == 401) {
            final message = data?.toString().toLowerCase() ?? "";


            if (message.contains("token expired") ||
                message.contains("invalid token") ||
                message.contains("unauthorized")||
                message.contains("unauthenticated"))
          {
              isTokenExpired = true;
            }
          }


          if (isTokenExpired && !isLoggingOut) {
            isLoggingOut = true;

            await SessionManager.clearSession();

            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              RoutesName.loginScreen,
                  (route) => false,
            );

            Future.delayed(const Duration(seconds: 1), () {
              isLoggingOut = false;
            });

            return;
          }


          handler.next(error);
        },
      ),
    );
  }

  /// ================= PUBLIC APIs =================
  bool _isPublicApi(String path) {
    return path.contains("login");
  }

  /// ================= GET =================
  Future<dynamic> get(
      String url, {
        Map<String, dynamic>? query,
      }) async {
    try {
      final response = await dio.get(url, queryParameters: query);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw ApiException("Something went wrong");
    }
  }

  /// ================= POST =================
  Future<dynamic> post(
      String url, {
        dynamic data,
      }) async {
    try {
      final response = await dio.post(url, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw ApiException("Unexpected Error");
    }
  }

  /// =================  =================
  Future<dynamic> put(
      String url, {
        dynamic data,
      }) async {
    try {

      final response = await dio.put(url, data: data);

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw ApiException("Unexpected Error");
    }
  }

  /// ================= DELETE =================
  Future<dynamic> delete(
      String url, {
        dynamic data,
        Map<String, dynamic>? query,
      }) async {
    try {
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: query,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw ApiException("Unexpected Error");
    }
  }

  /// ================= RESPONSE =================
  dynamic _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }
    throw ApiException(
      response.data?["message"] ?? "Server Error",
    );
  }

  /// ================= ERROR =================
  ApiException _handleDioError(DioException e) {
    if (e.error is SocketException) {
      return ApiException("No Internet Connection");
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException("Connection Timeout");
      case DioExceptionType.sendTimeout:
        return ApiException("Send Timeout");
      case DioExceptionType.receiveTimeout:
        return ApiException("Receive Timeout");
      case DioExceptionType.badCertificate:
        return ApiException("SSL Certificate Error");
      case DioExceptionType.badResponse:
      //  FIX: Safely check message
        final data = e.response?.data;
        String message = "Server Error";

        if (data != null) {
          if (data is Map && data.containsKey("message")) {
            message = data["message"];
          } else if (data is String) {
            message = data; // sometimes backend sends string
          }
        }

        return ApiException(message);

      case DioExceptionType.cancel:
        return ApiException("Request Cancelled");
      case DioExceptionType.connectionError:
        return ApiException("No Internet Connection");
      default:
        return ApiException("Something went wrong");
    }
  }
}