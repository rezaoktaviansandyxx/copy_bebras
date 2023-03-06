import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/list_of_author/list_of_author_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';

import '../../appsettings.dart';

class ListOfAuthorScreen extends StatefulWidget {
  ListOfAuthorScreen({Key? key}) : super(key: key);

  _ListOfAuthorScreenState createState() => _ListOfAuthorScreenState();
}

class _ListOfAuthorScreenState extends State<ListOfAuthorScreen>
    with BaseStateMixin<ListOfAuthorStore, ListOfAuthorScreen> {
  final _store = ListOfAuthorStore();
  @override
  ListOfAuthorStore get store => _store;

  final localization = sl.get<ILocalizationService>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.dataRefresher.add(null);
    });
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  shape: BoxShape.circle,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.more_horiz,
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              height: 14,
              color: Colors.white,
              margin: const EdgeInsets.only(
                bottom: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double listHeight = 120;
    final double itemWidth = listHeight / 1.35;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 5,
            ),
            child: Text(
              localization!.getByKey(
                'list_of_author.title',
              ),
              style: AppTheme.of(context).sectionTitle,
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
                      itemCount: store.items.length + 1,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 5,
                      ),
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == store.items.length) {
                          return GestureDetector(
                            onTap: () {},
                            child: IntrinsicWidth(
                              child: Container(
                                // width: itemWidth,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                  right: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .inputDecorationTheme
                                              .fillColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.more_horiz,
                                            size: 38,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      height: 42,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          localization!.getByKey(
                                            'list_of_author.more',
                                          ),
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                fontSize: FontSizes.thin,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final item = store.items[index];

                        return GestureDetector(
                          onTap: () {},
                          child: IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 10,
                                right: 10,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 60,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: item.avatar ?? '',
                                              // fit: BoxFit.cover,
                                              // alignment: Alignment.center,
                                              placeholder: (c, url) {
                                                return Align(
                                                  alignment: Alignment.center,
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                              errorWidget: (context, url, v) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .inputDecorationTheme
                                                        .fillColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      height: 42,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          item.name!,
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                fontSize: FontSizes.thin,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
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
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
