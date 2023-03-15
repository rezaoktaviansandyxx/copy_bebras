import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:quiver/strings.dart';

import '../../appsettings.dart';

part 'goals_create_store.g.dart';

class GoalsCreateStore = _GoalsCreateStore with _$GoalsCreateStore;

abstract class _GoalsCreateStore extends BaseStore with Store {
  _GoalsCreateStore({
    AppClientServices? appClientServices,
    AppServices? appServices,
  }) {
    appClientServices = appClientServices ?? sl.get<AppClientServices>();
    appServices = appServices ?? sl.get<AppServices>();

    createNewGoal = Command(() async {
      if (isBlank(goalName)) {
        await alertInteraction.handle('You have to set Goal name');
        return;
      }

      try {
        state = DataState.loading;

        final goalItem = AddGoalItemRequest()
          ..goalName = goalName
          ..notes = goalDescription ?? ''
          ..items = [];
        final id = await appClientServices!.addGoal(goalItem);
        logger.i('Goal created with id $id');

        appServices!.navigatorState!.pop(id);
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      } finally {
        state = DataState.none;
      }
    });
  }

  @observable
  var state = DataState.none;

  String? goalName;

  String? goalDescription;

  late Command createNewGoal;

  final alertInteraction = Interaction<String?, Object?>();
}
