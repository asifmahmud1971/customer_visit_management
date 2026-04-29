import 'package:dio/dio.dart';
import '../internet_connection_checker.dart';

class ConnectivityInterceptor extends Interceptor {
  final InternetConnectionChecker _connectivity;

  ConnectivityInterceptor(this._connectivity);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!await _connectivity.hasInternetConnection()) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
        ),
      );
    }
    handler.next(options);
  }
}
