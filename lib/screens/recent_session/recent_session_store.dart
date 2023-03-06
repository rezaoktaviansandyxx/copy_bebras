import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'recent_session_store.g.dart';

class OnGoingRecentSessionStore = RecentSessionStore
    with _$OnGoingRecentSessionStore;
class CompletedRecentSessionStore = RecentSessionStore
    with _$OnGoingRecentSessionStore;

class RecentSessionStore = _RecentSessionStore with _$OnGoingRecentSessionStore;

abstract class _RecentSessionStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _RecentSessionStore({
    bool onGoingMode = true,
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
        final request = GetRecentSessionRequest()
          ..isCompleted = onGoingMode != true
          ..page = page
          ..pageLimit = pageLimit
          ..query = '';
        final response = await appClient!.getRecentSession(
          request,
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
      appServices!.navigatorState!.pushNamed('/detail', arguments: {
        'item': v,
      });
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
  var items = ObservableList<RecentSessionModel>();

  late Command<RecentSessionModel> goToDetail;
}
