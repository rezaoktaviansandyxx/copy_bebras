import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/components/user_profile_button.dart';
import 'package:fluxmobileapp/screens/browse/browse_filter_screen.dart';
import 'package:fluxmobileapp/screens/browse/browse_store.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';

import '../../stores/user_profile_store.dart';
import '../../appsettings.dart';

class BrowseScreen extends StatefulWidget {
  BrowseScreen({Key? key}) : super(key: key);

  _BrowseScreenState createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen>
    with
        BaseStateMixin<BrowseStore, BrowseScreen>,
        AutomaticKeepAliveClientMixin {
  final _store = BrowseStore();
  @override
  BrowseStore get store => _store;

  final localization = sl.get<ILocalizationService>();
  final scrollController = ScrollController();

  final searchFocusNode = FocusNode();
  final double listHeight = 250;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        store.loadMoreRefresher.add(null);
      }
    });

    {
      final d = store.filterInteraction.registerHandler((i) async {
        final r = await showDialog(
          context: context,
          builder: (context) {
            return BrowseFilterScreen(
              browseFilterStore: store.browseFilterStore,
            );
          },
        );
        return r;
      });
      store.registerDispose(() {
        d.dispose();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabStore = Provider.of<MainTabStore>(
        context,
        listen: false,
      );

      {
        final d = tabStore.topicStream.listen((e) {
          final topicItem = tabStore.topicStream.value;
          if (topicItem == null) {
            // This should be hit the frst time widget created and there is no filter value created
            store.getDefaultFilterRefresher.add(null);
            return;
          }

          store.getDefaultFilterRefresher.add({
            'topicItem': topicItem,
          });
        });
        store.registerDispose(() {
          d.cancel();
        });
      }

      {
        final d = tabStore.focusBrowseSearch
            .where((t) => t == true)
            .doOnData((event) {
              FocusScope.of(context).unfocus();
            })
            .delay(const Duration(milliseconds: 350))
            .listen((value) {
              FocusScope.of(context).requestFocus(searchFocusNode);
              tabStore.focusBrowseSearch.add(false);
            });
        store.registerDispose(() {
          d.cancel();
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

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
  void dispose() {
    scrollController.dispose();
    searchFocusNode.dispose();

    super.dispose();
  }

  final formKey = GlobalKey<FormState>();

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
                title: Text(
                  'Browse',
                  style: context.isLight
                      ? TextStyle(
                          color: const Color(0xff00ADEE),
                        )
                      : null,
                ),
                centerTitle: false,
                backgroundColor: context.isLight ? Colors.transparent : null,
                actions: <Widget>[
                  TutorialWalkthroughBasic(
                    selectedTutorialIndex: 0,
                    store: store.tutorialWalkthroughStore,
                    child: IconButton(
                      iconSize: 30,
                      icon: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Icon(
                              Icons.filter_alt_rounded,
                              color: Colors.white,
                            ),
                            // Image.asset(
                            //   'images/ic_filter.png',
                            //   color: Colors.white,
                            // ),
                          ),
                          Observer(
                            builder: (context) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: Opacity(
                                  opacity: store.browseFilterStore == null ||
                                          !store
                                              .browseFilterStore!.containsFilter
                                      ? 0.0
                                      : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xff5AD57F),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onPressed: () {
                        store.showBrowseFilter.executeIf();
                      },
                    ),
                  ),
                  UserProfileButton(),
                ],
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomPaint(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Form(
                              key: formKey,
                              child: TutorialWalkthroughBasic(
                                selectedTutorialIndex: 1,
                                store: store.tutorialWalkthroughStore,
                                child: TextFormField(
                                  onChanged: (v) {
                                    store.query = v;
                                  },
                                  focusNode: searchFocusNode,
                                  // autofocus: true,
                                  style:
                                      TextStyle().copyWith(color: Colors.black),
                                  decoration: InputDecoration(
                                    fillColor: context.isLight
                                        ? const Color(0xffEDF3FC)
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ),
                                      borderSide: context.isLight
                                          ? BorderSide(
                                              width: 1,
                                              color: const Color(0xff8597AE),
                                            )
                                          : BorderSide.none,
                                    ),
                                    hintText: 'Mencari',
                                    suffixIcon: Icon(
                                      Icons.search,
                                      size: 24,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pembahasan Soal',
                                  style: AppTheme.of(context)
                                      .sectionTitle
                                      .copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                                Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: listHeight,
                              child: ListView.builder(
                                itemCount: 1,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {},
                                        child: AspectRatio(
                                          aspectRatio:
                                              listHeight / (listHeight - 0),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              10,
                                            ),
                                            child: SessionItemWidget(
                                              useExpandedCategory: false,
                                              item: SessionItem()
                                                ..title = ''
                                                ..category = 'Pembahasan Soal'
                                                ..imageThumbnail =
                                                    'images/bebras/bebras_pembahasan_soal.png'
                                                ..author = 'Bebras Indonesia',
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: AspectRatio(
                                          aspectRatio:
                                              listHeight / (listHeight - 0),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              10,
                                            ),
                                            child: SessionItemWidget(
                                              useExpandedCategory: false,
                                              item: SessionItem()
                                                ..title = ''
                                                ..category = 'Pembahasan Soal'
                                                ..imageThumbnail =
                                                    'images/bebras/bebras_pembahasan_soal_2.png'
                                                ..author = 'Bebras Indonesia',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Contoh Soal',
                                  style: AppTheme.of(context)
                                      .sectionTitle
                                      .copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                                Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: listHeight,
                              child: ListView.builder(
                                itemCount: 1,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {},
                                        child: AspectRatio(
                                          aspectRatio:
                                              listHeight / (listHeight + 100),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              10,
                                            ),
                                            child: SessionItemWidget(
                                              useExpandedCategory: false,
                                              item: SessionItem()
                                                ..title = ''
                                                ..category = 'Contoh Soal'
                                                ..imageThumbnail =
                                                    'images/bebras/bebras_contoh_soal.png'
                                                ..author = 'Bebras Indonesia',
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: AspectRatio(
                                          aspectRatio:
                                              listHeight / (listHeight + 100),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              10,
                                            ),
                                            child: SessionItemWidget(
                                              useExpandedCategory: false,
                                              item: SessionItem()
                                                ..title = ''
                                                ..category = 'Contoh Soal'
                                                ..imageThumbnail =
                                                    'images/bebras/bebras_contoh_soal.png'
                                                ..author = 'Bebras Indonesia',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bebras Challenge',
                                  style: AppTheme.of(context)
                                      .sectionTitle
                                      .copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                                Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: listHeight,
                              child: ListView.builder(
                                itemCount: 1,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          
                                        },
                                        child: AspectRatio(
                                          aspectRatio:
                                              listHeight / (listHeight - 0),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              10,
                                            ),
                                            child: SessionItemWidget(
                                              useExpandedCategory: false,
                                              item: SessionItem()
                                                ..title = ''
                                                ..category = 'Bebras Challenge'
                                                ..imageThumbnail =
                                                    'images/bebras/bebras_challenge.png'
                                                ..author = 'Bebras Indonesia',
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: AspectRatio(
                                          aspectRatio:
                                              listHeight / (listHeight - 0),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              10,
                                            ),
                                            child: SessionItemWidget(
                                              useExpandedCategory: false,
                                              item: SessionItem()
                                                ..title = ''
                                                ..category = 'Bebras Challenge'
                                                ..imageThumbnail =
                                                    'images/bebras/bebras_challenge.png'
                                                ..author = 'Bebras Indonesia',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Expanded(
                  //   child: Observer(
                  //     builder: (BuildContext context) {
                  //       return WidgetSelector(
                  //         selectedState: store.state,
                  //         states: {
                  //           [DataState.success]:
                  //           SmartRefresher(
                  //             controller: RefreshController(
                  //               initialRefresh: false,
                  //             ),
                  //             onRefresh: () {
                  //               store.dataRefresher.add(null);
                  //             },
                  //             footer: Container(
                  //               height: 100,
                  //               color: Colors.green,
                  //             ),
                  //             child: GridView.builder(
                  //               gridDelegate:
                  //                   SliverGridDelegateWithMaxCrossAxisExtent(
                  //                 maxCrossAxisExtent: 250,
                  //                 childAspectRatio: 0.75,
                  //               ),
                  //               controller: scrollController,
                  //               itemCount: store.items.length + 1,
                  //               padding: const EdgeInsets.only(
                  //                 left: 5,
                  //                 right: 5,
                  //                 bottom: 15,
                  //               ),
                  //               addAutomaticKeepAlives: true,
                  //               shrinkWrap: true,
                  //               physics: const ClampingScrollPhysics(),
                  //               itemBuilder: (BuildContext context, int index) {
                  //                 if (index == store.items.length) {
                  //                   return Observer(
                  //                     builder: (BuildContext context) {
                  //                       if (store.loadMoreState ==
                  //                           DataState.loading) {
                  //                         return Container(
                  //                           padding: const EdgeInsets.only(
                  //                             left: 10,
                  //                             right: 10,
                  //                             top: 10,
                  //                           ),
                  //                           child: AppShimmer(
                  //                             child: SessionItemShimmerWidget(),
                  //                           ),
                  //                         );
                  //                       }

                  //                       return const SizedBox(
                  //                         height: 0,
                  //                       );
                  //                     },
                  //                   );
                  //                 }

                  //                 final item = store.items[index];

                  //                 return InkWell(
                  //                   onTap: () {
                  //                     store.goToDetail.executeIf(item);
                  //                   },
                  //                   child: Container(
                  //                     padding: const EdgeInsets.only(
                  //                       left: 10,
                  //                       right: 10,
                  //                       top: 10,
                  //                     ),
                  //                     child: SessionItemWidget(
                  //                       item: SessionItem()
                  //                         ..category = item.type
                  //                         ..author = item.author
                  //                         ..imageThumbnail = item.imageThumbnail
                  //                         ..rating = item.rating
                  //                         ..totalUserRate = item.totalUserRate
                  //                         ..title = item.title
                  //                         ..tag = item.tags,
                  //                     ),
                  //                   ),
                  //                 );
                  //               },
                  //             ),
                  //           ),
                  //           [DataState.loading]: GridView.builder(
                  //             gridDelegate:
                  //                 const SliverGridDelegateWithFixedCrossAxisCount(
                  //               crossAxisCount: 2,
                  //               childAspectRatio: 0.75,
                  //             ),
                  //             itemCount: 5,
                  //             padding: const EdgeInsets.only(
                  //               left: 5,
                  //               right: 5,
                  //               bottom: 15,
                  //             ),
                  //             addAutomaticKeepAlives: true,
                  //             shrinkWrap: true,
                  //             itemBuilder: (BuildContext context, int index) {
                  //               return Container(
                  //                 padding: const EdgeInsets.only(
                  //                   left: 10,
                  //                   right: 10,
                  //                   top: 10,
                  //                 ),
                  //                 child: AppShimmer(
                  //                   child: SessionItemShimmerWidget(),
                  //                 ),
                  //               );
                  //             },
                  //           ),
                  //           [DataState.error]: Padding(
                  //             padding: const EdgeInsets.all(10),
                  //             child: ErrorDataWidget(
                  //               text: store.state.message ?? '',
                  //               onReload: () {
                  //                 store.dataRefresher.add(null);
                  //               },
                  //             ),
                  //           ),
                  //           [DataState.empty]: Padding(
                  //             padding: const EdgeInsets.all(10),
                  //             child: ErrorDataWidget(
                  //               text: localization!.getByKey(
                  //                 'common.empty',
                  //               ),
                  //             ),
                  //           ),
                  //         },
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
