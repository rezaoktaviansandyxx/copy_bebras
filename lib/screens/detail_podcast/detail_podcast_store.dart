import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:tuple/tuple.dart';

import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'detail_podcast_store.g.dart';

class DetailPodcastStore = _DetailPodcastStore with _$DetailPodcastStore;

abstract class _DetailPodcastStore extends BaseStore with Store {
  _DetailPodcastStore({
    AppServices? appServices,
    AppClientServices? appClient,
    String? podcastId,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();

    goBack = Command.sync(() {
      appServices!.navigatorState!.pop();
    });

    getData = Command(() async {
      try {
        state = DataState.loading;

        final response = await appClient!.getDetailPodcast(podcastId);
        podcastDetailItem = response.payload;

        state = DataState.success;
      } catch (error) {
        state = DataState.error;
      }
    });

    {
      final d = MobxUtils.toStream(() => podcastDetailItem)
          .where((t) => t != null)
          .listen((v) {
        episodes.clear();

        final _episodes = podcastDetailItem!.episodes!.map((f) {
          return TileItem<PodcastEpisode>()..value = f;
        });
        episodes.addAll(_episodes);

        final firstEpisodeIndex = episodes.indexWhere(
          (t) => t != null,
        );
        if (firstEpisodeIndex >= 0) {
          playEpisode.executeIf(
            Tuple2(episodes[firstEpisodeIndex], firstEpisodeIndex),
          );
        }

        if (podcastDetailItem!.todoListArr != null) {
          todos.clear();
          todos.addAll(podcastDetailItem!.todoListArr!.map((f) {
            return TileItem<String>()..value = f;
          }));
        }
      });
      registerDispose(() {
        d.cancel();
      });
    }

    playEpisode = Command.parameter((v) async {
      try {
        if (v!.item1.isSelected == true) {
          return;
        }

        state = DataState.loading;

        // Set completed if user play the last episode
        if (v.item2 == podcastDetailItem!.episodes!.length - 1) {
          await appClient!.setActivityCompleted(
            SetCompleteActivityRequest()
              ..contentId = podcastDetailItem!.id
              ..type = 'podcast',
          );
        }

        episodes.forEach((t) {
          t.isSelected = false;
        });

        selectedEpisode = v.item1;
        selectedEpisode!.isSelected = true;

        state = DataState.success;
      } catch (error) {
        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });
  }

  @observable
  var state = DataState.none;

  @observable
  PodcastDetailItem? podcastDetailItem;

  late Command getData;

  late Command goBack;

  @observable
  var episodes = ObservableList<TileItem<PodcastEpisode>>();

  @observable
  TileItem<PodcastEpisode>? selectedEpisode;

  late Command<Tuple2<TileItem<PodcastEpisode>, int>> playEpisode;

  @observable
  var todos = ObservableList<TileItem<String>>();
}
