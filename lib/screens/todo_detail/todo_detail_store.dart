import 'package:flutter/material.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';

part 'todo_detail_store.g.dart';

class TodoDetailStore = _TodoDetailStore with _$TodoDetailStore;

abstract class _TodoDetailStore with Store {
  _TodoDetailStore(
    BuildContext context, {
    AppClientServices? appClient,
  }) {
    appClient = appClient ?? sl.get<AppClientServices>();

    onMarkAsDone = Command.parameter((p) async {
      try {
        final newItem = TodoItem.fromJson(p!.toJson());
        newItem.isCompleted = !newItem.isCompleted!;
        await appClient!.editTodo(newItem);
        todoItem = newItem;
      } catch (error) {
        final m = getErrorMessage(error);
        showMessage(
          context: context,
          text: m,
        );
      }
    });

    onDelete = Command.parameter((p) async {
      try {
        await appClient!.deleteTodo(p!.id);
        Navigator.of(context).pop();
      } catch (error) {
        final m = getErrorMessage(error);
        showMessage(
          context: context,
          text: m,
        );
      }
    });

    editTodo = Command.parameter((p) async {
      try {
        editTodoState.add(DataState.loading);

        await appClient!.editTodo(p!);
        Navigator.of(context).pop();

        editTodoState.add(DataState.success);
      } catch (error) {
        editTodoState.add(
          DataState(
            enumSelector: EnumSelector.error,
            message: getErrorMessage(error),
          ),
        );
      }
    });

    // editDueDate = Command.parameter((p) async {
    //   try {
    //     var newValue = TodoItem.fromJson(p.item1.toJson());
    //     newValue.dueDate = p.item2;
    //     await appClient.editTodo(newValue);
    //     todoItem = newValue;
    //   } catch (error) {
    //     logger.e(error);
    //     showMessage(context: context, text: getErrorMessage(error));
    //   }
    // });

    // editReminder = Command.parameter((p) async {
    //   try {
    //     var newValue = TodoItem.fromJson(p.item1.toJson());
    //     newValue.reminderType = p.item2;
    //     if (p.item2 != ReminderTypeEnum.once) {
    //       newValue.reminderDate = null;
    //     } else {
    //       newValue.reminderDate = p.item3;
    //     }
    //     await appClient.editTodo(newValue);
    //     todoItem = newValue;
    //   } catch (error) {
    //     logger.e(error);
    //     showMessage(context: context, text: getErrorMessage(error));
    //   }
    // });

    // editNotes = Command.parameter((p) async {
    //   try {
    //     final newItem = TodoItem.fromJson(p.item1.toJson());
    //     newItem.notes = p.item2 ?? '';
    //     await appClient.editTodo(newItem);
    //     todoItem = newItem;
    //   } catch (error) {
    //     logger.e(error);
    //     showMessage(context: context, text: getErrorMessage(error));
    //   }
    // });

    // editHour = Command.parameter((p) async {
    //   try {
    //     final newItem = TodoItem.fromJson(p.item1.toJson());
    //     newItem.hour = p.item2 ?? 0;
    //     await appClient.editTodo(newItem);
    //     todoItem = newItem;
    //   } catch (error) {
    //     logger.e(error);
    //     showMessage(context: context, text: getErrorMessage(error));
    //   }
    // });
  }

  showMessage({
    required BuildContext context,
    String? text,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text!),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @observable
  TodoItem? todoItem;

  late Command<TodoItem> onMarkAsDone;
  late Command<TodoItem> onDelete;
  late Command<TodoItem> editTodo;

  //ignore: close_sinks
  var editTodoState = BehaviorSubject<DataState>.seeded(DataState.success);
  // Command<Tuple2<TodoItem, DateTime>> editDueDate;
  // Command<Tuple3<TodoItem, ReminderTypeEnum, DateTime>> editReminder;
  // Command<Tuple2<TodoItem, String>> editNotes;
  // Command<Tuple2<TodoItem, int>> editHour;
  // final void Function(DateTime) onDueDateChanged;
  // final void Function(DateTime) onReminderDateChanged;
  // final void Function(ReminderTypeEnum) onReminderTypeChanged;
  // final void Function(String) onNotesChanged;
  // final void Function(int) onHourChanged;
}
