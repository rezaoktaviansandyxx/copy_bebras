import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

part 'assessment_chart_store.g.dart';

class AssessmentChartStore = _AssessmentChartStore with _$AssessmentChartStore;

abstract class _AssessmentChartStore extends BaseStore with Store {
  _AssessmentChartStore({
    AppServices? appServices,
    AppClientServices? appClient,
    SecureStorage? secureStorage,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();
    secureStorage = secureStorage ?? sl.get<SecureStorage>();

    getData = Command(() async {
      try {
        state = DataState.loading;

        // final response = await appClient.getUserAssessment();
        // items.clear();
        // if (response?.payload != null) {
        //   items.addAll(response.payload);
        // }
        final userProfile = await (secureStorage!.getUserProfile());
        if (userProfile != null) {
          final myAssessmentv2 = await (appClient!.getUserAssessmentV2(
            userProfile.assessmentVersion,
          ));
          items.clear();
          if (myAssessmentv2 != null && myAssessmentv2.payload != null) {
            items.addAll(myAssessmentv2.payload!.map((e) {
              e.assessmentVersion = userProfile.assessmentVersion;
              return e;
            }));
          }
        }

        state = items.isNotEmpty ? DataState.success : DataState.empty;
      } catch (error) {
        logger.e(error);

        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });

    {
      final d = MergeStream([
        dataRefresher,
      ]).doOnData((_) {
        items.clear();
      }).asyncExpand((_) {
        return Stream.fromFuture(getData.executeIf());
      }).listen(null);
      registerDispose(
        () => d.cancel(),
      );
    }

    registerDispose(() {
      dataRefresher.close();
    });
  }

  @observable
  DataState state = DataState.none;

  final dataRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<MyAssessmentModelV2>();
}
