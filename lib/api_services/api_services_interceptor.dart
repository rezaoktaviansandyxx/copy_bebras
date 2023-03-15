import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'api_services.dart';
import 'dart:convert' show jsonEncode;

import '../appsettings.dart';

class ApiServicesInterceptor extends Interceptor {
  final secureStorage = sl.get<SecureStorage>();

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers.containsKey(authorization)) {
      final loginResponse = await (secureStorage!.getLoginResponse());
      if (loginResponse != null) {
        options.headers[authorization] =
            '${loginResponse.tokenScheme} ${loginResponse.token}';
      }
    }
    if (kDebugMode) {
      final sb = StringBuffer();
      separator() {
        sb.writeln('==================================');
      }

      separator();
      sb.writeln(jsonEncode(options.method));
      sb.writeln(jsonEncode(options.path));
      sb.writeln(jsonEncode(options.headers));
      sb.writeln(jsonEncode(options.queryParameters));
      sb.writeln(jsonEncode(options.data));
      separator();
      logger.i(sb.toString());
    }
    super.onRequest(options, handler);
  }

  // @override
  // Future onError(DioError err) {
  //   return super.onError(err);
  // }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    final data = response;
    bool? isSuccess = data.data["isSuccess"];
    if (isSuccess == null || !isSuccess) {
      if (data.data['statusCode'] == 401) {
        final logoutProvider = sl.get<ApiServicesInterceptorLogoutProvider>()!;
        await logoutProvider.logout();
        handler.next(response);
      } else {
        final error = DioError(
          response: response,
          type: DioErrorType.response,
          error: DioErrorType.response,
          requestOptions: RequestOptions(
            path: '',
          ),
        );
        handler.reject(error);
      }
      return;
    }
    super.onResponse(response, handler);
  }
}

abstract class ApiServicesInterceptorLogoutProvider {
  Future logout();
}
