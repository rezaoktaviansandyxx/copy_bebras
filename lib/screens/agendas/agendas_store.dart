import 'package:collection/collection.dart' show IterableExtension;
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../api_services/api_services.dart';
import '../../api_services/api_services_models.dart';
import '../../appsettings.dart';

part 'agendas_store.g.dart';

class AgendasStore = _AgendasStore with _$AgendasStore;

abstract class _AgendasStore extends BaseStore with Store {
  _AgendasStore({
    AppClientServices? appClient,
    AppServices? appServices,
  }) {
    appClient = appClient ?? sl.get<AppClientServices>();
    appServices = appServices ?? sl.get<AppServices>();

    getData = Command(() async {
      try {
        state = DataState.loading;

        final request = GetAgendaRequest()..date = date.value;
        final response = await appClient!.getTodoAgenda(
          request,
        );
        items.clear();
        items.addAll(response.payload!.map((f) {
          return AgendaItemStore()..item = f;
        }));

        final _goals = await appClient.getGoals();
        goals.clear();
        goals.addAll(_goals.payload!);
        selectedGoal = goals.firstWhereOrNull(
          (element) => element != null,
        );

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
      final dateObservable = date
          .where((t) => t != null)
          .skip(1)
          .debounceTime(const Duration(
            milliseconds: 350,
          ))
          .map((_) => null);
      final d = MergeStream([
        date.where((t) => t != null).take(1).map((_) => null),
        dateObservable,
      ]).asyncExpand((_) {
        return DeferStream(
          () => Stream.fromFuture(
            getData.executeIf(),
          ),
        );
      }).listen(null);
      registerDispose(
        () => d.cancel(),
      );
    }

    completeAgenda = Command.parameter((v) async {
      DataState? prevState;
      try {
        prevState = v!.state;
        v.state = DataState.loading;

        final newItem = TodoItem.fromJson(v.item!.toJson());
        newItem.isCompleted = !newItem.isCompleted!;
        await appClient!.editTodo(newItem);
        v.item = newItem;
      } catch (error) {
        logger.e(error);
      } finally {
        v!.state = prevState;
      }
    });

    addTodo = Command.parameter((p) async {
      if (p!.isValidReminder != true) {
        return;
      }

      DataState? prevState;
      try {
        prevState = state;

        final request = AddGoalTodoRequest()
          ..dueDate = p.dueDate
          ..goalId = p.selectedGoal!.id
          ..hour = p.hour ?? 0
          ..name = p.taskName
          ..notes = ''
          ..reminderDate = p.reminderDate
          ..reminderType = p.reminderType;
        await appClient!.addTodoInGoal(p.selectedGoal!.id, request);
        date.add(date.value);
      } catch (error) {
        logger.e(error);
      } finally {
        state = prevState;
      }
    });

    deleteTodo = Command.parameter((p) async {
      DataState? prevState;
      try {
        prevState = state;

        await appClient!.deleteTodo(p!.id);
        items.removeWhere((element) => element.item!.id == p.id);

        appServices!.navigatorState!.pop();
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      } finally {
        state = prevState;
      }
    });

    completeTodo = Command.parameter((p) async {
      try {
        var newValue = TodoItem.fromJson(p!.item!.toJson());
        newValue.isCompleted = !newValue.isCompleted!;
        await appClient!.editTodo(newValue);
        p.item = newValue;
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      }
    });

    editDueDate = Command.parameter((p) async {
      try {
        var newValue = TodoItem.fromJson(p!.item1.toJson());
        newValue.dueDate = p.item2;
        await appClient!.editTodo(newValue);
        p.item1.changeItem(newValue);
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      }
    });

    editReminder = Command.parameter((p) async {
      try {
        var newValue = TodoItem.fromJson(p!.item1.toJson());
        newValue.reminderType = p.item2;
        if (p.item2 != ReminderTypeEnum.once) {
          newValue.reminderDate = null;
        } else {
          newValue.reminderDate = p.item3;
        }
        await appClient!.editTodo(newValue);
        p.item1.changeItem(newValue);
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      }
    });

    editNotes = Command.parameter((p) async {
      try {
        final newItem = TodoItem.fromJson(p!.item1.toJson());
        newItem.notes = p.item2 ?? '';
        await appClient!.editTodo(newItem);
        p.item1.changeItem(newItem);
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      }
    });

    editHour = Command.parameter((p) async {
      try {
        final newItem = TodoItem.fromJson(p!.item1.toJson());
        newItem.hour = p.item2 ?? 0;
        await appClient!.editTodo(newItem);
        p.item1.changeItem(newItem);
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(getErrorMessage(error));
      }
    });

    editTodo = Command.parameter((p) async {
      if (p!.item2.isValidReminder != true) {
        return;
      }

      try {
        p.item1.editTodoState.add(DataState.loading);

        await appClient!.editTodo(p.item2);
        p.item1.item = p.item2;
        date.add(date.value);

        p.item1.editTodoState.add(DataState.success);
        appServices!.navigatorState!.pop();
      } catch (error) {
        logger.e(error);
        // alertInteraction.handle(getErrorMessage(error));
        p.item1.editTodoState.add(
          DataState(
            enumSelector: EnumSelector.error,
            message: getErrorMessage(error),
          ),
        );
      }
    } as Future<dynamic> Function(Tuple2<AgendaItemStore?, TodoItem>?));

    registerDispose(() {
      date.close();
    });
  }

  final alertInteraction = Interaction<String?, Object?>();

  @observable
  DataState? state = DataState.none;

  final date = BehaviorSubject<DateTime>.seeded(DateTime.now());

  late Command getData;

  @observable
  var items = ObservableList<AgendaItemStore>();

  @observable
  var goals = ObservableList<GoalItem>();

  @observable
  GoalItem? selectedGoal;

  @computed
  int get completedCount {
    final _completedCount =
        items.where((t) => t.item!.isCompleted == true).length;
    return _completedCount;
  }

  @computed
  double get completedPercentage {
    if (items.length == 0) {
      return 0;
    }

    final _completedPercentage = completedCount / items.length;
    return _completedPercentage;
  }

  late Command<AgendaItemStore> completeAgenda;

  late Command<TodoAddModel> addTodo;

  late Command<TodoItem> deleteTodo;

  late Command<AgendaItemStore> completeTodo;

  Command<Tuple2<TodoItem, DateTime>>? editDueDate;

  Command<Tuple3<TodoItem, ReminderTypeEnum, DateTime>>? editReminder;

  Command<Tuple2<TodoItem, String>>? editNotes;

  Command<Tuple2<TodoItem, int>>? editHour;

  late Command<Tuple2<AgendaItemStore?, TodoItem>> editTodo;
}

class AgendaItemStore = _AgendaItemStore with _$AgendaItemStore;

abstract class _AgendaItemStore extends BaseStore with Store {
  @observable
  TodoItem? item;

  @observable
  DataState? state = DataState.none;

  var editTodoState = BehaviorSubject<DataState>.seeded(DataState.success);

  @override
  Future dispose() {
    editTodoState.close();

    return super.dispose();
  }
}
