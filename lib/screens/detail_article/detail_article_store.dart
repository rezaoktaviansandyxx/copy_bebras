import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/related_detail_content/related_detail_content_store.dart';
import 'package:fluxmobileapp/screens/content_rating/content_rating_store.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:mobx/mobx.dart';

import '../../api_services/api_services.dart';
import '../../appsettings.dart';

part 'detail_article_store.g.dart';

class DetailArticleStore = _DetailArticleStore with _$DetailArticleStore;

abstract class _DetailArticleStore extends BaseStore with Store {
  _DetailArticleStore({
    AppServices? appServices,
    AppClientServices? appClient,
    String? articleId,
  }) {
    appServices = appServices ?? sl.get<AppServices>();
    appClient = appClient ?? sl.get<AppClientServices>();

    goBack = Command.sync(() {
      appServices!.navigatorState!.pop();
    });

    getData = Command(() async {
      try {
        state = DataState.loading;

        final i = await appClient!.getDetailArticle(articleId);

        await relatedDetailContentStore.getRelatedContent.executeIf(articleId);

        articleDetailItem = i.payload;

        state = DataState.success;
      } catch (error) {
        state = DataState.error;
      }
    });

    setComplete = Command(() async {
      try {
        await appClient!.setActivityCompleted(
          SetCompleteActivityRequest()
            ..contentId = articleDetailItem!.id
            ..type = getBrowseTypeName(BrowseType.article),
        );
      } catch (error) {
        logger.e(error);
      }
    });

    _tutorialWalkthroughStore = TutorialWalkthroughStore(
      'tutorial_article',
    );
    tutorialWalkthroughStore!.tutorials.addAll([
      TutorialWalkthroughBasicData()
        ..title = 'Dark/Light theme'
        ..description = ''
        ..status = '1/1',
    ]);
  }

  @observable
  var state = DataState.none;

  @observable
  ArticleDetailItem? articleDetailItem;

  late Command getData;

  late Command goBack;

  late Command setComplete;

  final contentRatingStore = ContentRatingStore();

  TutorialWalkthroughStore? _tutorialWalkthroughStore;
  TutorialWalkthroughStore? get tutorialWalkthroughStore =>
      _tutorialWalkthroughStore;

  final relatedDetailContentStore = RelatedDetailContentStore();
}
