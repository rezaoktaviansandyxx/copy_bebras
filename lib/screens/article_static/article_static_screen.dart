import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/article_static/detail_article_static_screen.dart';
import 'package:fluxmobileapp/screens/popular_sesion/popular_session_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../../appsettings.dart';

class ArticleScreenStatic extends StatefulWidget {
  final Stream? refreshTrigger;
  final String title;
  final String title2;
  final TextStyle? style;

  ArticleScreenStatic(
      {Key? key, this.refreshTrigger, required this.title, required this.title2, this.style})
      : super(key: key);

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
                  widget.title??'',
                  style: widget.style,
                ),
                Text(
                  widget.title2??'',
                  style: AppTheme.of(context).sectionTitle.copyWith(
                        fontSize: 12,
                      ),
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
                      itemCount: 1,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 5,
                      ),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final item = store.items
                            .where((num) =>
                                num.id?.contains(
                                    '9294f338-2f8c-47f6-946e-b0911cd3cc8a') ??
                                false)
                            .toList();
                        final item2 = store.items
                            .where((num) =>
                                num.id?.contains(
                                    '4299b73e-bd46-4c36-98da-707b91139161') ??
                                false)
                            .toList();
                        ;

                        return Row(
                          children: [
                            InkWell(
                              onTap: () {
                                store.goToDetail.executeIf(item[0]);
                              },
                              child: AspectRatio(
                                aspectRatio: listHeight / (listHeight + 100),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    10,
                                  ),
                                  child: SessionItemWidget(
                                    item: SessionItem()
                                      ..author = item[0].author
                                      ..imageThumbnail = item[0].imageThumbnail
                                      ..rating = item[0].rating
                                      ..totalUserRate = item[0].totalUserRate
                                      ..title = item[0].title
                                      ..category = item[0].type
                                      ..tag = item[0].tags,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () {
                                store.goToDetail.executeIf(item2[0]);
                              },
                              child: AspectRatio(
                                aspectRatio: listHeight / (listHeight + 100),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    10,
                                  ),
                                  child: SessionItemWidget(
                                    item: SessionItem()
                                      ..author = item2[0].author
                                      ..imageThumbnail = item2[0].imageThumbnail
                                      ..rating = item2[0].rating
                                      ..totalUserRate = item2[0].totalUserRate
                                      ..title = item2[0].title
                                      ..category = item2[0].type
                                      ..tag = item2[0].tags,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                  // [DataState.none]: SizedBox(
                  //   height: listHeight,
                  //   child: ListView.builder(
                  //     itemCount: 1,
                  //     scrollDirection: Axis.horizontal,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       return Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           InkWell(
                  //             onTap: () {
                  //               Get.to(
                  //                 DetailArticleStaticScreen(),
                  //               );
                  //             },
                  //             child: AspectRatio(
                  //               aspectRatio: listHeight / (listHeight - 30),
                  //               child: Padding(
                  //                 padding: EdgeInsets.all(
                  //                   10,
                  //                 ),
                  //                 child: SessionItemWidget(
                  //                   useExpandedCategory: false,
                  //                   item: SessionItem()
                  //                     ..title =
                  //                         'Institut Teknologi Sumatera, \nBandar Lampung'
                  //                     ..tag = '23 September 2017'
                  //                     ..category = 'Artikel'
                  //                     ..imageThumbnail =
                  //                         'images/bebras/Itera-2017-01-300x225 1.png'
                  //                     ..author = 'Bebras Indonesia',
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           InkWell(
                  //             onTap: () {},
                  //             child: AspectRatio(
                  //               aspectRatio: listHeight / (listHeight - 30),
                  //               child: Padding(
                  //                 padding: EdgeInsets.all(
                  //                   10,
                  //                 ),
                  //                 child: SessionItemWidget(
                  //                   useExpandedCategory: false,
                  //                   item: SessionItem()
                  //                     ..title =
                  //                         'Univesitas Lambung \nMangkurat, Samarinda'
                  //                     ..tag = '18 Juli 2017'
                  //                     ..category = 'Artikel'
                  //                     ..imageThumbnail =
                  //                         'images/bebras/Unlam-2017-01-270x270 1.png'
                  //                     ..author = 'Bebras Indonesia'
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       );
                  //     },
                  //   ),
                  // ),
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
