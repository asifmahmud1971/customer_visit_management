import 'package:dio/dio.dart';
import 'api_failure.dart';

class ApiException implements Exception {
  final ApiFailure failure;

  ApiException(this.failure);

  factory ApiException.handle(dynamic error) {
    if (error is DioException) {
      return ApiException(_handleDioError(error));
    } else {
      return ApiException(const ApiFailure('An unexpected error occurred'));
    }
  }

  static ApiFailure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 'Bad response';
        return ApiFailure(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const ApiFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const ApiFailure('No internet connection');
      default:
        return const ApiFailure('Something went wrong');
    }
  }
}
