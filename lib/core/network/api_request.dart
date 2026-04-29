import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../di/app_dependency.dart';
import '../constants/http_method.dart';
import '../typedef/typedef.dart';
import '../errors/api_failure.dart';
import 'api_client.dart';
import '../errors/api_exception.dart';

@injectable
class ApiRequest {
  // Use the injected instance from app_dependency
  final ApiClient? apiClient = instance<ApiClient>();

  Future<Either<ApiFailure, T>> performRequest<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? params,
    Function? fromJson,
    bool isMultipart = false,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int? id,
  }) async {
    try {
      final response = await apiClient?.request(
        url: id != null ? '$url/$id' : url,
        method: method,
        params: params,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        formData: isMultipart ? FormData.fromMap(params ?? {}) : null,
        isMultipart: isMultipart,
      );

      if (fromJson != null) {
        return Right(fromJson(response));
      } else {
        return Right(response);
      }
    } catch (error, stackTrace) {
      logError(error, stackTrace, url, params ?? {});
      return Left(ApiException.handle(error).failure);
    }
  }

  void logError(dynamic error, dynamic stackTrace, String url, Params params) {
    log('Error on $url: $error\nStack Trace: $stackTrace');
  }
}
