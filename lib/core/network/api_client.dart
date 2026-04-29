import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../utils/app_preference.dart';
import '../constants/http_method.dart';
import '../errors/api_exception.dart';
import 'api_urls.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'internet_connection_checker.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;
  final AppPreferences _appPreferences;
  final InternetConnectionChecker _internetConnectionChecker;

  ApiClient(
    this._dio,
    this._appPreferences,
    this._internetConnectionChecker,
  ) {
    _initInterceptors();
  }

  void _initInterceptors() {
    _dio.options.baseUrl = ApiUrls.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.addAll([
      ConnectivityInterceptor(_internetConnectionChecker),
      HeaderInterceptor(_appPreferences),
      RetryInterceptor(_dio),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    ]);
  }

  Future<dynamic> request({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? params,
    FormData? formData,
    bool isMultipart = false,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.request(
        url,
        data: isMultipart ? formData : params,
        queryParameters: method == HttpMethod.get ? params : null,
        options: Options(method: method.name.toUpperCase()),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } on DioException catch (e) {
      throw ApiException.handle(e);
    } catch (e) {
      log('Unexpected Error: $e');
      rethrow;
    }
  }
}
