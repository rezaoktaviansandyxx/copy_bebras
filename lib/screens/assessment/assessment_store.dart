// ignore: unused_import
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_result_screen.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/stores/indexing_iteration_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:tuple/tuple.dart';

part 'assessment_store.g.dart';

class AssessmentStore = _AssessmentStore with _$AssessmentStore;

abstract class _AssessmentStore extends BaseStore with Store {
  _AssessmentStore({
    AppServices? appServices,
    AppClientServices? appClientServices,
    SecureStorage? secureStorage,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClientServices = appClientServices ?? sl.get<AppClientServices>();
    secureStorage = secureStorage ?? sl.get<SecureStorage>();

    const String assessmentQuestionCheckpointKey = 'assessment';

    getAssessment = Command.parameter((existingAssessmentId) async {
      try {
        state = DataState.loading;

        final assessmentQuestionsKeys = (await secureStorage!.getAll())
            .entries
            .where((t) => t.key.startsWith(assessmentQuestionCheckpointKey))
            .toList();

        final _userProfile = await (secureStorage.getUserProfile());
        if (_userProfile == null) {
          return;
        }
        final _assessments = await appClientServices!.getAssessment(
          version: _userProfile.assessmentVersion,
        );
        for (var item1 in _assessments.payload!) {
          if (existingAssessmentId != null) {
            if (item1.id != existingAssessmentId) {
              logger.i('Skipping assessment id ${item1.id} ${item1.title}');
              continue;
            }
          }

          BaseResponse<AssessmentModel> firstDetailAssesment;
          if (item1.version == 2) {
            firstDetailAssesment =
                await appClientServices.getDetailAssessmentV3(
              item1.id,
            );
          } else {
            firstDetailAssesment = await appClientServices.getDetailAssessment(
              item1.id,
            );
          }
          for (var item2 in firstDetailAssesment.payload!.questions!) {
            final id = assessmentQuestionsKeys.firstWhereOrNull(
              (t) => t.key.contains(item2.id!),
            );
            if (id != null) {
              final selectedAnswer = item2.answers!.firstWhereOrNull(
                (t) => t.id == id.value,
              );
              item2.selectedAnswer = selectedAnswer;
            }
          }
          indexingAssessmentStore.items.add(firstDetailAssesment.payload);
        }

        {
          final _userProfile = await appClientServices.getUserProfile();
          userProfile = _userProfile.payload;
        }

        goToAssessment(0);
        appServices!.navigatorState!.pushReplacementNamed(
          '/assessment_question',
          arguments: {'store': this},
        );

        state = DataState.success;
      } catch (error) {
        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });

    tapAnswer = Command.parameter((p) async {
      await secureStorage!.write(
          '$assessmentQuestionCheckpointKey-${currentQuestion!.id}', p!.id);
      currentQuestion!.selectedAnswer = p;
    });

    submitAssessment = Command(() async {
      try {
        submitState = DataState.loading;

        Future<Tuple2<String?, MyAssessmentModelV2?>?> _submitAssessment(
            AssessmentModel assessment) async {
          Tuple2<String?, MyAssessmentModelV2?>? result;

          SubmitAssessmentRequest getSubmitRequest({
            int? version = 0,
          }) {
            final request = SubmitAssessmentRequest()
              ..assessmentId = assessment.id
              ..questions = assessment.questions!.map((f) {
                final questionRequest = SubmitAssessmentQuestionRequest()
                  ..answerId = f.selectedAnswer!.id
                  ..id = f.id
                  ..score = f.selectedAnswer!.score
                  ..topic = f.topic
                  ..keyBehaviorId = f.keyBehaviorId;
                if (version == 2) {
                  questionRequest.assessmentId = f.assessmentId;
                }
                return questionRequest;
              }).toList();
            if (version == 2) {
              request.version = version;
            }
            return request;
          }

          final request = getSubmitRequest(
            version: assessment.version,
          );
          if (assessment.version == 0) {
            await appClientServices!.submitAssessment(request);
            result = Tuple2(assessment.id, null);
          } else if (assessment.version == 1) {
            final r = await appClientServices!.submitAssessmentV2(request);
            result = Tuple2(null, r.payload);
          } else if (assessment.version == 2) {
            final r = await appClientServices!.submitAssessmentV3(request);
            result = Tuple2(null, r.payload);
          }
          if (kReleaseMode) {
            final allkeys = await secureStorage!.getAll();
            for (var item in allkeys.entries) {
              if (item.key.startsWith('$assessmentQuestionCheckpointKey-')) {
                await secureStorage.remove(item.key);
              }
            }
          }

          // appServices.navigatorState.pushAndRemoveUntil(
          //   MaterialPageRoute(builder: (BuildContext context) {
          //     return Scaffold(
          //       body: Column(
          //         crossAxisAlignment: CrossAxisAlignment.stretch,
          //         children: <Widget>[
          //           Expanded(
          //             child: AssessmentChartScreen(),
          //           ),
          //           Container(
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 15,
          //               vertical: 15,
          //             ),
          //             color: Theme.of(context).appBarTheme.color,
          //             child: SafeArea(
          //               top: false,
          //               left: false,
          //               right: false,
          //               child: Row(
          //                 children: <Widget>[
          //                   const Expanded(
          //                     child: const SizedBox(),
          //                   ),
          //                   Expanded(
          //                     child: Align(
          //                       alignment: Alignment.centerRight,
          //                       child: TextButton(
          //                         onPressed: () async {
          //                           if (appServices.navigatorState.canPop()) {
          //                             appServices.navigatorState.pop();
          //                           } else {
          //                             appServices.navigatorState
          //                                 .pushNamedAndRemoveUntil(
          //                               '/',
          //                               (_) => false,
          //                             );
          //                           }
          //                         },
          //                         shape: OutlineInputBorder(
          //                           borderRadius: BorderRadius.circular(
          //                             10,
          //                           ),
          //                           borderSide: BorderSide.none,
          //                         ),
          //                         color: const Color(0xff5AD57F),
          //                         child: Text(
          //                           'Ok',
          //                           style: TextStyle(
          //                             color: Colors.white,
          //                             fontFamily: 'Quicksand',
          //                             fontWeight: FontWeight.bold,
          //                             fontSize:
          //                                 FontSizesWidget.of(context).regular,
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   }),
          //   (r) {
          //     if (r.settings?.name == '/assessment_question' ||
          //         r.settings?.name == '/assessment_introduction') {
          //       return false;
          //     }

          //     return true;
          //   },
          // );

          return result;
        }

        final _currentAssessment = indexingAssessmentStore
            .items[indexingAssessmentStore.currentIndex]!;
        final submitResult = await (_submitAssessment(_currentAssessment));
        if (submitResult == null) {
          return;
        }
        final index = indexingAssessmentStore.currentIndex;
        final isLastItem = indexingAssessmentStore.isLastItem;

        if (isLastItem == true) {
          await changeIsFirstLoginAndEmptyAssessment.executeIf();
        }

        if (submitResult.item2 != null) {
          if (_currentAssessment.version == 2) {
            Get.until((route) => route.settings.name == '/main');
            // appServices!.navigatorState!.popUntil(
            //   (route) => route.settings.name == '/user_profile_screen',
            // );
          } else {
            appServices!.navigatorState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (BuildContext context) {
              return AssessmentResultScreenV2(
                isLastItem: isLastItem,
                assessmentModel: submitResult.item2,
              );
            }), (route) {
              return route.settings.name ==
                  '/assessment_introduction'; // 'assessment_introduction' won't get removed, it's the one who stopped the remover
            });
          }
        } else {
          appServices!.navigatorState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) {
            return AssessmentResultScreen(
              isLastItem: isLastItem,
              assessmentModel: indexingAssessmentStore.items[index],
            );
          }), (route) {
            return route.settings.name ==
                '/assessment_introduction'; // 'assessment_introduction' won't get removed, it's the one who stopped the remover
          });
        }

        // indexingAssessmentStore.currentIndex++;
        // Already set when 'Start self assessment'
        indexingAssessmentStore.currentIndex = 0;
        currentQuestionIndex = 0;
      } catch (error) {
        alertInteraction.handle(getErrorMessage(error.toString()));
      } finally {
        submitState = DataState.none;
      }
    });

    changeIsFirstLoginAndEmptyAssessment = Command(() async {
      // Set isFirstLoginAndEmptyAssessment to flag that first time login and empty assesment is skipped
      final loginResponse = await (secureStorage!.getLoginResponse());
      if (loginResponse == null) {
        return;
      }
      if (loginResponse.isFirstLoginAndEmptyAssessment == true) {
        final clonedLoginResponse = LoginResponse.fromJson(
          loginResponse.toJson(),
        );
        clonedLoginResponse.isFirstLoginAndEmptyAssessment = false;
        await secureStorage.setLoginResponse(clonedLoginResponse);
      }
    });
  }

  @observable
  var state = DataState.none;

  late Command<String> getAssessment;

  final indexingAssessmentStore = IndexingIterationStore<AssessmentModel?>();

  @computed
  AssessmentModel? get assessment => indexingAssessmentStore.currentItem;

  @observable
  @observable
  UserProfile? userProfile;

  @observable
  int currentQuestionIndex = 0;

  @computed
  Question? get currentQuestion {
    try {
      final q = assessment?.questions![currentQuestionIndex];
      return q;
    } catch (error) {
      logger.e(error);
      return null;
    }
  }

  late Command<Answer> tapAnswer;

  late Command submitAssessment;

  @observable
  var submitState = DataState.none;

  final alertInteraction = Interaction<String?, Object?>();

  void goToAssessment(int v) {
    indexingAssessmentStore.currentIndex = v;
    currentQuestionIndex = 0;
  }

  late Command changeIsFirstLoginAndEmptyAssessment;
}
