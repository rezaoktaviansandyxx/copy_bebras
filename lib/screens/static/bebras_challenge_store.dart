
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

part 'bebras_challenge_store.g.dart';

class BebrasChallengeStore = _BebrasChallengeStore with _$BebrasChallengeStore;

abstract class _BebrasChallengeStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _BebrasChallengeStore({
    AppServices? appServices,
    AppClientServices? appClient,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    this.appClient = appClient ?? (appClient = this.appClient);

    getData = Command(() async {
      try {
        state = DataState.loading;

        final request = GetBrowseRequest()
          ..contentType = ['Bebras Challenge']
          ..page = 1
          ..pageLimit = pageLimit
          ..query = '';
        final response = await appClient!.getBrowseSearch(
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