import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/interest/interest_picker.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/stores/interest_store.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../screens/assessment/assessment_chart_store.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({
    Key? key,
  }) : super(key: key);

  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final appServices = sl.get<AppServices>();

  TabController? _tabController;
  final _tabStream = BehaviorSubject.seeded(0);

  final List<StreamSubscription> d = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      vsync: this,
      length: 2,
    );
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        _tabStream.add(_tabController!.index);
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final profileStore = Provider.of<UserProfileStore>(
        context,
        listen: false,
      );
      d.add(MobxUtils.toStream(() =>
              profileStore.tutorialWalkthroughStore!.currentTutorialIndex.value)
          .listen((event) {
        final v =
            profileStore.tutorialWalkthroughStore!.currentTutorialIndex.value;
        if (v == 2) {
          _tabController!.animateTo(1);
        } else if (v == 1) {
          _tabController!.animateTo(0);
        }
      }));
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _tabStream.close();
    for (var item in d) {
      item.cancel();
    }
    d.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );
    final asssessmentChartStore = Provider.of<AssessmentChartStore>(
      context,
      listen: false,
    );
    asssessmentChartStore.dataRefresher.add(null);

    final interestStore = Provider.of<InterestStore>(
      context,
      listen: false,
    );
    interestStore.dataRefresher.add(null);

    final content = FutureBuilder<int>(
      future: profileStore.tutorialWalkthroughStore!.getLastTutorialIndex
          .executeIf()
          .then(
            (e) => profileStore
                .tutorialWalkthroughStore!.currentTutorialIndex.value!,
          ),
      initialData: null,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: context.isLight ? Colors.transparent : null,
          appBar: AppBar(
            backgroundColor: context.isLight ? Colors.transparent : null,
            iconTheme: IconThemeData(
              color: context.isLight ? Colors.white : null,
            ),
            centerTitle: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Get.back();
                // Navigator.of(context).pop();
              },
            ),
            actions: <Widget>[
              TutorialWalkthroughBasic(
                selectedTutorialIndex: 2,
                store: profileStore.tutorialWalkthroughStore,
                child: TextButton(
                  onPressed: () async {
                    if (_tabController!.index == 0) {
                      final secureStorage = sl.get<SecureStorage>()!;
                      final allkeys = await secureStorage.getAll();
                      for (var item in allkeys.entries) {
                        if (item.key.startsWith('assessment-')) {
                          await secureStorage.remove(item.key);
                        }
                      }
                      Get.toNamed('/assessment_introduction');
                      // Navigator.of(context)
                      //     .pushNamed('/assessment_introduction');
                    } else if (_tabController!.index == 1) {
                      Get.toNamed('/interest');
                      // Navigator.of(context).pushNamed('/interest');
                    }
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(
                      color: context.isLight ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Container(
                child: SingleChildScrollView(
                  child: Observer(
                    builder: (BuildContext context) {
                      final profile = profileStore.userProfile!;
                      var isLight = context.isLight;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ClipOval(
                            child: Container(
                              height: 125,
                              width: 125,
                              child: CachedNetworkImage(
                                imageUrl: profile.avatar ?? '',
                                errorWidget: (context, url, d) {
                                  return ProfilePicture(
                                      name:
                                          '${profileStore.userProfile?.fullname}',
                                      radius: 25.0,
                                      fontsize: 40);
                                  // Icon(
                                  //   Icons.account_circle,
                                  //   size: 100,
                                  // );
                                },
                              ),
                            ),
                          ),
                          Text(
                            profile.fullname ?? '',
                            style: AppTheme.of(context)
                                .listItemTitleSettings
                                .copyWith(
                                  color: context.isLight ? Colors.black : null,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.type ?? '',
                            style: AppTheme.of(context)
                                .listItemTitleSettings
                                .copyWith(
                                  fontSize: FontSizesWidget.of(context)!.thin,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: context.isLight
                                  ? null
                                  : Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelStyle: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                fontSize: FontSizesWidget.of(context)!.regular,
                                letterSpacing: 1,
                              ),
                              labelColor: context.isDark
                                  ? Theme.of(context).accentColor
                                  : const Color(0xff0398CD),
                              unselectedLabelColor: context.isLight
                                  ? const Color(0xff8597AE)
                                  : null,
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
                                      'Self Assessment',
                                      textScaleFactor:
                                          getTabTextScaleFactor(context),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Topic Interest',
                                      textScaleFactor:
                                          getTabTextScaleFactor(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          StreamBuilder(
                            initialData: 0,
                            stream: _tabStream,
                            builder: (context, snapshot) {
                              final index = snapshot.data;

                              return WidgetSelector(
                                selectedState: index,
                                maintainState: true,
                                states: {
                                  [0]: Observer(
                                    builder: (BuildContext context) {
                                      return WidgetSelector(
                                        selectedState:
                                            asssessmentChartStore.state,
                                        states: {
                                          [DataState.success]: AssessmentChart(
                                            items: asssessmentChartStore.items,
                                            tutorialWalkthroughStore:
                                                profileStore
                                                    .tutorialWalkthroughStore,
                                          ),
                                          [DataState.loading]: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          [DataState.empty]: Center(
                                            child: ErrorDataWidget(
                                              text: asssessmentChartStore
                                                      .state?.message ??
                                                  'You haven\'t take any assessment',
                                            ),
                                          ),
                                        },
                                      );
                                    },
                                  ),
                                  [1]: Observer(
                                    builder: (BuildContext context) {
                                      final length = interestStore.items.length;

                                      return SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              IgnorePointer(
                                                child: TopicListView(
                                                  tutorialWalkthroughStore:
                                                      profileStore
                                                          .tutorialWalkthroughStore,
                                                  topics: length > 0
                                                      ? interestStore.items
                                                      : [],
                                                  onChangedItem: (v) {
                                                    final newList =
                                                        interestStore.items
                                                            .map((f) {
                                                      if (v.id == f.id) {
                                                        return v;
                                                      }

                                                      return TopicItem.fromJson(
                                                          f.toJson());
                                                    }).toList();
                                                    interestStore
                                                        .changeItems((f) {
                                                      f.clear();
                                                      f.addAll(newList);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                },
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
          ),
        );
      },
    );
    return Container(
      color: context.isLight ? const Color(0xffF3F8FF) : null,
      child: Stack(
        children: [
          AppClipPath(
            height: 175,
          ),
          content,
        ],
      ),
    );
  }
}
