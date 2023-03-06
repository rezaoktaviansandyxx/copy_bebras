import 'package:dio/dio.dart';

getErrorMessage(error) {
  if (error is DioError) {
    if (error.response != null) {
      return error.response!.data['message'];
    }
  }

  return 'Something happened';
}
