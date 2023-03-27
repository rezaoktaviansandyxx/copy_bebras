import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/popular_sesion/popular_session_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../../appsettings.dart';

class ArticleScreenStatic extends StatefulWidget {
  final Stream? refreshTrigger;

  ArticleScreenStatic({
    Key? key,
    this.refreshTrigger,
  }) : super(key: key);

  _ArticleScreenStaticState createState() => _ArticleScreenStaticState();
}

class _ArticleScreenStaticState extends State<ArticleScreenStatic>
    with BaseStateMixin<PopularSessionStore, ArticleScreenStatic> {
  final _store = PopularSessionStore();
  @override
  PopularSessionStore get store => _store;

  final localization = sl.get<ILocalizationService>();

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.dataRefresher.add(null);
    });

    if (widget.refreshTrigger != null) {
      compositeSubscription.add(widget.refreshTrigger!.listen((value) {
        store.dataRefresher.add(null);
      }));
    }
  }

  @override
  void dispose() {
    compositeSubscription.dispose();

    super.dispose();
  }

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
    final double listHeight = 250;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Berita',
                  style: AppTheme.of(context).sectionTitle,
                ),
                Text(
                  'Lihat Semua',
                  style: AppTheme.of(context).sectionTitle.copyWith(fontSize: 12),
                ),
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
                      itemCount: store.items.length,
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
                            aspectRatio: listHeight / (listHeight + 100),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                10,
                              ),
                              child: SessionItemWidget(
                                item: SessionItem()
                                  ..author = item.author
                                  ..imageThumbnail = item.imageThumbnail
                                  ..rating = item.rating
                                  ..totalUserRate = item.totalUserRate
                                  ..title = item.title
                                  ..category = item.type
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 5,
                      ),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return AspectRatio(
                          aspectRatio: listHeight / (listHeight + 100),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              10,
                            ),
                            child: AppShimmer(
                              child: SessionItemShimmerWidget(),
                            ),
                          ),
                        );
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
          ),
        ],
      ),
    );
  }
}
