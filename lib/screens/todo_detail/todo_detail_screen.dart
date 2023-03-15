import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/goals_detail/goals_detail_screen.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/app_dropdown.dart';
import 'package:fluxmobileapp/widgets/checkbox_label.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../appsettings.dart';

class TodoDetailProvider {
  final void Function()? onDelete;
  final void Function()? onMarkAsDone;
  final void Function(TodoItem)? onSaved;

  TodoDetailProvider({
    this.onDelete,
    this.onMarkAsDone,
    this.onSaved,
  });
}

class TodoDetailScreen extends StatefulWidget {
  final TodoItem? todoItem;
  final Stream<DataState>? state;
  final TodoDetailProvider? provider;

  TodoDetailScreen({
    this.state,
    this.todoItem,
    this.provider,
    Key? key,
  }) : super(key: key);

  _TodoDetailScreen createState() => _TodoDetailScreen();
}

class _TodoDetailScreen extends State<TodoDetailScreen> {
  final appServices = sl.get<AppServices>();
  final localization = sl.get<ILocalizationService>();

  // TodoItem get getTodoItem => widget.todoItem;

  final copiedTodoItem = BehaviorSubject<TodoItem?>.seeded(null);

  Widget createDivider(BuildContext context) {
    return Container(
      height: 1,
      color: context.isLight
          ? Colors.grey[300]
          : AppTheme.of(context).canvasColorLevel2,
    );
  }

