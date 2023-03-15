import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:provider/provider.dart';

import '../../appsettings.dart';
import 'recent_session_store.dart';

class RecentSessionScreen extends HookWidget {
  final Stream? refreshTrigger;

  const RecentSessionScreen({
    Key? key,
    this.refreshTrigger,
  }) : super(key: key);

  Widget createShimmerItem(double itemWidth) {
    return AppShimmer(
      child: Container(
        width: itemWidth,
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
    final localization = useMemoized((() => sl.get<ILocalizationService>()!) as ILocalizationService Function());

    useMemoized(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final onGoingStore = Provider.of<OnGoingRecentSessionStore>(
          context,
          listen: false,
        );

        {
          final tabStore = Provider.of<MainTabStore>(
            context,
            listen: false,
          );

          final d = tabStore.tabIndex.listen((e) {
            if (e == 0) {
              onGoingStore.dataRefresher.add(null);
            }
          });
          tabStore.registerDispose(() {
            d.cancel();
          });
        }
      });
    });

    final mediaQuery = MediaQuery.of(context);
    final double itemWidth = (mediaQuery.size.width - 85);
    final double listHeight = 260;
    final store = Provider.of<OnGoingRecentSessionStore>(context);

    useEffect(() {
      StreamSubscription? subscription;
      if (refreshTrigger != null) {
        subscription = refreshTrigger!.listen((value) {
          store.dataRefresher.add(null);
        });
      }
      return () {
        if (subscription != null) {
          subscription.cancel();
        }
      };
    }, const []);

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    localization.getByKey(
                      'recent_session.title',
                    ),
                    style: AppTheme.of(context).sectionTitle,
                  ),
                ),
                // Observer(
                //   builder: (BuildContext context) {
                //     if (store.items.length <= 0) {
                //       return const SizedBox();
                //     }

                //     return IconButton(
                //       icon: const Icon(
                //         Icons.refresh,
                //       ),
                //       onPressed: () {
                //         store.dataRefresher.add(null);
                //       },
                //     );
                //   },
                // ),
              ],
            ),
          ),
          Observer(
            builder: (BuildContext context) {
              return WidgetSelector(
                selectedState: store.state,
                states: {
                  [DataState.success]: SizedBox(
                    height: listHeight,
                    child: ListView.builder(
                      itemCount: store.items.length >= pageLimit
                          ? pageLimit
                          : store.items.length,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 5,
                      ),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final item = store.items[index];

                        return InkWell(
                          onTap: () {
                            store.goToDetail.executeIf(item);
                          },
                          child: AspectRatio(
                            aspectRatio: listHeight / (listHeight - 60),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                10,
                              ),
                              child: SessionItemWidget(
                                  useExpandedCategory: false,
                                  showRating: false,
                                  item: SessionItem()
                                    ..author = item.authorName
                                    ..imageThumbnail = item.imageThumbnail
                                    ..title = item.title
                                    ..category = item.type
                                  // ..rating = item.rating
                                  // ..tag = item,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  [DataState.loading]: SizedBox(
                    height: listHeight,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        top: 0,
                        left: 10,
                        right: 10,
                      ),
                      addAutomaticKeepAlives: true,
                      itemBuilder: (BuildContext context, int index) {
                        return createShimmerItem(itemWidth);
                      },
                    ),
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
                      text: 'No recent session',
                      onReload: () {
                        store.dataRefresher.add(null);
                      },
                    ),
                  ),
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
