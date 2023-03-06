import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:mobx/mobx.dart';

import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'detail_video_store.g.dart';

class DetailVideoStore = _DetailVideoStore with _$DetailVideoStore;

abstract class _DetailVideoStore extends BaseStore with Store {
  _DetailVideoStore({
    AppServices? appServices,
    AppClientServices? appClient,
    String? videoId,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();

    goBack = Command.sync(() {
      appServices!.navigatorState!.pop();
    });

    getData = Command(() async {
      try {
        state = DataState.loading;

        final response = await appClient!.getDetailVideo(videoId);
        videoDetailItem = response.payload;

        if (videoDetailItem!.todoListArr != null) {
          todos.clear();
          todos.addAll(videoDetailItem!.todoListArr!.map((f) {
            return TileItem<String>()..value = f;
          }));
        }

        state = DataState.success;
      } catch (error) {
        state = DataState.error;
      }
    });

    setComplete = Command(() async {
      try {
        await appClient!.setActivityCompleted(
          SetCompleteActivityRequest()
            ..contentId = videoDetailItem!.id
            ..type = getBrowseTypeName(BrowseType.video),
        );
      } catch (error) {
        logger.e(error);
      }
    });
  }

  @observable
  var state = DataState.none;

  @observable
  VideoDetailItem? videoDetailItem;

  late Command getData;

  late Command goBack;

  @observable
  var todos = ObservableList<TileItem<String>>();

  late Command setComplete;
}
