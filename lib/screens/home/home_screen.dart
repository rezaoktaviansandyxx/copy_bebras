import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/components/user_profile_button.dart';
import 'package:fluxmobileapp/screens/home/home_store.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_screen.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_store.dart';
import 'package:fluxmobileapp/services/cached_image_manager.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/flux_app_bar.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import '../../stores/user_profile_store.dart';
import '../../appsettings.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with BaseStateMixin<HomeStore, HomeScreen>, AutomaticKeepAliveClientMixin {
  final _store = HomeStore();
  @override
  HomeStore get store => _store;

  final localization = sl.get<ILocalizationService>();

  final searchController = sl.get<TextEditingController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      {
        final store = Provider.of<UserProfileStore>(
          context,
          listen: false,
        );
        store.getProfile.executeIf();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    searchController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final mainTabStore = Provider.of<MainTabStore>(
      context,
      listen: false,
    );
    final userProfileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );
    if (kDebugMode) {
      userProfileStore.getProfile.executeIf();
    }

    final Color? backgroundColor =
        context.isDark ? Theme.of(context).canvasColor : null;

    void focusBrowse() {
      final pageController = PageControllerInheritedWidget.of(context)!;
      pageController.pageController!.jumpToPage(1);
      mainTabStore.focusBrowseSearch.add(true);
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Builder(
          builder: (content) {
            final userProfileStore = Provider.of<UserProfileStore>(
              context,
              listen: false,
            );
            return FluxAppBar(
              actions: <Widget>[
                UserProfileButton(),
              ],
            );
          },
        ),
        Container(
          child: RefreshIndicator(
            onRefresh: () async {
              await store.refreshAll.executeIf();
            },
            color: Colors.black,
            backgroundColor: Colors.white,
            child: Observer(
              builder: (BuildContext context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      color: backgroundColor,
                      child: CustomPaint(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    focusBrowse();
                                  },
                                  child: AbsorbPointer(
                                    child: TutorialWalkthroughBasic(
                                      selectedTutorialIndex: 0,
                                      store: store.tutorialWalkthroughStore,
                                      child: TextFormField(
                                        controller: searchController,
                                        decoration: InputDecoration(
                                          fillColor: context.isLight
                                              ? const Color(0xffEDF3FC)
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Mencari',
                                          suffixIcon: Icon(
                                            Icons.search,
                                            size: 24,
                                            color: context.isDark
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .headline4!
                                                    .color
                                                : const Color(0xff8597AE),
                                          ),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 5,
                        bottom: 5,
                      ),
                      child: Observer(
                        builder: (BuildContext context) {
                          return WidgetSelector(
                            selectedState: userProfileStore.getProfileState,
                            states: {
                              // TODO: check app shimer here
                              [DataState.loading]: AppShimmer(
                                child: SizedBox(
                                  height: 50,
                                  // child: Container(
                                  //   color: Colors.green,
                                  //   child: const SizedBox(),
                                  // ),
                                ),
                              ),
                              [DataState.error]: Center(
                                child: ErrorDataWidget(
                                  text: userProfileStore
                                          .getProfileState.message ??
                                      '',
                                ),
                              ),
                              [DataState.success]: Observer(
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xffD1F3FF),
                                      border: Border.all(
                                        color: const Color(0xff0E9DE9),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(15),
                                      ),
                                    ),
                                    // padding: const EdgeInsets.all(15),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Text(
                                                      'Halo, ${userProfileStore.userProfile?.fullname}!',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: const Color(
                                                          0xff0398CD,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      // 'Mau belajar apa hari ini?',
                                                      'Belajar apa hari ini?',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: const Color(
                                                          0xff0398CD,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                              0xff0E9DE9,
                                                            ),
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: 15,
                                                            ),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                  10,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                // 'Explore',
                                                                'Jelajah',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Quicksand',
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .chevron_right,
                                                                color: Colors
                                                                    .white,
                                                              )
                                                            ],
                                                          ),
                                                          onPressed: () {
                                                            focusBrowse();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          bottom: -55,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Image.asset(
                                              'images/maskot_bebras.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            },
                          );
                        },
                      ),
                    ),
                    ListView.builder(
                      itemCount: store.sections!.length,
                      addAutomaticKeepAlives: true,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (BuildContext context, int index) {
                        final item = store.sections![index];
                        // final widget = item.widget(context);
                        final widget = item.hasTutorial == true
                            ? Observer(
                                builder: (BuildContext context) {
                                  final tutorialIndex = index + 1;
                                  return item.widget(context);
                                  // TutorialWalkthroughBasic(
                                  //   store: store.tutorialWalkthroughStore,
                                  //   selectedTutorialIndex: tutorialIndex,
                                  //   tooltipDirection: tutorialIndex == 2
                                  //       ? TooltipDirection.up
                                  //       : TooltipDirection.down,
                                  //   child: item.widget(context),
                                  // );
                                },
                              )
                            : item.widget(context);
                        return IntrinsicHeight(
                          child: widget,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: FutureBuilder<int>(
        future: store.tutorialWalkthroughStore!.getLastTutorialIndex
            .executeIf()
            .then(
              (e) => store.tutorialWalkthroughStore!.currentTutorialIndex.value,
            ),
        initialData: null,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Container(
              child: Stack(
                children: [
                  AppClipPath(),
                  content,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
