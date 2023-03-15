import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/goals/goals_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';

part 'detail_accept_goals_store.g.dart';

class AcceptGoalRequest {
  String? goalName;

  late List<String?> todos;
}

class DetailAcceptGoalsStore = _DetailAcceptGoalsStore
    with _$DetailAcceptGoalsStore;

abstract class _DetailAcceptGoalsStore extends BaseStore with Store {
  _DetailAcceptGoalsStore({
    AppClientServices? appClientServices,
    AppServices? appServices,
  }) {
    appClientServices = appClientServices ?? sl.get<AppClientServices>();
    appServices = appServices ?? sl.get<AppServices>();

    acceptGoals = Command.parameter((p) async {
      final prevState = state;
      try {
        state = DataState.loading;

        final responseAddGoal = await appClientServices!.addGoal(
          AddGoalItemRequest()
            ..goalName = p!.goalName
            ..items = p.todos.map((f) {
              return TodoItem()
                ..isCompleted = false
                ..isRecurring = false
                ..name = f
                ..notes = ''
                ..reminderType = ReminderTypeEnum.none
                ..hour = 0;
            }).toList()
            ..notes = '',
        );

        final goalId = responseAddGoal.payload;
        final detailGoal = await appClientServices.getGoal(goalId);
        final goalItemStore = ListGoalItemModel()..item = detailGoal.payload;
        appServices!.navigatorState!.pushNamed(
          '/detail_goals',
          arguments: {
            'item': goalItemStore,
            'goalsStore': null,
            'titleMode': TitleMode.edit,
          },
        );
      } catch (error) {
        alertInteraction.handle(getErrorMessage(error));

        logger.e(error);
      } finally {
        state = prevState;
      }
    });
  }

  @observable
  var state = DataState.none;

  late Command<AcceptGoalRequest> acceptGoals;

  final alertInteraction = Interaction<String?, Object>();
}
