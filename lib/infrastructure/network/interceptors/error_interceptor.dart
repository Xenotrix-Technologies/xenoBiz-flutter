import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          message = 'Session expired. Please log in again.';
        } else if (statusCode == 403) {
          message = 'Access denied. You do not have permission for this action.';
        } else if (statusCode == 404) {
          message = 'Requested resource not found.';
        } else if (statusCode == 422) {
          message = 'Validation error. Please check your input fields.';
        } else if (statusCode == 429) {
          message = 'Too many requests. Please try again in a moment.';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error occurred. Please try again later.';
        } else {
          message = 'An unexpected error occurred (Code: $statusCode).';
        }
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection available. Switched to offline mode.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
        break;
    }

    final customErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
    );

    super.onError(customErr, handler);
  }
}
