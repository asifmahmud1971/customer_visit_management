import 'package:dio/dio.dart';
import '../../utils/app_preference.dart';

class HeaderInterceptor extends Interceptor {
  final AppPreferences _appPreferences;

  HeaderInterceptor(this._appPreferences);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    final token = _appPreferences.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
