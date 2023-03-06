import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

part 'interest_store.g.dart';

class InterestStore = _InterestStore with _$InterestStore;

abstract class _InterestStore extends BaseStore with Store {
  _InterestStore({
    AppServices? appServices,
    AppClientServices? appClient,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();

    getData = Command(() async {
      try {
        state = DataState.loading;

        final _myInterests = await appClient!.getMyInterest();

        final response = await appClient.getTopic(
          GetTopicRequest()
            ..page = 1
            ..pageLimit = 100
            ..query = '',
        );
        items.clear();
        if (response?.payload != null) {
          items.addAll(response.payload!.map((f) {
            if (_myInterests.payload!.where((t) => t.topicId == f.id).length ==
                1) {
              f.isSelected = true;
            }

            return f;
          }));
        }

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

    saveInterest = Command.parameter((v) async {
      try {
        final onSaved = v!.item1;
        final isFirstTime = v.item2;

        final selectedItems = items.where((t) => t.isSelected == true);
        if (selectedItems.isEmpty) {
          return;
        }

        state = DataState.loading;

        for (var item in selectedItems) {
          final request = UserInterestRequest()..topicId = item.id;
          await appClient!.saveInterest(
            request,
          );
        }

        final unselectedItems = items.where((t) => t.isSelected != true);
        for (var item in unselectedItems) {
          final request = UserInterestRequest()..topicId = item.id;
          await appClient!.removeInterest(
            request,
          );
        }

        if (isFirstTime == true) {
          appServices!.navigatorState!.pushNamedAndRemoveUntil(
            '/user_registered_success',
            (_) => false,
          );
        } else {
          if (appServices!.navigatorState!.canPop()) {
            appServices.navigatorState!.pop();
          } else {
            appServices.navigatorState!.pushNamed('/');
          }
        }

        state = items.isNotEmpty ? DataState.success : DataState.empty;
        if (onSaved != null) {
          onSaved();
        }
      } catch (error) {
        logger.e(error);

        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    } as Future<dynamic> Function(Tuple2<Function?, bool>?));
  }

  @observable
  DataState state = DataState.none;

  final dataRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<TopicItem>();

  @action
  void changeItems(Function(ObservableList<TopicItem>) f) {
    f(items);
  }

  late Command<Tuple2<Function?, bool>> saveInterest;
}
