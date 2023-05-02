import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/interest/interest_picker_badge.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_screen.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/screens/topic/topic_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class TopicScreen extends StatefulWidget {
  final Stream? refreshTrigger;

  TopicScreen({
    Key? key,
    this.refreshTrigger,
  }) : super(key: key);

  _TopicScreenState createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen>
    with BaseStateMixin<TopicStore, TopicScreen> {
  final _store = TopicStore();
  @override
  TopicStore get store => _store;

  final scrollController = ScrollController();
  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        store.loadMoreRefresher.add(null);
      }
    });

    if (widget.refreshTrigger != null) {
      compositeSubscription.add(widget.refreshTrigger!.listen((value) {
        store.dataRefresher.add(null);
      }));
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    compositeSubscription.dispose();

    super.dispose();
  }

  Widget createShimmerItem(double itemWidth) {
    return AppShimmer(
      child: Container(
        width: itemWidth,
        padding: const EdgeInsets.only(
          top: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: itemWidth,
              height: itemWidth - 35,
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 10,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double minWidth = 100;
    final double maxWidth = 138;
    final double listHeight = 150;

    return Observer(
      builder: (BuildContext context) {
        return WidgetSelector(
          selectedState: store.state,
          states: {
            [DataState.success]: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Text(
                    'Program',
                    style: AppTheme.of(context).sectionTitle,
                  ),
                ),
                Container(
                  height: listHeight,
                  child: ListView.builder(
                    itemCount: store.items.length,
                    // itemCount: store.items.length + 1,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    addAutomaticKeepAlives: true,
                    // controller: scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      // // Header
                      // if (index == 0) {
                      //   return Container(
                      //     width: 100,
                      //     color: Colors.red,
                      //   );
                      // }

                      // Footer
                      if (index == store.items.length) {
                        return Observer(
                          builder: (BuildContext context) {
                            return WidgetSelector(
                              selectedState: store.loadMoreState,
                              states: {
                                [DataState.loading]: Container(
                                  child: createShimmerItem(minWidth),
                                ),
                              },
                            );
                          },
                        );
                      }

                      // final item = store.items[--index];
                      final item = store.items[index];

                      return InkWell(
                        onTap: () {
                          final tabStore = Provider.of<MainTabStore>(
                            context,
                            listen: false,
                          );
                          tabStore.topicStream.add(item);

                          final pageController =
                              PageControllerInheritedWidget.of(context)
                                  ?.pageController!;
                          if (pageController == null) {
                            return;
                          }
                          // Go to browse tab
                          pageController.jumpToPage(1);
                        },
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            // minHeight: 5.0,
                            // maxHeight: 30.0,
                            minWidth: minWidth,
                            maxWidth: maxWidth,
                          ),
                          child: InterestPickerBadge(
                            item: item,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            [DataState.loading]: Container(
              height: minWidth + 34,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                addAutomaticKeepAlives: true,
                itemBuilder: (BuildContext context, int index) {
                  return createShimmerItem(minWidth);
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
          },
        );
      },
    );
  }
}
