import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'list_of_author_store.g.dart';

class ListOfAuthorStore = _ListOfAuthorStore with _$ListOfAuthorStore;

abstract class _ListOfAuthorStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _ListOfAuthorStore({
    AppClientServices? appClient,
  }) {
    this.appClient = appClient ?? (appClient = this.appClient);

    getData = Command(() async {
      try {
        state = DataState.loading;

        final response = await appClient!.getListAuthor(
          page: 1,
          pageSize: pageLimit,
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

    registerDispose(() {
      dataRefresher.close();
    });
  }

  @observable
  DataState state = DataState.none;

  final dataRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<AuthorModel>();
}
