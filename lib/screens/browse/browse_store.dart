import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/browse/browse_filter_store.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'browse_store.g.dart';

class BrowseStore = _BrowseStore with _$BrowseStore;

abstract class _BrowseStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _BrowseStore({
    AppClientServices? appClient,
    AppServices? appServices,
  }) {
    this.appClient = appClient ?? (appClient = this.appClient);
    appServices = appServices ?? sl.get<AppServices>();

    browseFilterStore = BrowseFilterStore();

    getData = Command(() async {
      try {
        if (items.isEmpty) {
          state = DataState.loading;
        } else {
          loadMoreState = DataState.loading;
        }

        final page = getPageFromOffset(pageLimit, items.length);
        final filterData = browseFilterStore!.filterData!;
        final request = GetBrowseRequest()
          ..topic =
              filterData.topics?.where((t) => t.isSelected == true).map((f) {
            return f.id;
          }).toList()
          ..contentType =
              filterData.types?.where((t) => t.isSelected == true).map((f) {
            return f.id;
          }).toList()
          ..rating = filterData.rating
          ..author =
              filterData.authors?.where((t) => t.isSelected == true).map((f) {
            return f.id;
          }).toList()
          ..page = page
          ..pageLimit = pageLimit
          ..query = query;
        final response = await appClient!.getBrowseSearch(
          request: request,
        );
        items.addAll(response.payload!);

        //kode hardcoded ada disini
        List<BrowseModel> listItem = [
          BrowseModel()
            ..title = 'Pembahasan Soal'
            ..type = 'Pembahasan Soal'
            ..imageThumbnail = 'images/bebras/bebras_pembahasan_soal.png'
            ..author = 'Bebras Indonesia',
          BrowseModel()
            ..title = 'Pembahasan Soal'
            ..type = 'Pembahasan Soal'
            ..imageThumbnail = 'images/bebras/bebras_pembahasan_soal_2.png'
            ..author = 'Bebras Indonesia',
          BrowseModel()
            ..title = 'Bebras Challenge'
            ..type = 'Bebras Challenge'
            ..imageThumbnail = 'images/bebras/bebras_challenge.png'
            ..author = 'Bebras Indonesia',
          BrowseModel()
            ..title = 'Bebras Challenge'
            ..type = 'Bebras Challenge'
            ..imageThumbnail = 'images/bebras/bebras_challenge.png'
            ..author = 'Bebras Indonesia',
        ];
        listItem = listItem
            .where((element) => element.title?.contains(query) ?? false)
            .toList();
        
        items.addAll(listItem);

        state = items.isNotEmpty ? DataState.success : DataState.empty;
        loadMoreState = DataState.none;
      } catch (error) {
        logger.e(error);

        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });

    {
      final queryObservable = MobxUtils.toStream(() => query)
          .skip(1)
          .delay(const Duration(milliseconds: 350));
      final filterDataObservable = MobxUtils.toStream(() {
        return browseFilterStore!.filterData;
      }).where((t) {
        return t != null;
      });
      final d = MergeStream([
        dataRefresher,
        filterDataObservable,
        queryObservable,
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

    goToDetail = Command.syncParameter((v) {
      appServices!.navigatorState!.pushNamed('/detail', arguments: {
        'item': v,
      });
    });

    _getDefaultFilter = Command.parameter((p) async {
      try {
        state = DataState.loading;
        await browseFilterStore!.getDefaultFilter.executeIf(p);
      } catch (error) {
        logger.e(error);
      } finally {
        state = DataState.none;
      }
    });

    {
      final d = getDefaultFilterRefresher
          .asyncExpand(
            (e) => DeferStream(
              () {
                if (e != null) {
                  browseFilterStore!.filterData = null;
                }

                return _getDefaultFilter.execute(e).asStream();
              },
            ),
          )
          .listen(null);
      registerDispose(() {
        d.cancel();
      });
    }

    showBrowseFilter = Command(() async {
      if (browseFilterStore!.filterData == null) {
        return;
      } else {
        await filterInteraction.handle(
          browseFilterStore!.filterData,
        );
      }
    });

    registerDispose(() {
      browseFilterStore!.dispose();
      dataRefresher.close();
      loadMoreRefresher.close();
      getDefaultFilterRefresher.close();
    });

    _tutorialWalkthroughStore = TutorialWalkthroughStore(
      'tutorial_browse',
    );
    tutorialWalkthroughStore!.tutorials.addAll([
      TutorialWalkthroughBasicData()
        ..title = 'Filter'
        ..description = ''
        ..status = '1/2',
      TutorialWalkthroughBasicData()
        ..title = 'Search'
        ..description = ''
        ..status = '2/2',
    ]);
  }

  @observable
  BrowseFilterStore? browseFilterStore;

  @observable
  DataState state = DataState.none;

  @observable
  DataState loadMoreState = DataState.none;

  @observable
  String query = '';

  final dataRefresher = PublishSubject();

  final loadMoreRefresher = PublishSubject();

  late Command getData;

  late Command<Map<String, Object>> _getDefaultFilter;

  final getDefaultFilterRefresher = PublishSubject<Map<String, Object>?>();

  @observable
  var items = ObservableList<BrowseModel>();

  late Command<BrowseModel> goToDetail;

  final filterInteraction = Interaction<BrowseFilterData?, BrowseFilterData?>();

  late Command showBrowseFilter;

  TutorialWalkthroughStore? _tutorialWalkthroughStore;
  TutorialWalkthroughStore? get tutorialWalkthroughStore =>
      _tutorialWalkthroughStore;
}
