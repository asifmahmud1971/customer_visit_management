import 'dart:developer';
import 'package:dio/dio.dart';

/// Intercepts 429 Too Many Requests responses and retries with exponential backoff.
/// Reads `retry_after` from the response body (seconds). Caps wait at 10s for UX.
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 3;

  RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (err.response?.statusCode == 429 && retryCount < _maxRetries) {
      int waitSeconds = 5;
      try {
        final data = err.response?.data;
        if (data is Map && data['retry_after'] != null) {
          waitSeconds = (data['retry_after'] as num).toInt().clamp(1, 10);
        }
      } catch (_) {}

      // Exponential backoff: base wait * (retryCount + 1), capped at 10s
      final delay = Duration(seconds: (waitSeconds * (retryCount + 1)).clamp(1, 10));
      log('429 Rate limited. Retry ${retryCount + 1}/$_maxRetries after ${delay.inSeconds}s...');
      
      await Future.delayed(delay);

      final options = err.requestOptions;
      options.extra['retryCount'] = retryCount + 1;

      try {
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    }

    return handler.next(err);
  }
}
