import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/components/calendar_horizontal.dart';
import 'package:fluxmobileapp/components/user_profile_button.dart';
import 'package:fluxmobileapp/screens/agendas/agendas_store.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/screens/todo_add/todo_add_screen.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/circle_checkbox.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../stores/user_profile_store.dart';
import '../../appsettings.dart';

class AgendasScreen extends StatefulWidget {
  AgendasScreen({Key? key}) : super(key: key);

  _AgendasScreenState createState() => _AgendasScreenState();
}

class _AgendasScreenState extends State<AgendasScreen>
    with
        BaseStateMixin<AgendasStore, AgendasScreen>,
        AutomaticKeepAliveClientMixin {
  final _store = AgendasStore();
  @override
  AgendasStore get store => _store;

  final appServices = sl.get<AppServices>();

  final localization = sl.get<ILocalizationService>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final tabStore = Provider.of<MainTabStore>(
        context,
        listen: false,
      );

      {
        final d = tabStore.tabIndex.listen((e) {
          if (e == 4) {
            store.date.add(store.date.value);
          }
        });
        store.registerDispose(() {
          d.cancel();
        });
      }

      {
        final d = store.alertInteraction.registerHandler((value) async {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(value!),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.back();
                      // appServices!.navigatorState!.pop();
                    },
                    child: Text('Ok'),
                  ),
                ],
              );
            },
          );
          return null;
        });
        store.registerDispose(() {
          d.dispose();
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  Widget createShimmerItem() {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userProfileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );

    return Stack(
      children: [
        AppClipPath(
          height: 200,
        ),
        Scaffold(
          backgroundColor: context.isLight ? Colors.transparent : null,
          appBar: AppBar(
            backgroundColor: context.isLight ? Colors.transparent : null,
            title: Text(
              localization!.getByKey(
                'agendas.title',
              ),
              style: TextStyle(
                color: Color(0XFF00ADEE),
              ),
              // context.isLight
              //     ? TextStyle(
              //         color: Colors.white,
              //       )
              //     : null,
            ),
            centerTitle: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded, color: Colors.red,
                  // context.isLight ? Colors.white : null,
                ),
                onPressed: () async {
                  if (store.goals.isEmpty) {
                    return;
                  }

                  final r = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (builder) {
                      return TodoAddScreen(
                        goals: store.goals,
                        selectedGoal: store.selectedGoal,
                        dueDateRequired: true,
                      );
                    },
                  ) as TodoAddModel?;
                  if (r != null) {
                    store.addTodo.executeIf(r);
                  }
                },
              ),
              UserProfileButton(),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: CalendarHorizontal(
                          onChanged: (v) {
                            store.date.add(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Task title
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 15,
                    right: 15,
                    bottom: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(
                                  localization!.getByKey(
                                    'agendas.task',
                                  ),
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize:
                                        FontSizesWidget.of(context)!.cardTitle,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Observer(
                                  builder: (BuildContext context) {
                                    return Text(
                                      '${store.completedCount}/${store.items.length} Task Completed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: context.isLight
                                            ? const Color(0xff9FADBF)
                                            : AppTheme.of(context)
                                                .sectionTitle
                                                .color,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.only(
                          //     left: 15,
                          //   ),
                          //   child: SizedBox(
                          //     height: 20,
                          //     width: 20,
                          //     child: Observer(
                          //       builder: (BuildContext context) {
                          //         return CircularProgressIndicator(
                          //           value: store.completedPercentage,
                          //           backgroundColor:
                          //               AppTheme.of(context).canvasColorLevel2,
                          //         );
                          //       },
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Observer(
                        builder: (BuildContext context) {
                          final double value = store.items.length == 0
                              ? 0.0
                              : store.completedCount / store.items.length;
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            curve: Curves.easeInOut,
                            tween: Tween<double>(
                              begin: 0.0,
                              end: value,
                            ),
                            builder: (context, value, child) =>
                                LinearProgressIndicator(
                              backgroundColor: const Color(0xffC2CFE0),
                              color: const Color(0xff14C48D),
                              value: value,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),

                // List
                Observer(
                  builder: (BuildContext context) {
                    return WidgetSelector(
                      selectedState: store.state,
                      states: {
                        [DataState.success]: Observer(
                          builder: (BuildContext context) {
                            return ListView.separated(
                              itemCount: store.items.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                final itemStore = store.items[index];

                                return InkWell(
                                  onTap: () {
                                    appServices!.navigatorState!.pushNamed(
                                      '/agendas_screen_listview_tap_detail',
                                      arguments: {
                                        'itemStore': itemStore,
                                        'store': store,
                                      },
                                    );
                                  },
                                  child: Observer(
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Observer(
                                                builder:
                                                    (BuildContext context) {
                                                  return WidgetSelector(
                                                    selectedState:
                                                        itemStore.state,
                                                    states: {
                                                      [DataState.none]:
                                                          CircleCheckbox(
                                                        onTap: () {
                                                          store.completeAgenda
                                                              .execute(
                                                            itemStore,
                                                          );
                                                        },
                                                        isChecked: itemStore
                                                            .item!.isCompleted,
                                                      ),
                                                      [DataState.loading]:
                                                          AppShimmer(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
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
                                                    CrossAxisAlignment.stretch,
                                                children: <Widget>[
                                                  // ListTile(
                                                  //   leading: Icon(
                                                  //     Icons.broken_image,
                                                  //     size: 60,
                                                  //   ),
                                                  //   title: Text(
                                                  //     itemStore.item!.name!,
                                                  //     style: TextStyle(
                                                  //       fontSize:
                                                  //           FontSizesWidget.of(
                                                  //                   context)!
                                                  //               .large,
                                                  //       fontWeight:
                                                  //           FontWeight.w300,
                                                  //       color: Colors.black,
                                                  //     ),
                                                  //   ),
                                                  //   subtitle: Text(
                                                  //     itemStore.item!.notes!,
                                                  //     style: TextStyle(
                                                  //       fontSize:
                                                  //           FontSizesWidget.of(
                                                  //                   context)!
                                                  //               .regular,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  Text(
                                                      itemStore.item!.name!,
                                                      style: TextStyle(
                                                        fontSize:
                                                            FontSizesWidget.of(
                                                                    context)!
                                                                .large,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    itemStore.item!.notes ?? '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .thin,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color:
                                                          AppTheme.of(context)
                                                              .sectionTitle
                                                              .color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return Container(
                                  height: 1,
                                  color: AppTheme.of(context).canvasColorLevel2,
                                );
                              },
                            );
                          },
                        ),
                        [DataState.loading]: ListView.separated(
                          itemCount: 5,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return AppShimmer(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 15,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Container(
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
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
                          separatorBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            return Container(
                              height: 1,
                              color: AppTheme.of(context).canvasColorLevel2,
                            );
                          },
                        ),
                        [DataState.empty]: Observer(
                          builder: (BuildContext context) {
                            return ErrorDataWidget(
                              text: localization!.getByKey(
                                'common.empty',
                              ),
                              onReload: () {
                                store.getData.executeIf();
                              },
                            );
                          },
                        ),
                        [DataState.error]: Observer(
                          builder: (BuildContext context) {
                            return ErrorDataWidget(
                              text: store.state!.message,
                              onReload: () {
                                store.getData.executeIf();
                              },
                            );
                          },
                        ),
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
