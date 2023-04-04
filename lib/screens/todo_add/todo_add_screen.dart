import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/screens/goals_detail/goals_detail_screen.dart';
import 'package:fluxmobileapp/screens/todo_add/todo_add_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/app_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../appsettings.dart';

class TodoAddScreen extends StatefulWidget {
  final GoalItem? selectedGoal;
  final List<GoalItem>? goals;
  final bool dueDateRequired;
  TodoAddScreen({
    Key? key,
    this.selectedGoal,
    this.goals,
    this.dueDateRequired = false,
  }) : super(key: key);

  @override
  _TodoAddScreenState createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen>
    with BaseStateMixin<TodoAddStore, TodoAddScreen> {
  final _store = TodoAddStore();
  @override
  TodoAddStore get store => _store;

  final appServices = sl.get<AppServices>();

  @override
  void initState() {
    super.initState();

    store.todoAddModel.selectedGoal = widget.selectedGoal;
    store.dueDateRequired = widget.dueDateRequired;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: context.isLight
              ? const Color(0xffF3F8FF)
              : Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        margin: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: SingleChildScrollView(
            child: Observer(
              builder: (BuildContext context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.drag_handle,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Add New Task',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                        fontSize: FontSizesWidget.of(context)!.large,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
          
                    // Goals
                    if (widget.goals != null)
                      Text(
                        'Goals',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    if (widget.goals != null) const SizedBox(height: 2),
                    if (widget.goals != null)
                      DropdownButtonHideUnderline(
                        child: Observer(
                          builder: (BuildContext context) {
                            if (store.todoAddModel == null ||
                                store.todoAddModel.selectedGoal == null ||
                                widget.goals == null) {
                              return const SizedBox();
                            }
                            return DropdownButton<GoalItem>(
                              value: store.todoAddModel.selectedGoal,
                              isExpanded: true,
                              isDense: false,
                              items: widget.goals?.map((e) {
                                    return DropdownMenuItem<GoalItem>(
                                      value: e,
                                      child: Text(
                                        e.name ?? '',
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          color: context.isLight
                                              ? Colors.black
                                              : null,
                                        ),
                                      ),
                                    );
                                  })?.toList() ??
                                  [],
                              onChanged: (v) {
                                store.todoAddModel.selectedGoal = v;
                              },
                            );
                          },
                        ),
                      ),
                    if (widget.goals != null) const SizedBox(height: 10),
          
                    // Task name
                    Text(
                      'Task Name',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (BuildContext context) {
                        final initial = store.todoAddModel.taskName ?? '';
                        return TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            fillColor:
                                context.isLight ? const Color(0xffE6F0FF) : null,
                          ),
                          style: context.isLight
                              ? TextStyle(
                                  color: Colors.black,
                                )
                              : null,
                          initialValue: initial,
                          textInputAction: TextInputAction.done,
                          autofocus: false,
                          onFieldSubmitted: (v) {
                            FocusScope.of(context).unfocus();
                          },
                          onChanged: (v) {
                            store.todoAddModel.taskName = v?.trim() ?? '';
                          },
                        );
                      },
                    ),
          
                    const SizedBox(
                      height: 15,
                    ),
                    // Due date
                    Text(
                      'Due Date',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final r = await showDatePicker(
                          context: context,
                          initialDate:
                              store.todoAddModel?.dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(5000),
                        );
                        if (r != null) {
                          store.todoAddModel.dueDate = r;
                        }
                      },
                      child: IgnorePointer(
                        child: Observer(
                          builder: (BuildContext context) {
                            final dateText = store.todoAddModel.dueDate != null
                                ? DateFormat('d MMMM yyyy').format(
                                    store.todoAddModel.dueDate!,
                                  )
                                : '';
                            return TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: Icon(
                                  FontAwesomeIcons.calendarAlt,
                                ),
                                fillColor: context.isLight
                                    ? const Color(0xffE6F0FF)
                                    : null,
                              ),
                              style: context.isLight
                                  ? TextStyle(
                                      color: Colors.black,
                                    )
                                  : null,
                              controller: TextEditingController(
                                text: dateText,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
          
                    const SizedBox(
                      height: 15,
                    ),
          
                    // Reminder
                    Text(
                      'Set Reminder',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    Observer(
                      builder: (BuildContext context) {
                        return TodoReminder(
                          date: store.todoAddModel.reminderDate,
                          value: store.todoAddModel.reminderType ??
                              ReminderTypeEnum.none,
                          onOncePicked: (v) {
                            store.todoAddModel.reminderType =
                                v ?? ReminderTypeEnum.none;
                          },
                          onValueChanged: (v1, v2) {
                            store.todoAddModel.reminderType =
                                v1 ?? ReminderTypeEnum.none;
                            store.todoAddModel.reminderDate =
                                v2 ?? DateTime.now();
                          },
                        );
                      },
                    ),
          
                    // Hour
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Hour',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Observer(
                          builder: (BuildContext context) {
                            final initial = store.todoAddModel.hour;
          
                            return AppDropdown(
                              items: List<String>.generate(24, (f) {
                                return twoDigits(f);
                              }),
                              value:
                                  initial != null ? twoDigits(initial) : '00:00',
                              onChanged: (String? v) {
                                final _hour =
                                    int.tryParse(v?.split(':')[0] ?? '');
                                if (_hour != null) {
                                  store.todoAddModel.hour = _hour;
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
          
                    const SizedBox(
                      height: 20,
                    ),
          
                    IntrinsicHeight(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.back();
                                // appServices!.navigatorState!.pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: Theme.of(context).iconTheme.color,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizesWidget.of(context)!.regular,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                store.apply.executeIf();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                backgroundColor: context.isLight
                                    ? const Color(0xff0E9DE9)
                                    : const Color(0xff5AD57F),
                              ),
                              child: Text(
                                'Terapkan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizesWidget.of(context)!.regular,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
