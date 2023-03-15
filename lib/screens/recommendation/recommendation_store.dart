import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'recommendation_store.g.dart';

enum RecommendationType {
  byInterest,
  byAssessment,
}

class RecommendationStore = _RecommendationStore with _$RecommendationStore;

abstract class _RecommendationStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _RecommendationStore({
    RecommendationType? type,
    AppClientServices? appClient,
    AppServices? appServices,
  }) {
    this.appClient = appClient ?? (appClient = this.appClient);
    appServices = appServices ?? sl.get<AppServices>();

    var hasMoreData = true;
    getData = Command(() async {
      try {
        if (items.isEmpty) {
          state = DataState.loading;
        } else {
          if (!hasMoreData) {
            return;
          }

          loadMoreState = DataState.loading;
        }

        final page = getPageFromOffset(pageLimit, items.length);
        final request = GetBrowseRequest()
          ..page = page
          ..pageLimit = pageLimit
          ..query = '';
        final response = type == RecommendationType.byInterest
            ? await appClient!.getRecommendationByInterest(
                request: request,
              )
            : await appClient!.getRecommendationByAssessment(
                request: request,
              );
        items.addAll(response.payload!);

        state = items.isNotEmpty ? DataState.success : DataState.empty;
        loadMoreState = DataState.none;

        if (items.isNotEmpty) {
          hasMoreData = response.payload!.isNotEmpty;
        }
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
      }).mergeWith([
        loadMoreRefresher,
      ]).asyncExpand((_) {
        return DeferStream(
          () => Stream.fromFuture(
            getData.execute(),
          ),
        );
      }).listen(null);
      registerDispose(
        () => d.cancel(),
      );
    }

    registerDispose(() {
      dataRefresher.close();
      loadMoreRefresher.close();
    });

    goToDetail = Command.parameter((v) async {
      Get.toNamed('/detail', arguments: {
        'item': v,
      });
      // appServices!.navigatorState!.pushNamed('/detail', arguments: {
      //   'item': v,
      // });
    });
  }

  @observable
  DataState state = DataState.none;

  @observable
  DataState loadMoreState = DataState.none;

  final dataRefresher = PublishSubject();

  final loadMoreRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<BrowseModel>();

  late Command<BrowseModel> goToDetail;
}
