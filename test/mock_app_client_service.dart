import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';

class MockAppClientService extends AppClientServices {
  FutureOr<BaseResponse<List<AssessmentModel>>> getAssessment({
    int page = 1,
    int sizePage = 20,
    String? query,
    int? version,
    CancelToken? cancelToken,
  }) async {
    return BaseResponse<List<AssessmentModel>>()
      ..payload = [
        AssessmentModel()..id = '1',
        AssessmentModel()..title = 'Example',
        AssessmentModel()..description = 'Example',
        AssessmentModel()..htmlContent = 'Example',
        AssessmentModel()..publishDate = DateTime.now(),
        AssessmentModel()..startDate = DateTime.now(),
        AssessmentModel()..endDate = DateTime.now(),
        AssessmentModel()..createdDt = DateTime.now(),
        AssessmentModel()..updatedDt = DateTime.now(),
        AssessmentModel()..totalQuestion = 9999,
        AssessmentModel()..isActive = true,
        AssessmentModel()..version = 0,
        AssessmentModel()..assessmentId = '0',
        AssessmentModel()
          ..questions = [
            Question()
              ..answers = [
                Answer()
                  ..id = '0'
                  ..imageUrl = 'Example'
                  ..isRightAnswer = true
                  ..questionId = '0'
                  ..score = 0
                  ..title = 'Example'
              ]
              ..assessmentId = '0'
              ..id = '0'
              ..imageUrl = 'Example'
              ..keyBehaviorId = '0'
              ..title = 'Example'
              ..topic = 'Example'
              ..type = 0
          ]
      ];
  }

  FutureOr<BaseResponse<AssessmentModel>> getDetailAssessment(
    String? id, {
    CancelToken? cancelToken,
  }) async {
    AssessmentModel assessmentModel = AssessmentModel();
    assessmentModel.questions = [
      Question()
        ..answers = [
          Answer()
            ..id = '0'
            ..imageUrl = 'Example'
            ..isRightAnswer = true
            ..questionId = '0'
            ..score = 0
            ..title = 'Example'
        ]
        ..assessmentId = '0'
        ..id = '0'
        ..imageUrl = 'Example'
        ..keyBehaviorId = '0'
        ..title = 'Example'
        ..topic = 'Example'
        ..type = 0
    ];
    return BaseResponse<AssessmentModel>()..payload = assessmentModel;
  }
}

FutureOr<BaseResponse<UserProfile>> getUserProfile({
  CancelToken? cancelToken,
}) async {
  UserProfile userProfile = UserProfile();
  userProfile.userId = '0';
  userProfile.username = 'Example';
  userProfile.fullname = 'Example';
  userProfile.createdDate = DateTime.now();
  userProfile.type = 'Example';
  userProfile.userType = 0;
  userProfile.email = 'Example';
  userProfile.birthPlace = 'Example';
  userProfile.birthDay = DateTime.now();
  userProfile.avatar = 'Example';
  userProfile.registerProvider = 'Example';
  userProfile.assessmentVersion = 0;
  return BaseResponse<UserProfile>()..payload = userProfile;
}
