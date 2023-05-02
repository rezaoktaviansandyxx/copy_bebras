import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/static/bebras_challenge_store.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';

import '../../appsettings.dart';

class BebrasChallengeScreen extends StatefulWidget {
  final Stream? refreshTrigger;
  final String title;
  final String title2;
  final TextStyle? style;
  final List<BrowseModel> item;

  BebrasChallengeScreen(
      {Key? key,
      this.refreshTrigger,
      required this.title,
      required this.title2,
      required this.item,
      this.style})
      : super(key: key);

  _BebrasChallengeScreenState createState() => _BebrasChallengeScreenState();
}

class _BebrasChallengeScreenState extends State<BebrasChallengeScreen>
    with BaseStateMixin<BebrasChallengeStore, BebrasChallengeScreen> {
  final _store = BebrasChallengeStore();

  @override
  BebrasChallengeStore get store => _store;

  final localization = sl.get<ILocalizationService>();

  final compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();

    if (widget.item.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        store.dataRefresher.add(null);
      });

      if (widget.refreshTrigger != null) {
        compositeSubscription.add(widget.refreshTrigger!.listen((value) {
          store.dataRefresher.add(null);
        }));
      }
    } else {
      store.items.clear();
      store.items.addAll(widget.item);
      store.state = DataState.success;
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
                  widget.title ?? '',
                  style: widget.style,
                ),
                Text(
                  widget.title2 ?? '',
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
                          onTap: () async {
                            final secureStorage = sl.get<SecureStorage>()!;
                            final allkeys = await secureStorage.getAll();
                            for (var item in allkeys.entries) {
                              if (item.key.startsWith('assessment-')) {
                                await secureStorage.remove(item.key);
                              }
                            }
                            Get.toNamed('/assessment_introduction');
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