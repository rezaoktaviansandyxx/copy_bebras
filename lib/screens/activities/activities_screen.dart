import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/components/user_profile_button.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/screens/recent_session/recent_session_store.dart';
import 'package:fluxmobileapp/services/cached_image_manager.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../stores/user_profile_store.dart';
import '../../appsettings.dart';

class ActivitiesScreen extends StatefulWidget {
  ActivitiesScreen({Key? key}) : super(key: key);

  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<ActivitiesScreen>
    with AutomaticKeepAliveClientMixin {
  final localization = sl.get<ILocalizationService>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onGoingStore = Provider.of<OnGoingRecentSessionStore>(
        context,
        listen: false,
      );

      final completedStore = Provider.of<CompletedRecentSessionStore>(
        context,
        listen: false,
      );

      {
        final tabStore = Provider.of<MainTabStore>(
          context,
          listen: false,
        );

        final d = tabStore.tabIndex.listen((e) {
          if (e == 1) {
            onGoingStore.dataRefresher.add(null);
            completedStore.dataRefresher.add(null);
          }
        });
        tabStore.registerDispose(() {
          d.cancel();
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

    final onGoingStore = Provider.of<OnGoingRecentSessionStore>(
      context,
      listen: false,
    );
    final completedStore = Provider.of<CompletedRecentSessionStore>(
      context,
      listen: false,
    );

    return Stack(
      children: [
        AppClipPath(
          height: 125,
        ),
        Scaffold(
          backgroundColor: context.isLight ? Colors.transparent : null,
          appBar: AppBar(
            title: Text(
              localization!.getByKey(
                'activities.title',
              ),
              style: context.isLight
                  ? TextStyle(
                      color: const Color(0xffF3F8FF),
                    )
                  : null,
            ),
            backgroundColor: context.isLight ? Colors.transparent : null,
            centerTitle: false,
            actions: <Widget>[
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
                        unselectedLabelColor:
                            context.isLight ? const Color(0xff8597AE) : null,
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
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                localization!.getByKey(
                                  'activities.tab.ongoing',
                                ),
                                textScaleFactor: getTabTextScaleFactor(context),
                              ),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                localization!.getByKey(
                                  'activities.tab.completed',
                                ),
                                textScaleFactor: getTabTextScaleFactor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        ActivityTabOnGoingWidget(
                          onGoingRecentSessionStore: onGoingStore,
                        ),
                        ActivityTabOnGoingWidget(
                          completedRecentSessionStore: completedStore,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActivityTabOnGoingWidget extends StatefulWidget {
  final OnGoingRecentSessionStore? onGoingRecentSessionStore;
  final CompletedRecentSessionStore? completedRecentSessionStore;

  ActivityTabOnGoingWidget({
    Key? key,
    this.onGoingRecentSessionStore,
    this.completedRecentSessionStore,
  }) : super(key: key);

  @override
  _ActivityTabOnGoingWidgetState createState() =>
      _ActivityTabOnGoingWidgetState();
}

class _ActivityTabOnGoingWidgetState extends State<ActivityTabOnGoingWidget>
    with AutomaticKeepAliveClientMixin {
  OnGoingRecentSessionStore? get ongoing => widget.onGoingRecentSessionStore;

  RecentSessionStore? get store => widget.onGoingRecentSessionStore != null
      ? widget.onGoingRecentSessionStore
      : widget.completedRecentSessionStore;

  final listController = ScrollController();

  @override
  void initState() {
    super.initState();

    listController.addListener(() {
      if (listController.offset == listController.position.maxScrollExtent) {
        store!.loadMoreRefresher.add(null);
      }
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
    final imageWidth = MediaQuery.of(context).size.width * 0.4;

    super.build(context);

    Widget createItemShimmer() {
      return AppShimmer(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                bottom: 0,
                top: 0,
                left: 0,
                width: 120,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 120,
                ),
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: 10,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: 80,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: 8,
                            ),
                          ],
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
            selectedState: store!.state,
            states: {
              [DataState.success]: SmartRefresher(
                controller: RefreshController(),
                onRefresh: () {
                  store!.dataRefresher.add(null);
                },
                child: ListView.builder(
                  itemCount: store!.items.length + 1,
                  addAutomaticKeepAlives: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  controller: listController,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == store!.items.length) {
                      return Observer(
                        builder: (BuildContext context) {
                          return WidgetSelector(
                            selectedState: store!.loadMoreState,
                            states: {
                              [DataState.loading]: createItemShimmer(),
                              [DataState.none]: Container(height: 50),
                            },
                          );
                        },
                      );
                    }

                    final item = store!.items[index];

                    return InkWell(
                      onTap: () {
                        store!.goToDetail.executeIf(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              bottom: 0,
                              top: 0,
                              left: 0,
                              width: imageWidth,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: item.imageThumbnail ?? '',
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                        placeholder: (c, url) {
                                          return Align(
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorWidget: (context, v, vv) =>
                                            const SizedBox(),
                                      ),
                                    ),
                                  ),
                                  // Positioned(
                                  //   top: 8,
                                  //   left: 8,
                                  //   child: Container(
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(15),
                                  //       color: Theme.of(context).accentColor,
                                  //     ),
                                  //     padding: const EdgeInsets.symmetric(
                                  //       horizontal: 10,
                                  //       vertical: 5,
                                  //     ),
                                  //     child: Text(
                                  //       item.type,
                                  //       style: TextStyle(
                                  //         fontSize: FontSizesWidget.of(context)
                                  //             .veryThin,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 135,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: imageWidth,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  height: 8,
                                                  width: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  item.type!,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              item.title!,
                                              style: TextStyle(
                                                fontSize:
                                                    FontSizesWidget.of(context)!
                                                        .large,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            // // Progress
                                            // Column(
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.stretch,
                                            //   mainAxisSize: MainAxisSize.min,
                                            //   children: <Widget>[
                                            //     Text(
                                            //       'lesson',
                                            //       style: TextStyle(
                                            //         fontSize:
                                            //             FontSizesWidget.of(context)
                                            //                 .thin,
                                            //         fontWeight: FontWeight.w300,
                                            //       ),
                                            //     ),
                                            //     const SizedBox(
                                            //       height: 5,
                                            //     ),
                                            //     ClipRRect(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //         5,
                                            //       ),
                                            //       child: LinearProgressIndicator(
                                            //         value: 0.5,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
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
                  text: store!.state.message ?? '',
                  onReload: () {
                    store!.dataRefresher.add(null);
                  },
                ),
              ),
              [DataState.empty]: Padding(
                padding: const EdgeInsets.all(10),
                child: ErrorDataWidget(
                  text: 'No recent session',
                  onReload: () {
                    store!.dataRefresher.add(null);
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

// class ActivityTabCompletedWidget extends StatefulWidget {
//   final ActivitiesCompletedStore store;

//   ActivityTabCompletedWidget({
//     this.store,
//     Key key,
//   }) : super(key: key);

//   @override
//   _ActivityTabCompletedWidget createState() => _ActivityTabCompletedWidget();
// }

// class _ActivityTabCompletedWidget extends State<ActivityTabCompletedWidget>
//     with AutomaticKeepAliveClientMixin {
//   ActivitiesCompletedStore get store => widget.store;

//   final listController = ScrollController();

//   @override
//   void initState() {
//     super.initState();

//     listController.addListener(() {
//       if (listController.offset == listController.position.maxScrollExtent) {
//         store.loadMoreRefresher.add(null);
//       }
//     });
//   }

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void dispose() {
//     listController.dispose();

//     super.dispose();
//   }

//   Widget createItemShimmer() {
//     return AppShimmer(
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           vertical: 10,
//         ),
//         child: Stack(
//           children: <Widget>[
//             Positioned(
//               bottom: 0,
//               top: 0,
//               left: 0,
//               width: 120,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 120,
//               ),
//               child: Row(
//                 children: <Widget>[
//                   const SizedBox(
//                     width: 15,
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 5,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: <Widget>[
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Colors.white,
//                             ),
//                             height: 10,
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Colors.white,
//                             ),
//                             height: 80,
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               color: Colors.white,
//                             ),
//                             height: 8,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageWidth = MediaQuery.of(context).size.width * 0.4;

//     super.build(context);

//     return Container(
//       child: Observer(
//         builder: (BuildContext context) {
//           return WidgetSelector(
//             selectedState: store.state,
//             states: {
//               [DataState.success]: ListView.builder(
//                 itemCount: store.items.length + 1,
//                 addAutomaticKeepAlives: true,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 5,
//                 ),
//                 controller: listController,
//                 itemBuilder: (BuildContext context, int index) {
//                   if (index == store.items.length) {
//                     if (index == store.items.length) {
//                       return Observer(
//                         builder: (BuildContext context) {
//                           return WidgetSelector(
//                             selectedState: store.loadMoreState,
//                             states: {
//                               [DataState.loading]: createItemShimmer(),
//                               [DataState.none]: Container(height: 50),
//                             },
//                           );
//                         },
//                       );
//                     }
//                   }

//                   final item = store.items[index];

//                   return GestureDetector(
//                     onTap: () {},
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 10,
//                       ),
//                       child: Stack(
//                         children: <Widget>[
//                           Positioned(
//                             bottom: 0,
//                             top: 0,
//                             left: 0,
//                             width: imageWidth,
//                             child: Stack(
//                               children: <Widget>[
//                                 Positioned.fill(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: CachedNetworkImage(
//                                       imageUrl: item.image,
//                                       fit: BoxFit.cover,
//                                       alignment: Alignment.center,
//                                       placeholder: (c, url) {
//                                         return Align(
//                                           alignment: Alignment.center,
//                                           child: CircularProgressIndicator(),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 8,
//                                   left: 8,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(15),
//                                       color: Theme.of(context).accentColor,
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 5,
//                                     ),
//                                     child: Text(
//                                       item.category,
//                                       style: TextStyle(
//                                         fontSize: FontSizesWidget.of(context)
//                                             .veryThin,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(
//                               left: imageWidth,
//                             ),
//                             child: Row(
//                               children: <Widget>[
//                                 const SizedBox(
//                                   width: 15,
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 15,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.stretch,
//                                       children: <Widget>[
//                                         Row(
//                                           children: <Widget>[
//                                             Container(
//                                               height: 8,
//                                               width: 8,
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 color: Theme.of(context)
//                                                     .accentColor,
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                               width: 8,
//                                             ),
//                                             Text(
//                                               item.typeName,
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 5,
//                                         ),
//                                         Text(
//                                           item.name,
//                                           style: TextStyle(
//                                             fontSize:
//                                                 FontSizesWidget.of(context)
//                                                     .large,
//                                             fontWeight: FontWeight.w300,
//                                           ),
//                                         ),

//                                         const SizedBox(
//                                           height: 8,
//                                         ),
//                                         // Progress
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.stretch,
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: <Widget>[
//                                             Text(
//                                               'lesson',
//                                               style: TextStyle(
//                                                 fontSize:
//                                                     FontSizesWidget.of(context)
//                                                         .thin,
//                                                 fontWeight: FontWeight.w300,
//                                               ),
//                                             ),
//                                             const SizedBox(
//                                               height: 5,
//                                             ),
//                                             ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                 5,
//                                               ),
//                                               child: LinearProgressIndicator(
//                                                 value: 0.5,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               [DataState.loading]: ListView.builder(
//                 itemCount: 5,
//                 addAutomaticKeepAlives: true,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 5,
//                 ),
//                 itemBuilder: (BuildContext context, int index) {
//                   return createItemShimmer();
//                 },
//               ),
//               [DataState.error]: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: ErrorDataWidget(
//                   text: store.state.message ?? '',
//                   onReload: () {
//                     store.dataRefresher.add(null);
//                   },
//                 ),
//               ),
//             },
//           );
//         },
//       ),
//     );
//   }
// }
