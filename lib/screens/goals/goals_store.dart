import 'package:collection/collection.dart' show IterableExtension;
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'goals_store.g.dart';

class GoalsStore = _GoalsStore with _$GoalsStore;

abstract class _GoalsStore extends BaseStore with Store {
  _GoalsStore({
    AppServices? appServices,
    AppClientServices? appClient,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();

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

        final response = await appClient!.getGoals();
        items.clear();
        final _items = response.payload!.map((e) {
          return ListGoalItemModel()..item = e;
        });
        items.addAll(_items);

        if (lastAddedGoalId != null) {
          final addedGoal = items.firstWhereOrNull(
            (t) => t.item!.id == lastAddedGoalId,
          );
          if (addedGoal != null) {
            goToDetail.executeIf(addedGoal);
          }
        }

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

        lastAddedGoalId = null;
      }
    });

    {
      final d = MergeStream([
        dataRefresher,
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

    goToDetail = Command.syncParameter((p) async {
      selectedDetailGoal = p;

      await appServices!.navigatorState!.pushNamed(
        '/detail_goals',
        arguments: {
          'item': p,
          'goalsStore': this,
        },
      );
      // dataRefresher.add(null);
    });

    registerDispose(() {
      dataRefresher.close();
      loadMoreRefresher.close();
    });

    _tutorialWalkthroughStore = TutorialWalkthroughStore(
      'tutorial_goals',
    );
    tutorialWalkthroughStore!.tutorials.addAll([
      TutorialWalkthroughBasicData()
        ..title = 'Create goals'
        ..description = ''
        ..status = '1/3',
      TutorialWalkthroughBasicData()
        ..title = 'List active goals'
        ..description = ''
        ..status = '2/3',
      TutorialWalkthroughBasicData()
        ..title = 'List completed goals'
        ..description = ''
        ..status = '3/3',
    ]);
  }

  @observable
  DataState state = DataState.none;

  @observable
  DataState loadMoreState = DataState.none;

  final dataRefresher = PublishSubject();

  final loadMoreRefresher = PublishSubject();

  late Command getData;

  @observable
  var items = ObservableList<ListGoalItemModel>();

  @computed
  ObservableList<ListGoalItemModel> get activeItems =>
      ObservableList.of(items.where((t) => t.isCompleted != true));

  @computed
  ObservableList<ListGoalItemModel> get completedItems =>
      ObservableList.of(items.where((t) => t.isCompleted == true));

  late Command<ListGoalItemModel> goToDetail;

  @observable
  ListGoalItemModel? selectedDetailGoal;

  String? lastAddedGoalId;

  TutorialWalkthroughStore? _tutorialWalkthroughStore;
  TutorialWalkthroughStore? get tutorialWalkthroughStore =>
      _tutorialWalkthroughStore;
}

class ListGoalItemModel = _ListGoalItemModel with _$ListGoalItemModel;

abstract class _ListGoalItemModel with Store {
  _ListGoalItemModel({
    AppClientServices? appClientServices,
    AppServices? appServices,
  }) {
    appClientServices = appClientServices ?? sl.get<AppClientServices>();
    appServices = appServices ?? sl.get<AppServices>();

    deleteGoal = Command.parameter((s) async {
      try {
        state = DataState.loading;

        await appClientServices!.deleteGoal(item!.id);
        if (s != null) {
          s.items.removeWhere((element) => element.item!.id == item!.id);
        }
        if (appServices!.navigatorState!.canPop()) {
          appServices.navigatorState!.pop();
        }

        state = DataState.none;
      } catch (error) {
        logger.e(error);

        state = DataState.error;
      }
    });

    editDueDate = Command.parameter((p) async {
      try {
        state = DataState.loading;

        var newValue = TodoItem.fromJson(p!.item1.toJson());
        if (p.item2 == null) {
          final newDueDate = await (datePickerInteraction
              .handle(newValue.dueDate ?? DateTime.now()));
          if (newDueDate == null) {
            return;
          }
          newValue.dueDate = newDueDate;
        } else {
          newValue.dueDate = p.item2;
        }
        await appClientServices!.editTodo(newValue);
        p.item1.changeItem(newValue);

        state = DataState.none;
      } catch (error) {
        logger.e(error);

        state = DataState.error;
      }
    } as Future<dynamic> Function(Tuple2<TodoItem, DateTime?>?));

    completeTodo = Command.parameter((p) async {
      try {
        completeState = DataState.loading;

        var newValue = TodoItem.fromJson(p!.toJson());
        newValue.isCompleted = !newValue.isCompleted!;
        await appClientServices!.editTodo(newValue);
        p.changeItem(newValue);

        completeState = DataState.none;
      } catch (error) {
        logger.e(error);

        completeState = DataState.error;
      }
    });

    addTodo = Command(() async {
      try {
        final r = await todoInteraction.handle(null) as TodoAddModel?;
        if (r == null) {
          return;
        }

        final id = await appClientServices!.addTodoInGoal(
          item!.id,
          AddGoalTodoRequest()
            ..goalId = item!.id
            ..dueDate = r.dueDate
            ..name = r.taskName
            ..notes = ''
            ..reminderDate = r.reminderDate
            ..reminderType = r.reminderType
            ..hour = r.hour,
        );

        item!.todos!.insert(
          0,
          TodoItem()
            ..id = id.payload
            ..dueDate = r.dueDate
            ..isCompleted = false
            ..isRecurring = false
            ..name = r.taskName
            ..notes = ''
            ..reminderDate = r.reminderDate
            ..reminderType = r.reminderType
            ..hour = r.hour,
        );
      } catch (error) {
        logger.e(error);
      }
    });

    editReminder = Command.parameter((p) async {
      try {
        completeState = DataState.loading;

        var newValue = TodoItem.fromJson(p!.item1.toJson());
        newValue.reminderType = p.item2;
        if (p.item2 != ReminderTypeEnum.once) {
          newValue.reminderDate = null;
        } else {
          newValue.reminderDate = p.item3;
        }
        await appClientServices!.editTodo(newValue);
        p.item1.changeItem(newValue);

        completeState = DataState.none;
      } catch (error) {
        logger.e(error);

        completeState = DataState.error;
      }
    });

    deleteTodo = Command.parameter((p) async {
      try {
        completeState = DataState.loading;

        await appClientServices!.deleteTodo(p!.id);
        item!.todos!.removeWhere((element) => element.id == p.id);
        appServices!.navigatorState!.pop();
        appServices.navigatorState!.pop();

        completeState = DataState.none;
      } catch (error) {
        logger.e(error);

        completeState = DataState.error;
      }
    });

    editNotes = Command.parameter((p) async {
      try {
        completeState = DataState.loading;

        final newItem = TodoItem.fromJson(p!.item1.toJson());
        newItem.notes = p.item2 ?? '';
        await appClientServices!.editTodo(newItem);
        p.item1.changeItem(newItem);

        completeState = DataState.none;
      } catch (error) {
        logger.e(error);

        completeState = DataState.error;
      }
    });

    editHour = Command.parameter((p) async {
      try {
        completeState = DataState.loading;

        final newItem = TodoItem.fromJson(p!.item1.toJson());
        newItem.hour = p.item2 ?? 0;
        await appClientServices!.editTodo(newItem);
        p.item1.changeItem(newItem);

        completeState = DataState.none;
      } catch (error) {
        logger.e(error);

        completeState = DataState.error;
      }
    });

    editTodo = Command.parameter((p) async {
      if (p!.todoItem.isValidReminder != true) {
        return;
      }

      try {
        editTodoState.add(DataState.loading);

        await appClientServices!.editTodo(p.newTodoItem);
        p.todoItem.changeItem(p.newTodoItem);
        if (p.popNavigation == true) {
          appServices!.navigatorState!.pop();
        }

        editTodoState.add(DataState.success);
      } catch (error) {
        logger.e(error);

        editTodoState.add(
          DataState(
            enumSelector: EnumSelector.error,
            message: getErrorMessage(error),
          ),
        );
      }
    });

    editGoalName = Command.parameter((p) async {
      try {
        editTodoState.add(DataState.loading);

        final goalName = p ?? '';

        final request = EditGoalRequest()
          ..id = item!.id
          ..name = goalName
          ..notes = item!.notes;
        await appClientServices!.editGoal(request);
        item!.name = goalName;

        titleMode = TitleMode.view;

        editTodoState.add(DataState.success);
      } catch (error) {
        logger.e(error);

        editTodoState.add(
          DataState(
            enumSelector: EnumSelector.error,
            message: getErrorMessage(error),
          ),
        );
      }
    });
  }

  @observable
  var completeState = DataState.none;

  late Command<TodoItem> completeTodo;

  @observable
  var state = DataState.none;

  late Command<GoalsStore> deleteGoal;

  late Command<Tuple2<TodoItem, DateTime?>> editDueDate;

  late Command<Tuple3<TodoItem, ReminderTypeEnum, DateTime>> editReminder;

  Command<Tuple2<TodoItem, String>>? editNotes;

  Command<Tuple2<TodoItem, int>>? editHour;

  late Command<EditTodoParams> editTodo;

  late Command<String> editGoalName;

  // ignore: close_sinks
  var editTodoState = BehaviorSubject<DataState>.seeded(DataState.success);

  late Command addTodo;

  final todoInteraction = Interaction<Object?, Object?>();

  late Command<TodoItem> deleteTodo;

  final datePickerInteraction = Interaction<DateTime, DateTime?>();

  @observable
  GoalItem? item;

  @computed
  bool get isCompleted {
    final _completedTodos = item!.todos!.where(
      (element) => element.isCompleted == true,
    );
    return item!.todos!.length > 0 &&
        _completedTodos.length == item!.todos!.length;
  }

  @computed
  int get completedTodoLength {
    final _completedTodoLength =
        item!.todos!.where((t) => t.isCompleted == true).length;
    return _completedTodoLength;
  }

  @computed
  double get percentage {
    if (item == null) {
      return 0;
    } else {
      final todoLength = item!.todos!.length;
      var _percentage = completedTodoLength.toDouble() / todoLength.toDouble();
      return _percentage.isNaN == true ? 0 : _percentage;
    }
  }

  @computed
  String get percentageText {
    final _percentageText = NumberFormat.decimalPercentPattern().format(
      percentage,
    );
    return _percentageText;
  }

  @observable
  TitleMode? titleMode = TitleMode.view;
}

enum TitleMode {
  view,
  edit,
}

class EditTodoParams {
  late TodoItem todoItem;

  late TodoItem newTodoItem;

  bool popNavigation = true;
}
