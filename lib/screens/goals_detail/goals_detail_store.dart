import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/goals/goals_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:tuple/tuple.dart';

import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'goals_detail_store.g.dart';

class GoalsDetailStore = _GoalsDetailStore with _$GoalsDetailStore;

abstract class _GoalsDetailStore extends BaseStore with Store {
  _GoalsDetailStore({
    AppClientServices? appClient,
    bool isCompletedTab = true,
  }) {
    appClient = appClient ?? sl.get<AppClientServices>();

    getData = Command(() async {
      try {} catch (error) {
        logger.e(error);

        state = DataState(
          enumSelector: EnumSelector.error,
          message: getErrorMessage(error),
        );
      }
    });

    addGoalTodo = Command(() async {
      try {
        final newGoalTodo = await addDialogInteraction.handle(null);
        if (newGoalTodo == null) {
          return;
        }

        final newItem = GoalItem.fromJson(item!.item!.toJson());
        newItem.todos!.add(
          TodoItem()
            ..dueDate = newGoalTodo.item1.dueDate
            ..id = newGoalTodo.item2
            ..isCompleted = false
            ..isRecurring = false
            ..name = newGoalTodo.item1.name
            ..notes = newGoalTodo.item1.notes
            ..reminderDate = newGoalTodo.item1.reminderDate
            ..reminderType = newGoalTodo.item1.reminderType
            ..hour = newGoalTodo.item1.hour,
        );
        item!.item = newItem;
      } catch (e) {
        logger.e(e);
      }
    });
  }

  @observable
  DataState state = DataState.none;

  Command? getData;

  @observable
  ListGoalItemModel? item;

  final addDialogInteraction =
      Interaction<Object?, Tuple2<AddGoalTodoRequest, String>>();

  Command? addGoalTodo;
}
