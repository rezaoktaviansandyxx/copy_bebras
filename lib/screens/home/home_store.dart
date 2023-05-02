import 'package:flutter/material.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/screens/static/article_static_screen.dart';
import 'package:fluxmobileapp/screens/topic/topic_screen.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';
import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _HomeStore({
    AppClientServices? appClient,
  }) {
    this.appClient = appClient ?? (appClient = this.appClient);

    final refreshAllTrigger = PublishSubject();

    sections = ObservableList.of(
      [
        SectionItem()
          ..widget = (c) {
            return TopicScreen(
              refreshTrigger: refreshAllTrigger,
            );
          }
          ..hasTutorial = true,
        SectionItem()
          ..widget = (c) => ArticleScreenStatic(
                refreshTrigger: refreshAllTrigger,
                title: 'Berita',
                title2: 'Lihat Semua',
                item: [],
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.large,
                  color: Colors.blue,
                ),
              ),
        // SectionItem()
        //   ..widget = (c) {
        //     return RecommendationScreen(
        //       type: RecommendationType.byInterest,
        //       refreshTrigger: refreshAllTrigger,
        //     );
        //   }
        //   ..hasTutorial = true,
        // SectionItem()
        //   ..widget = (c) => RecommendationScreen(
        //         type: RecommendationType.byAssessment,
        //         refreshTrigger: refreshAllTrigger,
        //       ),
        // SectionItem()
        //   ..widget = (c) => RecentSessionScreen(
        //         refreshTrigger: refreshAllTrigger,
        //       ),
        // SectionItem()
        //   ..widget = (c) => PopularSessionScreen(
        //         refreshTrigger: refreshAllTrigger,
        //       ),
        // SectionItem()..widget = (c) => ListOfAuthorScreen(),
      ],
    );

    tutorialWalkthroughStore = TutorialWalkthroughStore(
      'tutorial_home',
    );
    tutorialWalkthroughStore!.tutorials.addAll([
      TutorialWalkthroughBasicData()
        ..title = 'Search'
        ..description = ''
        ..status = '1/3',
      TutorialWalkthroughBasicData()
        ..title = 'Topic'
        ..description = ''
        ..status = '2/3',
      TutorialWalkthroughBasicData()
        ..title = 'Recent Session'
        ..description = ''
        ..status = '3/3',
    ]);

    refreshAll = Command(() async {
      refreshAllTrigger.add(null);
    });
  }

  @observable
  ObservableList<SectionItem>? sections;

  TutorialWalkthroughStore? tutorialWalkthroughStore;

  late Command refreshAll;
}

class SectionItem {
  late Widget Function(BuildContext) widget;
  bool? hasTutorial;
}
