import 'package:flutter/material.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/screens/activities/activities_screen.dart';
import 'package:fluxmobileapp/screens/agendas/agendas_screen.dart';
import 'package:fluxmobileapp/screens/browse/browse_screen.dart';
import 'package:fluxmobileapp/screens/goals/goals_screen.dart';
import 'package:fluxmobileapp/screens/home/home_screen.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/screens/recent_session/recent_session_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:provider/provider.dart';

import '../../appsettings.dart';

class MainTabScreen extends StatefulWidget {
  MainTabScreen({Key? key}) : super(key: key);

  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with BaseStateMixin<MainTabStore, MainTabScreen> {
  int pageIndex = 0;
  final pageController = PageController();
  final localization = sl.get<ILocalizationService>();

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      final page = pageController.page!.toInt();
      store.tabIndex.add(page);
    });
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  Widget createSelectedTabIndicator() {
    return Container(
      height: 5,
      width: 10,
      color: Theme.of(context).accentColor,
    );
  }

  final _store = MainTabStore();
  @override
  MainTabStore get store => _store;

  Widget createTab(
    String imageAsset,
    String text,
    bool isSelected,
  ) {
    return Stack(
      children: <Widget>[
        if (isSelected)
          Container(
            height: 2,
            color: Theme.of(context).accentColor,
          ),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                imageAsset,
                height: 32,
                color: isSelected
                    ? Theme.of(context).accentColor
                    : Theme.of(context).textTheme.caption!.color,
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).accentColor
                      : Theme.of(context).textTheme.caption!.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PageControllerInheritedWidget(
      pageController: pageController,
      child: Provider.value(
        value: store,
        child: MultiProvider(
          providers: [
            Provider<OnGoingRecentSessionStore>(
              create: (c) => OnGoingRecentSessionStore(),
              dispose: (_, store) => store.dispose(),
            ),
            Provider<CompletedRecentSessionStore>(
              create: (c) => CompletedRecentSessionStore(
                onGoingMode: false,
              ),
              dispose: (_, store) => store.dispose(),
            ),
          ],
          child: Scaffold(
            body: PageView.builder(
              itemCount: 4,
              pageSnapping: false,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return HomeScreen();
                } 
                // else if (index == 1) {
                //   return ActivitiesScreen();
                // } 
                else if (index == 1) {
                  return BrowseScreen();
                } else if (index == 2) {
                  return GoalsScreen();
                } else if (index == 3) {
                  return AgendasScreen();
                }

                return HomeScreen();
              },
            ),
            bottomNavigationBar: StreamBuilder<int>(
              initialData: 0,
              stream: store.tabIndex,
              builder: (context, data) {
                final selectedIndex = data.data!;

                return Container(
                  height: kBottomNavigationBarHeight + bottomPadding,
                  color: Theme.of(context).appBarTheme.color,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: DefaultTabController(
                      initialIndex: selectedIndex,
                      length: 5,
                      child: Container(
                        height: kBottomNavigationBarHeight,
                        child: TabBar(
                          labelPadding: const EdgeInsets.all(0),
                          indicatorWeight: 0,
                          indicator: const BoxDecoration(),
                          labelColor: Theme.of(context).accentColor,
                          labelStyle: TextStyle(
                            fontSize: FontSizesWidget.of(context)!.veryThin,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                          ),
                          unselectedLabelColor:
                              Theme.of(context).textTheme.caption!.color,
                          unselectedLabelStyle: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                          ),
                          onTap: (v) {
                            pageController.jumpToPage(v);
                          },
                          tabs: [
                            createTab(
                              'images/ic_home.png',
                              localization!.getByKey(
                                'main_tab.home.title',
                              ),
                              selectedIndex == 0,
                            ),
                            // createTab(
                            //   'images/ic_course.png',
                            //   localization!.getByKey(
                            //     'main_tab.activities.title',
                            //   ),
                            //   selectedIndex == 1,
                            // ),
                            createTab(
                              'images/ic_browse.png',
                              localization!.getByKey(
                                'main_tab.browse.title',
                              ),
                              selectedIndex == 1,
                            ),
                            createTab(
                              'images/ic_goals.png',
                              localization!.getByKey(
                                'main_tab.goals.title',
                              ),
                              selectedIndex == 2,
                            ),
                            createTab(
                              'images/ic_setting.png',
                              localization!.getByKey(
                                'main_tab.agendas.title',
                              ),
                              selectedIndex == 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PageControllerInheritedWidget extends InheritedWidget {
  final PageController? pageController;
  final Widget child;

  PageControllerInheritedWidget({
    Key? key,
    required this.child,
    this.pageController,
  }) : super(key: key, child: child);

  static PageControllerInheritedWidget? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PageControllerInheritedWidget>();
  }

  @override
  bool updateShouldNotify(PageControllerInheritedWidget oldWidget) {
    return true;
  }
}
