import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';

part 'related_detail_content_store.g.dart';

class RelatedDetailContentStore = _RelatedDetailContentStore
    with _$RelatedDetailContentStore;

abstract class _RelatedDetailContentStore extends BaseStore with Store {
  _RelatedDetailContentStore({
    AppServices? appServices,
    AppClientServices? appClientServices,
  }) {
    appClientServices ??= sl.get<AppClientServices>();
    appServices ??= sl.get<AppServices>();

    getRelatedContent = Command.parameter((id) async {
      try {
        getDataState = DataState.loading;

        final result = await appClientServices!.getRelatedContent(id);
        if (result.payload == null || result.payload!.isEmpty) {
          getDataState = DataState.none;
        } else {
          listRelatedContent.clear();
          listRelatedContent.addAll(result.payload!);
          getDataState = DataState.success;
        }
      } catch (error) {
        getDataState = DataState(
          enumSelector: EnumSelector.error,
          message: error.toString(),
        );
      }
    });

    goToDetail = Command.syncParameter((parameter) async {
      appServices!.navigatorState!.pushNamed('/detail', arguments: {
        'item': parameter,
      });
    });
  }

  @observable
  var getDataState = DataState.none;

  late Command<String> getRelatedContent;

  final listRelatedContent = ObservableList<BrowseModel>();

  late Command<BrowseModel> goToDetail;
}
