import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'popular_session_store.g.dart';

class PopularSessionStore = _PopularSessionStore with _$PopularSessionStore;

abstract class _PopularSessionStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _PopularSessionStore({
    AppServices? appServices,
    AppClientServices? appClient,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    this.appClient = appClient ?? (appClient = this.appClient);

    getData = Command(() async {
      try {
        state = DataState.loading;

        final request = GetBrowseRequest()
          ..page = 1
          ..pageLimit = pageLimit
          ..query = '';
        final response = await appClient!.getSearchPopular(
          request: request,
        );
        items.clear();
        items.addAll(response.payload!);

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

    goToDetail = Command.syncParameter((v) {
      Get.toNamed('/detail', arguments: {
        'item': v,
      });
      // appServices!.navigatorState!.pushNamed('/detail', arguments: {
      //   'item': v,
      // });
    });

    registerDispose(() {
      dataRefresher.close();
    });
  }

  @observable
  DataState state = DataState.none;

  final dataRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<BrowseModel>();

  late Command<BrowseModel> goToDetail;
}
