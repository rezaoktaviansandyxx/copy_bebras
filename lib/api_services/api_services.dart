import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';

import '../appsettings.dart';
import 'api_services_interceptor.dart';
import 'api_services_models.dart';
import 'package:quiver/strings.dart';

const String authorization = 'authorization';

abstract class AppClientServices {
  final Dio _dio = Dio();
  Dio get dio => _dio;

  var secureStorage = sl.get<SecureStorage>();

  AppClientServices({
    SecureStorage? secureStorage,
  }) {
    this.secureStorage = secureStorage ?? (secureStorage = this.secureStorage);

    dio.interceptors.add(ApiServicesInterceptor());
    if (kDebugMode) {
      dio.options.baseUrl = 'https://bebras-api.azurewebsites.net/';
    } else {
      dio.options.baseUrl = 'https://bebras-api.azurewebsites.net/';
    }
  }

  FutureOr<BaseResponse<LoginResponse>> auth(
    LoginRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.request(
      '/api/auth/login',
      options: Options(
        method: 'POST',
      ),
      data: request.toJson(),
      cancelToken: cancelToken,
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return LoginResponse.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<Response> registerUser(
    RegisterUserRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.request(
      '/api/user',
      options: Options(
        method: 'POST',
      ),
      data: request.toJson(),
      cancelToken: cancelToken,
    );
    return _result;
  }

  FutureOr<BaseResponse<UserProfile>> getUserProfile({
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/user/me',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return UserProfile.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<TopicItem>>> getTopic(
    GetTopicRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/topic',
      cancelToken: cancelToken,
      queryParameters: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return TopicItem.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<RecentSessionModel>>> getRecentSession(
    GetRecentSessionRequest request, {
    CancelToken? cancelToken,
  }) async {
    // final l = List.generate(request.pageLimit, (i) {
    //   final index = i + offset;
    //   return RecentSessionModel()
    //     ..category = 'Category'
    //     ..image = 'https://i.picsum.photos/id/1018/700/700.jpg'
    //     ..title = 'Title Title Title Title Title Title $index';
    // });
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/user/last_activity',
      cancelToken: cancelToken,
      queryParameters: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return RecentSessionModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<ArticleItem>>> getArticle(
    GetArticleRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/article',
      cancelToken: cancelToken,
      queryParameters: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return ArticleItem.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<ArticleDetailItem>> getDetailArticle(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/article/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return ArticleDetailItem.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<AuthorModel>>> getListAuthor({
    int? page,
    int? pageSize,
    String? query,
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/content/author',
      cancelToken: cancelToken,
      queryParameters: {
        'p': page,
        's': pageSize,
        'q': query,
      },
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return AuthorModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<BrowseModel>>> getBrowseSearch({
    required GetBrowseRequest request,
    CancelToken? cancelToken,
  }) async {
    final map = Map<String, dynamic>();
    if (request.topic?.isNotEmpty == true) {
      map.putIfAbsent('Topic', () {
        return request.topic;
      });
    }
    if (request.contentType?.isNotEmpty == true) {
      map.putIfAbsent('ContentType', () {
        return request.contentType;
      });
    }
    if (request.rating != null) {
      map.putIfAbsent('Rating', () {
        return request.rating.toString();
      });
    }
    if (request.author?.isNotEmpty == true) {
      map.putIfAbsent('Author', () {
        return request.author;
      });
    }
    if (request.page != null) {
      map.putIfAbsent('p', () {
        return request.page.toString();
      });
    }
    if (request.pageLimit != null) {
      map.putIfAbsent('s', () {
        return request.pageLimit.toString();
      });
    }
    if (!isBlank(request.query)) {
      map.putIfAbsent('q', () {
        return request.query;
      });
    }

    final uri = Uri(
      path: '/api/search',
      queryParameters: map,
    );

    final Response<Map<String, dynamic>> _result = await _dio.getUri(
      uri,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return BrowseModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<BrowseModel>>> getArticleSearch({
    required GetBrowseRequest request,
    CancelToken? cancelToken,
  }) async {
    final map = Map<String, dynamic>();
    if (request.topic?.isNotEmpty == true) {
      map.putIfAbsent('Topic', () {
        return request.topic;
      });
    }
    if (request.contentType?.isNotEmpty == true) {
      map.putIfAbsent('ContentType', () {
        return request.contentType;
      });
    }
    if (request.rating != null) {
      map.putIfAbsent('Rating', () {
        return request.rating.toString();
      });
    }
    if (request.author?.isNotEmpty == true) {
      map.putIfAbsent('Author', () {
        return request.author;
      });
    }
    if (request.page != null) {
      map.putIfAbsent('p', () {
        return request.page.toString();
      });
    }
    if (request.pageLimit != null) {
      map.putIfAbsent('s', () {
        return request.pageLimit.toString();
      });
    }
    if (!isBlank(request.query)) {
      map.putIfAbsent('q', () {
        return request.query;
      });
    }

    final uri = Uri(
      path: '/api/search',
      queryParameters: map,
    );

    final Response<Map<String, dynamic>> _result = await _dio.getUri(
      uri,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return BrowseModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<ActivityItem>>> getOnGoingActivity(
    GetActivityRequest request, {
    CancelToken? cancelToken,
  }) async {
    final offset = request.page! * request.size! - request.size!;
    final l = List.generate(request.size!, (i) {
      final index = i + offset;
      return ActivityItem()
        ..id = '$index'
        ..image = 'https://i.picsum.photos/id/1018/700/700.jpg'
        ..name = 'on going Title Title Title Title Title Title $index'
        ..category = 'Category'
        ..typeName = 'Type';
    });
    final response = BaseResponse<List<ActivityItem>>()..payload = l;
    await Future.delayed(const Duration(seconds: 2));
    return response;
  }

  FutureOr<BaseResponse<List<ActivityItem>>> getCompletedActivity(
    GetActivityRequest request, {
    CancelToken? cancelToken,
  }) async {
    final offset = request.page! * request.size! - request.size!;
    final l = List.generate(request.size!, (i) {
      final index = i + offset;
      return ActivityItem()
        ..id = '$index'
        ..image = 'https://i.picsum.photos/id/1018/700/700.jpg'
        ..name = 'Completed Title Title Title Title Title Title $index'
        ..category = 'Category'
        ..typeName = 'Type';
    });
    final response = BaseResponse<List<ActivityItem>>()..payload = l;
    await Future.delayed(const Duration(seconds: 2));
    return response;
  }

  FutureOr<BaseResponse<List<BrowseModel>>> getSearchPopular({
    required GetBrowseRequest request,
    CancelToken? cancelToken,
  }) async {
    final map = Map<String, dynamic>();
    if (request.page != null) {
      map.putIfAbsent('p', () {
        return request.page.toString();
      });
    }
    if (request.pageLimit != null) {
      map.putIfAbsent('s', () {
        return request.pageLimit.toString();
      });
    }
    if (!isBlank(request.query)) {
      map.putIfAbsent('q', () {
        return request.query;
      });
    }

    final uri = Uri(
      path: '/api/search/popular',
      queryParameters: map,
    );

    final Response<Map<String, dynamic>> _result = await _dio.getUri(
      uri,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return BrowseModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<PodcastDetailItem>> getDetailPodcast(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/podcast/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return PodcastDetailItem.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<VideoDetailItem>> getDetailVideo(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/video/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return VideoDetailItem.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<SeriesDetailItem>> getDetailSeries(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/series/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return SeriesDetailItem.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<GoalItem>>> getGoals({
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/todo',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return GoalItem.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<GoalItem>> getGoal(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/todo/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return GoalItem.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<String?>> addGoal(
    AddGoalItemRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.post(
      '/api/todo',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse<String?>.fromJson(_result.data!, (json) {
      final id = json as String?;
      return id;
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<TodoItem>> getTodo(
    String? todoId, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.get(
      '/api/todo/$todoId/detail',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data, (json) {
      return TodoItem.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<TodoItem>>> getTodoAgenda(
    GetAgendaRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/todo/agenda',
      cancelToken: cancelToken,
      queryParameters: {
        'DueDate': request.date?.toIso8601String(),
      },
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return TodoItem.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<Response<Map<String, dynamic>>> editTodo(
    TodoItem todoItem, {
    CancelToken? cancelToken,
  }) async {
    final data = jsonEncode(todoItem.toJson());
    final Response<Map<String, dynamic>> _result = await _dio.put(
      '/api/todo/${todoItem.id}',
      cancelToken: cancelToken,
      data: data,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<Response<Map<String, dynamic>>> deleteGoal(
    String? goalsId, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.delete(
      '/api/todo/delete_goal',
      cancelToken: cancelToken,
      queryParameters: {
        'id': goalsId,
      },
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<Response> deleteTodo(
    String? todoId, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.delete(
      '/api/todo/$todoId',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<BaseResponse<String?>> addTodoInGoal(
    String? goalId,
    AddGoalTodoRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/todo/$goalId/add_todo',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse<String?>.fromJson(_result.data, (json) {
      return json;
    });
    return Future.value(value);
  }

  FutureOr<Response> addActivity(
    AddUserActivityRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/user/activity',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<BaseResponse<List<UserActivityResponse>>> getLastActivity(
    GetLastActivityRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/user/last_activity',
      cancelToken: cancelToken,
      queryParameters: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return UserActivityResponse.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<Response> setActivityCompleted(
    SetCompleteActivityRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/user/set_complete',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<BaseResponse<List<MyAssessmentModel>>?> getUserAssessment({
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<Map<String, dynamic>> _result = await _dio.get(
        '/api/user/my_assessment',
        cancelToken: cancelToken,
        options: Options(
          headers: {
            authorization: '',
          },
        ),
      );
      final value = BaseResponse.fromJson(_result.data!, (json) {
        return MyAssessmentModel.fromListJson(json);
      });
      return Future.value(value);
    } catch (error) {
      if (error is DioError) {
        logger.i('User hasn\'t submit assessment');
        return null;
      } else {
        throw error;
      }
    }
  }

  FutureOr<BaseResponse<List<MyAssessmentModelV2>>?> getUserAssessmentV2(
    int? version, {
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<Map<String, dynamic>> _result = await _dio.get(
        '/api/user/v2/my_assessment',
        queryParameters: {
          'Version': version,
        },
        cancelToken: cancelToken,
        options: Options(
          headers: {
            authorization: '',
          },
        ),
      );
      final value = BaseResponse.fromJson(_result.data!, (json) {
        return MyAssessmentModelV2.fromListJson(json);
      });
      return Future.value(value);
    } catch (error) {
      if (error is DioError) {
        logger.i('User hasn\'t submit assessment');
        return null;
      } else {
        throw error;
      }
    }
  }

  FutureOr<BaseResponse<List<AssessmentModel>>> getAssessment({
    int page = 1,
    int sizePage = 20,
    String? query,
    int? version,
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/assessment',
      cancelToken: cancelToken,
      queryParameters: {
        'IsActive': true,
        'p': page,
        's': sizePage,
        'q': query ?? '',
        'version': version,
      },
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return AssessmentModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<AssessmentModel>> getDetailAssessment(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/assessment/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return AssessmentModel.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<AssessmentModel>> getDetailAssessmentV3(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final String json =
        await rootBundle.loadString('assets/jsonfile/soala.json');
    final _result = jsonDecode(json);
    // final Response<Map<String, dynamic>> _result = await _dio.get(
    //   '/api/assessment/v3/$id',
    //   cancelToken: cancelToken,
    //   options: Options(
    //     headers: {
    //       authorization: '',
    //     },
    //   ),
    // );
    final value = BaseResponse.fromJson(_result, (json) {
      return AssessmentModel.fromJson(json);
    });
    return Future.value(value);
  }

  FutureOr<Response> submitAssessment(
    SubmitAssessmentRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/assessment/submit',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<BaseResponse<MyAssessmentModelV2>> submitAssessmentV2(
    SubmitAssessmentRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/assessment/v2/submit',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data, (json) {
      return MyAssessmentModelV2.fromJson(json);
    });
    return value;
  }

  FutureOr<BaseResponse<MyAssessmentModelV2?>> submitAssessmentV3(
    SubmitAssessmentRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/assessment/v3/submit',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data, (json) {
      // return MyAssessmentModelV2.fromJson(json);
      final v = MyAssessmentModelV2.fromListJson(json);
      return v.firstWhereOrNull(
        (element) => element != null,
      );
    });
    return value;
  }

  FutureOr<BaseResponse<List<InterestModel>>> getMyInterest({
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/user/interest',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return InterestModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<Response> saveInterest(
    UserInterestRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/user/save_interest',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<Response> removeInterest(
    UserInterestRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/user/remove_interest',
      cancelToken: cancelToken,
      data: request.toJson(),
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<Response> updateFcmToken(
    String? fcmToken, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/user/update_fcm_token',
      cancelToken: cancelToken,
      data: {
        'fcmDeviceToken': fcmToken,
      },
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<Response> changePassword(
    String? oldPassword,
    String? newPassword,
    String? confirmNewPassword, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/auth/change_password',
      cancelToken: cancelToken,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmNewPassword,
      },
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }

  FutureOr<Response> forgotPassword(
    String? email, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/auth/forgot_password',
      cancelToken: cancelToken,
      data: {
        'email': email,
      },
    );
    return _result;
  }

  FutureOr<BaseResponse<List<BrowseModel>>> getRecommendationByInterest({
    required GetBrowseRequest request,
    CancelToken? cancelToken,
  }) async {
    final map = Map<String, dynamic>();
    if (request.page != null) {
      map.putIfAbsent('p', () {
        return request.page.toString();
      });
    }
    if (request.pageLimit != null) {
      map.putIfAbsent('s', () {
        return request.pageLimit.toString();
      });
    }
    if (!isBlank(request.query)) {
      map.putIfAbsent('q', () {
        return request.query;
      });
    }

    final uri = Uri(
      path: '/api/search/recommendation_by_interest',
      queryParameters: map,
    );

    final Response<Map<String, dynamic>> _result = await _dio.getUri(
      uri,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return BrowseModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<BrowseModel>>> getRecommendationByAssessment({
    required GetBrowseRequest request,
    CancelToken? cancelToken,
  }) async {
    final map = Map<String, dynamic>();
    if (request.page != null) {
      map.putIfAbsent('p', () {
        return request.page.toString();
      });
    }
    if (request.pageLimit != null) {
      map.putIfAbsent('s', () {
        return request.pageLimit.toString();
      });
    }
    if (!isBlank(request.query)) {
      map.putIfAbsent('q', () {
        return request.query;
      });
    }

    final uri = Uri(
      path: '/api/search/recommendation_by_assessment',
      queryParameters: map,
    );

    final Response<Map<String, dynamic>> _result = await _dio.getUri(
      uri,
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return BrowseModel.fromListJson(json);
    });
    return Future.value(value);
  }

  FutureOr<Response> contentRate(
    RateContentRequest request, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.request(
      '/api/content/rate',
      options: Options(
        method: 'POST',
        headers: {
          authorization: '',
        },
      ),
      data: request.toJson(),
      cancelToken: cancelToken,
    );
    return _result;
  }

  FutureOr<BaseResponse<List<FaqModel>>> getFaqs({
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/faq',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return FaqModel.fromListJson(json);
    });
    return value;
  }

  FutureOr<BaseResponse<List<TermConditionModel>>> getTermCondition({
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/term-condition/term_condition',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    final value = BaseResponse.fromJson(_result.data!, (json) {
      return TermConditionModel.fromListJson(json);
    });
    return value;
  }

  FutureOr<BaseResponse<List<TermConditionModel>>> getPrivacyPolicy({
    CancelToken? cancelToken,
  }) async {
    final termConditions = await getTermCondition(cancelToken: cancelToken);
    final privacyPolicy = termConditions.payload!.firstWhereOrNull(
      (element) => element.title!.toLowerCase() == 'privacy policy',
    );
    termConditions.payload = [privacyPolicy!];
    return termConditions;
  }

  FutureOr<BaseResponse<List<TermConditionModel>>> getAboutUs({
    CancelToken? cancelToken,
  }) async {
    final termConditions = await getTermCondition(cancelToken: cancelToken);
    final privacyPolicy = termConditions.payload!.firstWhereOrNull(
        (element) => element.title!.toLowerCase() == 'about us');
    termConditions.payload = [privacyPolicy!];
    return termConditions;
  }

  FutureOr<BaseResponse<bool?>> verifyCompany(
    String? companySite, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.post(
      '/api/auth/verify_company',
      cancelToken: cancelToken,
      data: {
        'companySite': companySite,
      },
    );
    final value = BaseResponse<bool?>.fromJson(_result.data!, (json) {
      final value = json as bool?;
      return value;
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<FindCompanyResponse>> findCompany(
    String email, {
    CancelToken? cancelToken,
  }) async {
    final Response _result = await _dio.post(
      '/api/auth/find_company',
      cancelToken: cancelToken,
      data: {
        'email': email,
      },
    );
    final value =
        BaseResponse<FindCompanyResponse>.fromJson(_result.data, (json) {
      final value = FindCompanyResponse.fromJson(json);
      return value;
    });
    return Future.value(value);
  }

  FutureOr<BaseResponse<List<BrowseModel>>> getRelatedContent(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    final Response<Map<String, dynamic>> _result = await _dio.get(
      '/api/content/related_content',
      queryParameters: {
        'id': id,
      },
      cancelToken: cancelToken,
    );
    final value =
        BaseResponse<List<BrowseModel>>.fromJson(_result.data!, (json) {
      final value = BrowseModel.fromListJson(json);
      return value;
    });
    return Future.value(value);
  }

  FutureOr<Response<Map<String, dynamic>>> editGoal(
    EditGoalRequest request, {
    CancelToken? cancelToken,
  }) async {
    final data = jsonEncode(request.toJson());
    final Response<Map<String, dynamic>> _result = await _dio.put(
      '/api/todo/update_goal',
      cancelToken: cancelToken,
      data: data,
      options: Options(
        headers: {
          authorization: '',
        },
      ),
    );
    return _result;
  }
}

class AppClientServicesImpl extends AppClientServices {}