  Widget createSectionContent(
    String title,
    String content, {
    bool editable = true,
    Function? onEditTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title ?? '',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content ?? '',
                    style: TextStyle(
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ],
              ),
            ),
            if (editable == true)
              InkWell(
                onTap: () {
                  onEditTap!();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  child: Image.asset(
                    'images/ic_pencil.png',
                    color: context.isLight ? Colors.black : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    copiedTodoItem.add(TodoItem.fromJson(
      widget.todoItem!.toJson(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.isLight ? const Color(0xffF3F8FF) : null,
      child: Stack(
        children: [
          // AppClipPath(),
          Scaffold(
            backgroundColor: context.isLight ? Colors.transparent : null,
            appBar: AppBar(
              backgroundColor: context.isLight ? Colors.transparent : null,
              centerTitle: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  // color: context.isLight ? Colors.white : null,
                ),
                onPressed: () {
                  Get.back();
                  // appServices!.navigatorState!.pop();
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.save,
                    // color: context.isLight ? Colors.white : null,
                  ),
                  onPressed: () {
                    final newValue = TodoItem.fromJson(
                      copiedTodoItem.value!.toJson(),
                    );
                    widget.provider!.onSaved!(newValue);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    // color: context.isLight ? Colors.white : null,
                  ),
                  onPressed: () {
                    if (widget.provider!.onDelete != null) {
                      widget.provider!.onDelete!();
                    }
                  },
                ),
              ],
            ),
            body: StreamBuilder<TodoItem?>(
                initialData: null,
                stream: copiedTodoItem,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox();
                  }

                  final getTodoItem = snapshot.data;

                  return StreamBuilder<DataState>(
                      initialData: DataState.success,
                      stream: widget.state,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return const SizedBox();
                        }

                        return WidgetSelector(
                          maintainState: true,
                          selectedState: snapshot.data,
                          states: {
                            [DataState.success]: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: Observer(
                                      builder: (BuildContext context) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 15,
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  CheckboxLabel(
                                                    onTap: () {
                                                      if (widget.provider!
                                                              .onMarkAsDone !=
                                                          null) {
                                                        widget.provider!
                                                            .onMarkAsDone!();
                                                      }
                                                    },
                                                    isChecked: widget.todoItem!
                                                            .isCompleted ??
                                                        false,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      getTodoItem!.name ?? '',
                                                      style: TextStyle(
                                                        fontFamily: 'Quicksand',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize:
                                                            FontSizesWidget.of(
                                                                    context)!
                                                                .large,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      final r =
                                                          await showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          final textController =
                                                              TextEditingController
                                                                  .fromValue(
                                                                      TextEditingValue(
                                                            text: getTodoItem
                                                                    .name ??
                                                                '',
                                                          ));
                                                          return AlertDialog(
                                                            title: Text(
                                                              'Edit',
                                                            ),
                                                            content:
                                                                TextFormField(
                                                              controller:
                                                                  textController,
                                                              decoration:
                                                                  InputDecoration(
                                                                fillColor: Colors
                                                                    .transparent,
                                                              ),
                                                              style: TextStyle(
                                                                color: context
                                                                        .isLight
                                                                    ? Colors
                                                                        .black
                                                                    : null,
                                                              ),
                                                            ),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () {
                                                                  Get.back(
                                                                      result: textController
                                                                          .text);
                                                                  // appServices!
                                                                  //     .navigatorState!
                                                                  //     .pop(
                                                                  //   textController
                                                                  //       .text,
                                                                  // );
                                                                },
                                                                child:
                                                                    Text('Ok'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      if (r != null) {
                                                        copiedTodoItem
                                                            .value!.name = r;
                                                        copiedTodoItem.add(
                                                            copiedTodoItem
                                                                .value);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 15,
                                                      ),
                                                      child: Image.asset(
                                                        'images/ic_pencil.png',
                                                        color: context.isLight
                                                            ? Colors.black
                                                            : null,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  // const SizedBox(height: 10),

                                  // Goals
                                  Observer(
                                    builder: (BuildContext context) {
                                      if (getTodoItem!.goalName == null) {
                                        return const SizedBox();
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          createSectionContent(
                                            'GOALS',
                                            getTodoItem!.goalName ?? '',
                                            editable: false,
                                          ),
                                          const SizedBox(height: 15),
                                        ],
                                      );
                                    },
                                  ),
                                  createDivider(context),
                                  const SizedBox(height: 15),

                                  // Due Date
                                  Observer(
                                    builder: (BuildContext context) {
                                      return createSectionContent(
                                        'DUE DATE',
                                        getTodoItem!.dueDate != null
                                            ? DateFormat('d MMMM yyyy')
                                                .format(getTodoItem.dueDate!)
                                            : '-',
                                        editable: true,
                                        onEditTap: () async {
                                          final r = await showDatePicker(
                                            context: context,
                                            initialDate: getTodoItem.dueDate ??
                                                DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(5000),
                                          );
                                          if (r != null) {
                                            copiedTodoItem.value!.dueDate = r;
                                            copiedTodoItem
                                                .add(copiedTodoItem.value);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  createDivider(context),
                                  const SizedBox(height: 15),

                                  // Set Reminder
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Text(
                                      'REMINDER',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Observer(
                                      builder: (BuildContext context) {
                                        return TodoReminder(
                                          backgroundColor: Colors.transparent,
                                          date: getTodoItem!.reminderDate,
                                          value: getTodoItem.reminderType,
                                          onOncePicked: (v) {
                                            copiedTodoItem.value!.reminderType =
                                                v;
                                          },
                                          onValueChanged: (
                                            v1,
                                            v2,
                                          ) {
                                            copiedTodoItem.value!.reminderType =
                                                v1;
                                            copiedTodoItem.value!.reminderDate =
                                                v2;
                                            copiedTodoItem
                                                .add(copiedTodoItem.value);
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 15),
                                  createDivider(context),
                                  const SizedBox(height: 15),

                                  // Hour
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Text(
                                      'HOUR',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Observer(
                                      builder: (BuildContext context) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Observer(
                                              builder: (BuildContext context) {
                                                final hour = getTodoItem!.hour;

                                                return AppDropdown(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  items: List<String>.generate(
                                                      24, (f) {
                                                    return twoDigits(f);
                                                  }),
                                                  value: hour != null
                                                      ? twoDigits(hour)
                                                      : '00:00',
                                                  onChanged: (String? v) {
                                                    final _hour = int.tryParse(
                                                        v?.split(':')[0] ?? '');
                                                    if (_hour != null) {
                                                      copiedTodoItem
                                                          .value!.hour = _hour;
                                                      copiedTodoItem.add(
                                                          copiedTodoItem.value);
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 15),
                                  createDivider(context),
                                  const SizedBox(height: 15),

                                  // Notes
                                  Observer(
                                    builder: (BuildContext context) {
                                      return createSectionContent(
                                        'NOTES',
                                        getTodoItem!.notes ?? '',
                                        editable: true,
                                        onEditTap: () async {
                                          final r = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              final textController =
                                                  TextEditingController
                                                      .fromValue(
                                                          TextEditingValue(
                                                text: getTodoItem.notes ?? '',
                                              ));
                                              return AlertDialog(
                                                title: Text(
                                                  'Enter notes',
                                                ),
                                                content: TextFormField(
                                                  controller: textController,
                                                  decoration: InputDecoration(
                                                    fillColor:
                                                        Colors.transparent,
                                                  ),
                                                  style: TextStyle(
                                                    color: context.isLight
                                                        ? Colors.black
                                                        : null,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back(
                                                          result: textController
                                                              .text);
                                                      // appServices!
                                                      //     .navigatorState!
                                                      //     .pop(
                                                      //   textController.text,
                                                      // );
                                                    },
                                                    child: Text('Ok'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (r != null) {
                                            copiedTodoItem.value!.notes = r;
                                            copiedTodoItem
                                                .add(copiedTodoItem.value);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  createDivider(context),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                            [DataState.loading]: Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            [DataState.error]: Container(
                              child: ErrorDataWidget(
                                text: snapshot.data?.message ?? '',
                              ),
                            ),
                          },
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
