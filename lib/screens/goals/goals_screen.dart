import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/components/user_profile_button.dart';
import 'package:fluxmobileapp/screens/goals/goals_store.dart';
import 'package:fluxmobileapp/screens/goals_create/goals_create_screen.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/services/cached_image_manager.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../stores/user_profile_store.dart';
import '../../appsettings.dart';

class GoalsScreen extends StatefulWidget {
  GoalsScreen({Key? key}) : super(key: key);

  _GoalsScreen createState() => _GoalsScreen();
}

class _GoalsScreen extends State<GoalsScreen>
    with
        BaseStateMixin<GoalsStore, GoalsScreen>,
        AutomaticKeepAliveClientMixin {
  final localization = sl.get<ILocalizationService>();
  final appServices = sl.get<AppServices>();

  final _store = GoalsStore();
  GoalsStore get store => _store;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final tabStore = Provider.of<MainTabStore>(
    //     context,
    //     listen: false,
    //   );

    //   {
    //     final d = tabStore.tabIndex.listen((e) {
    //       if (e == 2) {
    //         store.dataRefresher.add(null);
    //       }
    //     });
    //     store.registerDispose(() {
    //       d.cancel();
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userProfileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );

    return FutureBuilder<int>(
      future: store.tutorialWalkthroughStore!.getLastTutorialIndex
          .executeIf()
          .then(
            (e) => store.tutorialWalkthroughStore!.currentTutorialIndex.value,
          ),
      initialData: null,
      builder: (context, snapshot) {
        return Stack(
          children: [
            AppClipPath(
              height: 130,
            ),
            Scaffold(
              backgroundColor: context.isLight ? Colors.transparent : null,
              appBar: AppBar(
                backgroundColor: context.isLight ? Colors.transparent : null,
                title: Text(
                  'Task',
                  style: TextStyle(
                    color: Color(0XFF00ADEE),
                  ),
                  // context.isLight
                  //     ? TextStyle(
                  //         color: const Color(0xffF3F8FF),
                  //       )
                  //     : null,
                ),
                centerTitle: false,
                actions: <Widget>[
                  TutorialWalkthroughBasic(
                    selectedTutorialIndex: 0,
                    store: store.tutorialWalkthroughStore,
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline_outlined,
                        color: Colors.red
                        // context.isLight ? Colors.white : null,
                      ),
                      onPressed: () async {
                        final id = await Get.toNamed('/add_goals')
                            //   appServices!.navigatorState!.pushNamed(
                            // '/add_goals',
                            // )
                            as BaseResponse<String?>;
                        if (id != null) {
                          if (id.payload != null) {
                            store.lastAddedGoalId = id.payload;
                            store.dataRefresher.add(null);
                          }
                        }
                      },
                    ),
                  ),
                  UserProfileButton(),
                ],
              ),
              body: Stack(
                children: <Widget>[
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          height: 45,
                          decoration: context.isDark
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                                )
                              : null,
                          child: TabBar(
                            labelStyle: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold,
                              fontSize: FontSizesWidget.of(context)!.semiLarge,
                              letterSpacing: 1,
                            ),
                            labelColor: context.isDark
                                ? Theme.of(context).accentColor
                                : const Color(0xff0398CD),
                            unselectedLabelColor: context.isLight
                                ? const Color(0xff8597AE)
                                : null,
                            indicator: BoxDecoration(
                              color: context.isDark
                                  ? Theme.of(context).accentColor
                                  : const Color(0xffD1F3FF),
                              borderRadius: BorderRadius.circular(10),
                              border: context.isLight
                                  ? Border.all(
                                      width: 2,
                                      color: Theme.of(context).accentColor,
                                    )
                                  : null,
                            ),
                            tabs: [
                              TutorialWalkthroughBasic(
                                selectedTutorialIndex: 1,
                                store: store.tutorialWalkthroughStore,
                                child: Tab(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Active',
                                      textScaleFactor:
                                          getTabTextScaleFactor(context),
                                    ),
                                  ),
                                ),
                              ),
                              TutorialWalkthroughBasic(
                                selectedTutorialIndex: 2,
                                store: store.tutorialWalkthroughStore,
                                child: Tab(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Completed',
                                      textScaleFactor:
                                          getTabTextScaleFactor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              GoalsTabContentWidget(
                                goalsStore: store,
                                isActive: true,
                              ),
                              GoalsTabContentWidget(
                                goalsStore: store,
                                isActive: false,
                              ),
                            ],
                          ),
                        ),
                      ],
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
}

class GoalsTabContentWidget extends StatefulWidget {
  final GoalsStore goalsStore;
  final isActive;
  GoalsTabContentWidget({
    required this.goalsStore,
    required this.isActive,
    Key? key,
  }) : super(key: key);

  @override
  _GoalsTabContentWidgetState createState() => _GoalsTabContentWidgetState();
}

class _GoalsTabContentWidgetState extends State<GoalsTabContentWidget>
    with AutomaticKeepAliveClientMixin {
  GoalsStore get store => widget.goalsStore;

  final listController = ScrollController();

  final localization = sl.get<ILocalizationService>();

  @override
  void initState() {
    super.initState();

    listController.addListener(() {
      if (listController.offset == listController.position.maxScrollExtent) {
        store.loadMoreRefresher.add(null);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      store.loadMoreRefresher.add(null);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    listController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget createItemShimmer() {
      return AppShimmer(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
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
                        borderRadius: BorderRadius.circular(
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
    }

    return Container(
      child: Observer(
        builder: (BuildContext context) {
          return WidgetSelector(
            selectedState: store.state,
            states: {
              [DataState.success]: SmartRefresher(
                controller: RefreshController(),
                onRefresh: () {
                  store.dataRefresher.add(null);
                },
                child: Observer(
                  builder: (BuildContext context) {
                    final _items = widget.isActive == true
                        ? store.activeItems
                        : store.completedItems;
                    if (_items.length == 0) {
                      return Center(
                        child: ErrorDataWidget(
                          text: 'You haven\'t add anything here',
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: _items.length,
                      addAutomaticKeepAlives: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      controller: listController,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == _items.length) {
                          return Observer(
                            builder: (BuildContext context) {
                              return WidgetSelector(
                                selectedState: store.loadMoreState,
                                states: {
                                  [DataState.loading]: createItemShimmer(),
                                  [DataState.none]: Container(height: 50),
                                },
                              );
                            },
                          );
                        }

                        final item = _items[index];

                        return Observer(
                          builder: (context) => InkWell(
                            onTap: () {
                              store.goToDetail.executeIf(item);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 65,
                                    height: 65,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: SizedBox(
                                            height: 60,
                                            width: 60,
                                            child: CircularProgressIndicator(
                                              value: item.percentage,
                                              color: context.isLight
                                                  ? const Color(0xff14C48D)
                                                  : null,
                                              backgroundColor: context.isLight
                                                  ? const Color(0xffC2CFE0)
                                                  : AppTheme.of(context)
                                                      .canvasColorLevel2,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            '${item.percentageText}',
                                            style: TextStyle(
                                              fontSize:
                                                  FontSizesWidget.of(context)!
                                                      .thin,
                                              fontWeight: FontWeight.w300,
                                              color: context.isLight
                                                  ? null
                                                  : AppTheme.of(context)
                                                      .sectionTitle
                                                      .color,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                        Text(
                                          item.item!.name ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                FontSizesWidget.of(context)!
                                                    .regular,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${item.completedTodoLength}/${item.item!.todos!.length} Task Completed',
                                          style: TextStyle(
                                            fontSize:
                                                FontSizesWidget.of(context)!
                                                    .thin,
                                            fontWeight: FontWeight.w300,
                                            color: context.isLight
                                                ? const Color(0xff9FADBF)
                                                : AppTheme.of(context)
                                                    .sectionTitle
                                                    .color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 1,
                          color: AppTheme.of(context).canvasColorLevel2,
                        );
                      },
                    );
                  },
                ),
              ),
              [DataState.loading]: ListView.builder(
                itemCount: 5,
                addAutomaticKeepAlives: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return createItemShimmer();
                },
              ),
              [DataState.error]: Padding(
                padding: const EdgeInsets.all(10),
                child: ErrorDataWidget(
                  text: store.state.message ?? '',
                  onReload: () {
                    store.dataRefresher.add(null);
                  },
                ),
              ),
              [DataState.empty]: Padding(
                padding: const EdgeInsets.all(10),
                child: ErrorDataWidget(
                  text: localization!.getByKey(
                    'common.empty',
                  ),
                  onReload: () {
                    store.dataRefresher.add(null);
                  },
                ),
              ),
            },
          );
        },
      ),
    );
  }
}
