import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';

import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'detail_session_store.g.dart';

class DetailSessionStore = _DetailSessionStore with _$DetailSessionStore;

abstract class _DetailSessionStore extends BaseStore with Store {
  _DetailSessionStore({
    AppServices? appServices,
    AppClientServices? appClient,
    String? sessionId,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();

    goBack = Command.sync(() {
      appServices!.navigatorState!.pop();
    });

    getData = Command(() async {
      try {
        state = DataState.loading;

        final response = await appClient!.getDetailSeries(sessionId);
        seriesDetailItem = response.payload;

        if (seriesDetailItem!.todoListArr != null) {
          todos.clear();
          todos.addAll(seriesDetailItem!.todoListArr!.map((f) {
            return TileItem<String>()..value = f;
          }));
        }

        state = DataState.success;
      } catch (error) {
        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });

    goToDetail = Command.parameter((v) async {
      appServices!.navigatorState!.pushNamed('/detail', arguments: {
        'item': v,
      });
    });
  }

  @observable
  var state = DataState.none;

  @observable
  SeriesDetailItem? seriesDetailItem;

  late Command getData;

  late Command goBack;

  late Command<SeriesEpisode> goToDetail;

  @observable
  var todos = ObservableList<TileItem<String>>();
}
