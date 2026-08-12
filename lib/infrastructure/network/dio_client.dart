import 'package:dio/dio.dart';
import '../../const/durations.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageService secureStorage;

  DioClient({required this.secureStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppDurations.apiTimeout,
        receiveTimeout: AppDurations.apiTimeout,
        sendTimeout: AppDurations.apiTimeout,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      ErrorInterceptor(),
    ]);
  }
}
