import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/goals/goals_store.dart';
import 'package:fluxmobileapp/screens/todo_add/todo_add_screen.dart';
import 'package:fluxmobileapp/screens/todo_detail/todo_detail_screen.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/app_dropdown.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/checkbox_label.dart';
import 'package:fluxmobileapp/widgets/circle_checkbox.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/text_field_controller_wrapper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../appsettings.dart';

class GoalsDetailScreen extends StatefulWidget {
  final ListGoalItemModel? item;
  final GoalsStore? goalsStore;
  final TitleMode? titleMode;

  GoalsDetailScreen({
    this.item,
    this.goalsStore,
    this.titleMode,
    Key? key,
  }) : super(key: key);

  _GoalsDetailScreen createState() => _GoalsDetailScreen();
}

class _GoalsDetailScreen extends State<GoalsDetailScreen> {
  final appServices = sl.get<AppServices>();
  final localization = sl.get<ILocalizationService>();

  ListGoalItemModel? get item => widget.item;

  List<Disposable> datePickerDisposable = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      {
        datePickerDisposable.add(item!.datePickerInteraction.registerHandler(
          (value) async {
            final r = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(5000),
            );
            return r;
          },
        ));
      }

      {
        datePickerDisposable
            .add(item!.todoInteraction.registerHandler((value) async {
          final r = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (builder) {
              return TodoAddScreen();
            },
          );
          return r;
        }));
      }
    });

    if (widget.titleMode != null) {
      item!.titleMode = widget.titleMode;
    }
  }

  @override
  void dispose() {
    datePickerDisposable.forEach(
      (element) {
        element.dispose();
      },
    );
    datePickerDisposable.clear();

    super.dispose();
  }

  Widget createDivider(BuildContext context) {
    return Container(
      height: 1,
      color: AppTheme.of(context).canvasColorLevel2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DataState>(
      stream: widget.item!.editTodoState,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox();
        }

        return WidgetSelector(
          selectedState: snapshot.data,
          states: {
            [DataState.loading]: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            [DataState.error]: Scaffold(
              body: ErrorDataWidget(
                text: snapshot.data!.message ?? '',
              ),
            ),
            [DataState.success]: Container(
              color: context.isLight ? const Color(0xffF3F8FF) : null,
              child: Stack(
                children: [
                  AppClipPath(
                    height: 210,
                  ),
                  Scaffold(
                    backgroundColor:
                        context.isLight ? Colors.transparent : null,
                    appBar: AppBar(
                      backgroundColor:
                          context.isLight ? Colors.transparent : null,
                      centerTitle: false,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: context.isLight ? Colors.white : null,
                        ),
                        onPressed: () {
                          Get.back();
                          // appServices!.navigatorState!.pop();
                        },
                      ),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: context.isLight ? Colors.white : null,
                          ),
                          onPressed: () {
                            item!.addTodo.executeIf();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: context.isLight ? Colors.white : null,
                          ),
                          onPressed: () {
                            item!.deleteGoal.executeIf(widget.goalsStore);
                          },
                        ),
                      ],
                    ),
                    body: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Observer(
                              builder: (
                                BuildContext context,
                              ) {
                                final textStyle = TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Quicksand',
                                );
                                final mode = widget.item!.titleMode;

                                if (mode == TitleMode.edit) {
                                  return TextFieldControllerWrapper(
                                    textEditingControllerBuilder: () {
                                      return TextEditingController.fromValue(
                                        TextEditingValue(
                                            text: item!.item!.name ?? ''),
                                      );
                                    },
                                    onControllerCreated: (
                                      BuildContext context,
                                      TextEditingController
                                          textEditingController,
                                    ) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          TextField(
                                            controller: textEditingController,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            textAlign: TextAlign.center,
                                            autocorrect: false,
                                            autofocus: true,
                                            style: textStyle,
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText: '',
                                              border: InputBorder.none,
                                              fillColor: Colors.transparent,
                                            ),
                                          ),
                                          Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    textEditingController.text =
                                                        '';
                                                    widget.item!.titleMode =
                                                        TitleMode.view;
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 15,
                                                    ),
                                                    child: Icon(
                                                      Icons.clear,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1!
                                                          .color,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                InkWell(
                                                  onTap: () {
                                                    widget.item!.editGoalName
                                                        .executeIf(
                                                            textEditingController
                                                                .text);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 15,
                                                    ),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1!
                                                          .color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        item!.item!.name ?? '',
                                        textAlign: TextAlign.center,
                                        style: textStyle,
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          widget.item!.titleMode =
                                              TitleMode.edit;
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 15,
                                          ),
                                          child: Image.asset(
                                            'images/ic_pencil.png',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(
                              height: 25,
                            ),
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
                                      Container(
                                        width: 100,
                                        height: 100,
                                        child: Stack(
                                          children: <Widget>[
                                            Center(
                                              child: SizedBox(
                                                height: 90,
                                                width: 90,
                                                child: TweenAnimationBuilder<
                                                    double>(
                                                  duration: const Duration(
                                                    milliseconds: 180,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                  tween: Tween<double>(
                                                    begin: 0.0,
                                                    end:
                                                        item?.percentage ?? 0.0,
                                                  ),
                                                  builder:
                                                      (context, value, child) {
                                                    return CircularProgressIndicator(
                                                      value: value,
                                                      strokeWidth: 10,
                                                      color: context.isLight
                                                          ? const Color(
                                                              0xff14C48D)
                                                          : null,
                                                      backgroundColor: context
                                                              .isLight
                                                          ? const Color(
                                                              0xffC2CFE0)
                                                          : AppTheme.of(context)
                                                              .canvasColorLevel2,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                '${item!.percentageText}',
                                                style: TextStyle(
                                                  fontSize: FontSizesWidget.of(
                                                          context)!
                                                      .large,
                                                  color: context.isDark
                                                      ? Colors.white
                                                      : null,
                                                  fontFamily: 'Quicksand',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: context.isLight
                                                ? const Color(0xff0E9DE9)
                                                : AppTheme.of(context)
                                                    .canvasColorLevel3,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 15,
                                          ),
                                          child: Text(
                                              '${item!.completedTodoLength}/${item!.item!.todos!.length} Task Completed',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: context.isLight
                                                    ? const Color(0xffF3F8FF)
                                                    : null,
                                              )),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            if (!isBlank(item!.item!.notes))
                              const SizedBox(
                                height: 15,
                              ),
                            if (!isBlank(item!.item!.notes))
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  item!.item!.notes!,
                                  style: TextStyle(
                                    fontSize:
                                        FontSizesWidget.of(context)!.regular,
                                  ),
                                  // item.item.notes ?? '',
                                ),
                              ),
                            // createDivider(context),
                            Observer(
                              builder: (BuildContext context) {
                                if (item!.item!.todos!.length == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'No Task Added Yet',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w500,
                                            fontSize:
                                                FontSizesWidget.of(context)!
                                                    .large,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        // Text(
                                        //   'Tap button below to add new task',
                                        //   textAlign: TextAlign.center,
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.w300,
                                        //     fontSize: FontSizesWidget.of(context).regular,
                                        //     color: Theme.of(context).iconTheme.color,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  );
                                }

                                return Builder(
                                  builder: (BuildContext context) {
                                    return ListView.separated(
                                      itemCount: item!.item!.todos!.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(0),
                                      itemBuilder: (context, index) {
                                        final itemTodo =
                                            item!.item!.todos![index];

                                        return Observer(
                                          builder: (BuildContext context) {
                                            return InkWell(
                                              onTap: () async {
                                                ReminderTypeEnum?
                                                    prevReminderType =
                                                    itemTodo.reminderType;
                                                await showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) {
                                                    return SafeArea(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: context.isLight
                                                              ? const Color(
                                                                  0xffF3F8FF)
                                                              : Theme.of(
                                                                      context)
                                                                  .canvasColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    30),
                                                            topRight:
                                                                Radius.circular(
                                                                    30),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 15,
                                                            vertical: 10,
                                                          ),
                                                          child: Observer(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .stretch,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons
                                                                        .drag_handle,
                                                                  ),
                                                                  Row(
                                                                    children: <
                                                                        Widget>[
                                                                      CheckboxLabel(
                                                                        onTap:
                                                                            () {
                                                                          item!
                                                                              .completeTodo
                                                                              .executeIf(itemTodo);
                                                                        },
                                                                        isChecked:
                                                                            itemTodo.isCompleted,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            15,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          itemTodo.name ??
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Quicksand',
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize:
                                                                                FontSizesWidget.of(context)!.large,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            15,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  IntrinsicHeight(
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.stretch,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                'DUE DATE',
                                                                              ),
                                                                              const SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  item!.editDueDate.executeIf(
                                                                                    Tuple2(itemTodo, null),
                                                                                  );
                                                                                },
                                                                                child: Text(
                                                                                  itemTodo.dueDate != null ? '${DateFormat('d MMMM yyyy').format(itemTodo.dueDate!)}' : '-',
                                                                                  style: TextStyle(
                                                                                    color: AppTheme.of(context).sectionTitle.color,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.stretch,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                'REMINDER',
                                                                                textAlign: TextAlign.end,
                                                                              ),
                                                                              TodoReminder(
                                                                                value: itemTodo.reminderType ?? ReminderTypeEnum.none,
                                                                                date: itemTodo.reminderDate,
                                                                                onOncePicked: (v) {
                                                                                  itemTodo.reminderType = v;
                                                                                },
                                                                                onValueChanged: (
                                                                                  v1,
                                                                                  v2,
                                                                                ) {
                                                                                  if (v1 == null || v2 == null) {
                                                                                    return;
                                                                                  }
                                                                                  item!.editReminder.execute(Tuple3(
                                                                                    itemTodo,
                                                                                    v1,
                                                                                    v2,
                                                                                  ));
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  IntrinsicHeight(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          'HOUR',
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        Observer(
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            final hour =
                                                                                itemTodo.hour;

                                                                            return AppDropdown(
                                                                              backgroundColor: context.isLight ? const Color(0xffE6F0FF) : Theme.of(context).inputDecorationTheme.fillColor,
                                                                              items: List<String>.generate(24, (f) {
                                                                                return twoDigits(f);
                                                                              }),
                                                                              value: hour != null ? twoDigits(hour) : '00:00',
                                                                              onChanged: (String? v) {
                                                                                if (v == null) {
                                                                                  return;
                                                                                }
                                                                                final _hour = int.tryParse(v.split(':')[0]);
                                                                                if (_hour != null) {
                                                                                  final newItemTodo = TodoItem.fromJson(
                                                                                    itemTodo.toJson(),
                                                                                  );
                                                                                  newItemTodo.hour = _hour;
                                                                                  item!.editTodo.executeIf(
                                                                                    EditTodoParams()
                                                                                      ..todoItem = itemTodo
                                                                                      ..newTodoItem = newItemTodo
                                                                                      ..popNavigation = false,
                                                                                  );
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  TextButton(
                                                                    child: Text(
                                                                      'More Detail',
                                                                      style: TextStyle(
                                                                          color: context.isLight
                                                                              ? Colors.white
                                                                              : null),
                                                                    ),
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                          10,
                                                                        ),
                                                                      ),
                                                                      backgroundColor: context
                                                                              .isLight
                                                                          ? const Color(
                                                                              0xff0E9DE9)
                                                                          : AppTheme.of(context)
                                                                              .canvasColorLevel3,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      appServices!
                                                                          .navigatorState!
                                                                          .push(
                                                                              MaterialPageRoute(
                                                                        builder:
                                                                            (
                                                                          BuildContext
                                                                              context,
                                                                        ) {
                                                                          return TodoDetailScreen(
                                                                            todoItem:
                                                                                itemTodo,
                                                                            state:
                                                                                item!.editTodoState,
                                                                            provider:
                                                                                TodoDetailProvider(
                                                                              onDelete: () async {
                                                                                await item!.deleteTodo.executeIf(
                                                                                  itemTodo,
                                                                                );
                                                                              },
                                                                              onMarkAsDone: () {
                                                                                item!.completeTodo.executeIf(
                                                                                  itemTodo,
                                                                                );
                                                                              },
                                                                              onSaved: (v) {
                                                                                item!.editTodo.executeIf(
                                                                                  EditTodoParams()
                                                                                    ..todoItem = itemTodo
                                                                                    ..newTodoItem = v,
                                                                                );
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                      ));
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 15,
                                                                  ),
                                                                  Observer(
                                                                    builder: (
                                                                      BuildContext
                                                                          context,
                                                                    ) {
                                                                      final state =
                                                                          item!
                                                                              .completeState;
                                                                      if (state ==
                                                                          DataState
                                                                              .error) {
                                                                        return ErrorDataWidget(
                                                                          text:
                                                                              state.message,
                                                                        );
                                                                      } else if (state !=
                                                                          DataState
                                                                              .loading) {
                                                                        return const SizedBox();
                                                                      }

                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(),
                                                                      );
                                                                    },
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );

                                                // Set back to previous reminder type if valid reminder not valid
                                                if (itemTodo.isValidReminder !=
                                                    true) {
                                                  itemTodo.reminderType =
                                                      prevReminderType;
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 15,
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Observer(
                                                        builder: (BuildContext
                                                            context) {
                                                          return WidgetSelector(
                                                            selectedState:
                                                                DataState.none,
                                                            states: {
                                                              [
                                                                DataState.none
                                                              ]: CircleCheckbox(
                                                                onTap: () {
                                                                  item!
                                                                      .completeTodo
                                                                      .executeIf(
                                                                          itemTodo);
                                                                },
                                                                isChecked: itemTodo
                                                                    .isCompleted,
                                                              ),
                                                              [
                                                                DataState
                                                                    .loading
                                                              ]: AppShimmer(
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  height: 24,
                                                                  width: 24,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                    10,
                                                                  ),
                                                                ),
                                                              ),
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: <Widget>[
                                                          Text(
                                                            itemTodo.name ?? '',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  FontSizesWidget.of(
                                                                          context)!
                                                                      .large,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                          if (itemTodo
                                                                  .dueDate !=
                                                              null)
                                                            Text(
                                                              'Due Date: ${DateFormat('d MMMM yyyy').format(itemTodo.dueDate!)}',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    FontSizesWidget.of(
                                                                            context)!
                                                                        .thin,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color: AppTheme.of(
                                                                        context)
                                                                    .sectionTitle
                                                                    .color,
                                                              ),
                                                            ),
                                                          if (itemTodo
                                                                  .dueDate ==
                                                              null)
                                                            Text(
                                                              'Set Deadline & Reminder for this task',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    FontSizesWidget.of(
                                                                            context)!
                                                                        .thin,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                color:
                                                                    const Color(
                                                                  0xffFF5064,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return createDivider(context);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          },
        );
      },
    );
  }
}

class TodoReminder extends StatefulWidget {
  final ReminderTypeEnum? value;
  final DateTime? date;
  final Color? backgroundColor;
  final void Function(ReminderTypeEnum?, DateTime?)? onValueChanged;
  final void Function(ReminderTypeEnum?)? onOncePicked;

  TodoReminder({
    this.value,
    this.onValueChanged,
    this.date,
    this.backgroundColor,
    this.onOncePicked,
    Key? key,
  }) : super(key: key);

  @override
  _TodoReminderState createState() => _TodoReminderState();
}

final _list = ReminderTypeEnum.values;

class _TodoReminderState extends State<TodoReminder> {
  final dateSubject = BehaviorSubject<DateTime?>.seeded(null);
  final reminderTypeSubject = BehaviorSubject<ReminderTypeEnum?>.seeded(null);

  @override
  void initState() {
    super.initState();

    dateSubject.add(widget.date);
    reminderTypeSubject.add(widget.value);
  }

  @override
  void didUpdateWidget(TodoReminder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.date != widget.date) {
      dateSubject.add(widget.date);
    }
    if (oldWidget.value != widget.value) {
      reminderTypeSubject.add(widget.value);
    }
  }

  @override
  void dispose() {
    dateSubject.close();
    reminderTypeSubject.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.isLight
                ? const Color(0xffE6F0FF)
                : (widget.backgroundColor ??
                    Theme.of(context).inputDecorationTheme.fillColor),
          ),
          margin: const EdgeInsets.only(
            top: 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: DropdownButtonHideUnderline(
            child: StreamBuilder<ReminderTypeEnum?>(
                initialData: reminderTypeSubject.value,
                stream: reminderTypeSubject,
                builder: (context, snapshot) {
                  return DropdownButton<ReminderTypeEnum>(
                    value: snapshot.data ?? ReminderTypeEnum.none,
                    isExpanded: true,
                    items: _list.map((f) {
                      return DropdownMenuItem<ReminderTypeEnum>(
                        value: f,
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Text(
                            getTextByReminderType(f),
                            style: TextStyle(
                              fontSize: 14,
                              color: context.isLight ? Colors.black : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != ReminderTypeEnum.once) {
                        widget.onValueChanged!(v, dateSubject.value);
                      } else {
                        widget.onOncePicked!(v);
                      }
                      reminderTypeSubject.add(v);
                    },
                  );
                }),
          ),
        ),
        // if (widget.value == ReminderTypeEnum.once)
        StreamBuilder<ReminderTypeEnum?>(
          initialData: reminderTypeSubject.value,
          stream: reminderTypeSubject,
          builder: (context, snapshot) {
            if (reminderTypeSubject.value != ReminderTypeEnum.once) {
              return const SizedBox();
            }

            return StreamBuilder<DateTime?>(
              initialData: dateSubject.value,
              stream: dateSubject,
              builder: (context, snapshot) {
                return TextButton(
                  onPressed: () async {
                    final r = await showDatePicker(
                      context: context,
                      initialDate: snapshot.data ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(5000),
                    );
                    if (r != null) {
                      widget.onValueChanged!(reminderTypeSubject.value, r);
                      dateSubject.add(r);
                    }
                  },
                  child: snapshot.data != null
                      ? Text(
                          DateFormat('d MMMM yyyy').format(
                            snapshot.data!,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Pick Date',
                              ),
                              TextSpan(
                                text: ' (Required *)',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
