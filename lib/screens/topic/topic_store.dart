import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'topic_store.g.dart';

class TopicStore = _TopicStore with _$TopicStore;

abstract class _TopicStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _TopicStore({
    AppClientServices? appClient,
  }) {
    this.appClient = appClient ?? (appClient = this.appClient);

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
        final request = GetTopicRequest()
          ..page = page
          ..pageLimit = pageLimit
          ..query = query;
        final response = await appClient!.getTopic(
          request,
        );
        // items.addAll(response.payload!);
        items.addAll(
          [
            TopicItem()
              ..id = 'sikecil'
              ..iconUrl = 'images/icons/bebras_icon_sikecil.png'
              ..color = '#93C6F9'
              ..name = 'Sikecil',
            TopicItem()
              ..id = 'siaga'
              ..iconUrl = 'images/icons/bebras_icon_siaga.png'
              ..color = '#81E288'
              ..name = 'Siaga',
            TopicItem()
              ..id = 'penggalang'
              ..iconUrl = 'images/icons/bebras_icon_penggalang.png'
              ..color = '#FFC71F'
              ..name = 'Penggalang',
            TopicItem()
              ..id = 'penegak'
              ..iconUrl = 'images/icons/bebras_icon_penegak.png'
              ..color = '#EF4D56'
              ..name = 'Penegak',
          ],
        );

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
        MobxUtils.toStream(() => query),
        dataRefresher,
      ]).doOnData((_) {
        items.clear();
      }).mergeWith([
        loadMoreRefresher,
      ]).asyncExpand((_) {
        return Stream.fromFuture(getData.executeIf());
      }).listen(null);
      registerDispose(
        () => d.cancel(),
      );
    }

    registerDispose(() {
      dataRefresher.close();
      loadMoreRefresher.close();
    });
  }

  @observable
  DataState state = DataState.none;

  @observable
  DataState loadMoreState = DataState.none;

  @observable
  String query = '';

  final dataRefresher = PublishSubject();

  final loadMoreRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<TopicItem>();
}
