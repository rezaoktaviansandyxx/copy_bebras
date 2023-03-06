import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/stores/detail_accept_goals_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/checkbox_solid_widget.dart';
import 'package:mobx/mobx.dart';

class DetailTodoListScreen extends HookWidget {
  final ObservableList<TileItem<String>> todos;
  final String? goalName;

  const DetailTodoListScreen({
    Key? key,
    required this.todos,
    required this.goalName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final acceptGoalsStore = useMemoized(() => DetailAcceptGoalsStore());
    useEffect(
      () {
        Disposable? d;
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          d = acceptGoalsStore.alertInteraction.registerHandler((f) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                    f ?? '',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            return Future.value(null);
          });
        });
        return () {
          d?.dispose();
        };
      },
      const [],
    );

    return Observer(
      builder: (BuildContext context) {
        if (todos.isEmpty) {
          return const SizedBox();
        }

        return WidgetSelector(
          selectedState: acceptGoalsStore.state,
          states: {
            [DataState.none]: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: context.isLight
                          ? const Color(0xffF3F8FF)
                          : AppTheme.of(context).canvasColorLevel3,
                    ),
                    margin: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Observer(
                          builder: (BuildContext context) {
                            return ListView.builder(
                              itemCount: todos.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                top: 10,
                              ),
                              itemBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                final item = todos[index];

                                return Observer(
                                  builder: (BuildContext context) {
                                    return InkWell(
                                      onTap: () {
                                        item.isSelected = !item.isSelected;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            CheckboxSolidWidget(
                                              isChecked: item.isSelected,
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 5,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    Text(
                                                      item.value ?? '',
                                                      style: TextStyle(
                                                        fontFamily: 'Rubik',
                                                        fontSize:
                                                            FontSizesWidget.of(
                                                                    context)!
                                                                .large,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(
                          height: 38,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          final request = AcceptGoalRequest()
                            ..goalName = goalName
                            ..todos = todos
                                    ?.where(
                                      (t) => t.isSelected == true,
                                    )
                                    ?.map((f) => f.value)
                                    ?.toList() ??
                                [];
                          acceptGoalsStore.acceptGoals.executeIf(request);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.of(context).okButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                        child: Text(
                          'Accept Goals',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizesWidget.of(context)!.large,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            [DataState.loading]: Center(
              child: CircularProgressIndicator(),
            ),
          },
        );
      },
    );
  }
}
