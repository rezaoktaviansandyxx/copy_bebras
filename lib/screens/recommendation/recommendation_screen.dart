import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/recommendation/recommendation_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../../appsettings.dart';

class RecommendationScreen extends HookWidget {
  final RecommendationType type;
  final Stream? refreshTrigger;

  const RecommendationScreen({
    Key? key,
    required this.type,
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
    final store = useMemoized(
      () => RecommendationStore(
        type: type,
      ),
    );

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          store.dataRefresher.add(null);
        });
        return () {};
      },
      const [],
    );

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

    final mediaQuery = MediaQuery.of(context);
    final double itemWidth = (mediaQuery.size.width - 85);
    final double listHeight = 260;

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
                    type == RecommendationType.byInterest
                        ? 'Your favorite topic'
                        : 'Made for you',
                    style: AppTheme.of(context).sectionTitle,
                  ),
                ),
                // Observer(
                //   builder: (BuildContext context) {
                //     if (store.items.length == 0) {
                //       return const SizedBox();
                //     }

                //     return FlatButton.icon(
                //       icon: const Icon(Icons.refresh),
                //       label: const DecoratedBox(
                //         decoration: const BoxDecoration(),
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
                                item: SessionItem()
                                  ..author = item.author
                                  ..imageThumbnail = item.imageThumbnail
                                  ..title = item.title
                                  ..category = item.type
                                  ..rating = item.rating
                                  ..totalUserRate = item.totalUserRate
                                  ..tag = item.tags,
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
                      text: 'No items to show',
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
