import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/related_detail_content/related_detail_content_screen.dart';
import 'package:fluxmobileapp/screens/content_rating/content_rating_widget.dart';
import 'package:fluxmobileapp/screens/detail_podcast/detail_podcast_store.dart';
import 'package:fluxmobileapp/screens/detail_todo_list/detail_todo_list_screen.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/checkbox_solid_widget.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/rating_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluxmobileapp/stores/detail_accept_goals_store.dart';
import 'package:tuple/tuple.dart';

import '../../appsettings.dart';

class DetailPodcastScreen extends StatefulWidget with BaseWidgetParameterMixin {
  DetailPodcastScreen({Key? key}) : super(key: key);

  @override
  _DetailPodcastScreenState createState() => _DetailPodcastScreenState();
}

class _DetailPodcastScreenState extends State<DetailPodcastScreen>
    with BaseStateMixin<DetailPodcastStore?, DetailPodcastScreen> {
  DetailPodcastStore? _store;
  @override
  DetailPodcastStore? get store => _store;

  final webViewController = BehaviorSubject<InAppWebViewController>(
    sync: true,
  );

  @override
  void initState() {
    super.initState();

    _store = DetailPodcastStore(
      podcastId: Get.arguments['podcastId'],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store!.getData.executeIf();

      {
        final d = acceptGoalsStore.alertInteraction.registerHandler((f) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  f ?? '',
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return Future.value(null);
        });
        store!.registerDispose(() {
          d.dispose();
        });
      }
    });

    {
      final d = MobxUtils.toStream(() => store!.selectedEpisode)
          .mergeWith([webViewController])
          .where((t) {
            return store!.selectedEpisode != null;
          })
          .where((t) {
            return webViewController.value != null;
          })
          .asyncExpand(
            (_) => DeferStream(() {
              final html = getHtml(store!.selectedEpisode!);
              return webViewController.value
                  .loadData(
                    data: html,
                  )
                  .asStream();
            }),
          )
          .listen(null);
      store!.registerDispose(() {
        d.cancel();
        webViewController.close();
      });
    }
  }

  String getHtml(TileItem<PodcastEpisode> item) {
    final podcastItem = item.value!.id;
    final html = """
    <!DOCTYPE html>
<html>

<head>
  <meta charset='utf-8'>
  <meta http-equiv='X-UA-Compatible'
    content='IE=edge'>
  <title>Page Title</title>
  <meta name='viewport'
    content='initial-scale=1, user-scalable=no, width=device-width'>
</head>

<body>
  <iframe src="https://open.spotify.com/embed-podcast/episode/$podcastItem" width="100%" height="250" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe>
</body>

</html>
                          """;
    return html;
  }

  final acceptGoalsStore = DetailAcceptGoalsStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppBar(
              centerTitle: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  store!.goBack.executeIf();
                },
              ),
            ),
            Expanded(
              child: Observer(
                builder: (BuildContext context) {
                  return WidgetSelector(
                    selectedState: store!.state,
                    maintainState: true,
                    states: {
                      [DataState.success]: SingleChildScrollView(
                        child: Builder(
                          builder: (BuildContext context) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 260,
                                        child: Builder(
                                          key: UniqueKey(),
                                          builder: (BuildContext context) {
                                            return InAppWebView(
                                              initialData:
                                                  InAppWebViewInitialData(
                                                data: '<html></html>',
                                              ),
                                              onWebViewCreated: (controller) {
                                                logger.i(
                                                  'Podcast webview created',
                                                );
                                                webViewController
                                                    .add(controller);
                                              },
                                              onLoadStart: (controller, r) {
                                                final url = r.toString();
                                                if (url.startsWith('http')) {
                                                  controller.stopLoading();
                                                }
                                              },
                                              initialOptions:
                                                  InAppWebViewGroupOptions(
                                                crossPlatform:
                                                    InAppWebViewOptions(
                                                  transparentBackground: true,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color:
                                                        const Color(0xffAAA292),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  child: Text(
                                                    store!.podcastDetailItem
                                                            ?.tags ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .veryThin,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  child: Text(
                                                    'Podcast',
                                                    style: TextStyle(
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .veryThin,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    bottom: 10,
                                  ),
                                  child: Text(
                                    store?.podcastDetailItem?.title ?? '',
                                    style: TextStyle(
                                      fontSize: FontSizesWidget.of(context)!.h4,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Author & star
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'By: ',
                                                style: TextStyle(
                                                  color: context.isLight
                                                      ? const Color(0xff5A6E8F)
                                                      : AppTheme.of(context)
                                                          .sectionTitle
                                                          .color,
                                                  fontSize: FontSizesWidget.of(
                                                          context)!
                                                      .veryThin,
                                                ),
                                              ),
                                              TextSpan(
                                                text: store!.podcastDetailItem
                                                        ?.publisher ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: FontSizesWidget.of(
                                                          context)!
                                                      .veryThin,
                                                  color: context.isLight
                                                      ? const Color(0xff1B304D)
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      RatingWidget(
                                        rating: getContentRating(
                                          store!.podcastDetailItem?.rating,
                                          store!
                                              .podcastDetailItem?.totalUserRate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),

                                // Description
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    bottom: 15,
                                  ),
                                  child: Text(
                                    store!.podcastDetailItem?.description ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          FontSizesWidget.of(context)!.regular,
                                    ),
                                  ),
                                ),

                                // Episodes
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    bottom: 15,
                                  ),
                                  child: Observer(
                                    builder: (context) {
                                      return ListView.separated(
                                        padding: const EdgeInsets.all(0),
                                        itemCount: store!.episodes.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          final item = store!.episodes[index];
                                          final number = index + 1;

                                          return GestureDetector(
                                            onTap: () {
                                              store!.playEpisode.executeIf(
                                                Tuple2(item, index),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10,
                                                ),
                                                color: context.isLight
                                                    ? const Color(0xffF3F8FF)
                                                    : AppTheme.of(context)
                                                        .canvasColorLevel3,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 20,
                                              ),
                                              child: Observer(
                                                builder: (context) {
                                                  return Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Observer(
                                                          builder: (BuildContext
                                                              context) {
                                                            return Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  item.value!
                                                                          .name ??
                                                                      '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Quicksand',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize: FontSizesWidget.of(
                                                                            context)!
                                                                        .large,
                                                                    color: item
                                                                            .isSelected
                                                                        ? AppTheme.of(context)
                                                                            .selectedColor
                                                                        : Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2!
                                                                            .color,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'EPISODE $number',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        FontSizesWidget.of(context)!
                                                                            .thin,
                                                                    color: item
                                                                            .isSelected
                                                                        ? AppTheme.of(context)
                                                                            .selectedColor
                                                                        : Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2!
                                                                            .color,
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const EpisodePlayButton(),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const SizedBox(
                                            height: 10,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),

                                // Todo list
                                DetailTodoListScreen(
                                  goalName: store!.podcastDetailItem?.title,
                                  todos: store!.todos,
                                ),

                                store!.podcastDetailItem?.userRated != true
                                    ? ContentRatingWidget(
                                        title: 'How good this podcast for you?',
                                        request: RateContentRequest()
                                          ..id = store!.podcastDetailItem?.id
                                          ..contentType = BrowseType.podcast,
                                        onRated: () {
                                          store!.getData.executeIf();
                                        },
                                      )
                                    : const SizedBox(),
                                RelatedDetailContentScreen(
                                  contentId: store!.podcastDetailItem?.id,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      [DataState.loading]: Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      [DataState.error]: ErrorDataWidget(
                        text: store!.state.message ?? '',
                        onReload: () {
                          store!.getData.executeIf();
                        },
                      ),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EpisodePlayButton extends StatelessWidget {
  const EpisodePlayButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            context.isLight ? const Color(0xffE5EBF4) : const Color(0xff485d7a),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.isLight
              ? const Color(0xffF3F8FF)
              : Theme.of(context).iconTheme.color,
        ),
        padding: const EdgeInsets.all(2),
        child: Center(
          child: Icon(
            Icons.play_arrow,
            color: context.isLight
                ? const Color(0xff5A6E8F)
                : AppTheme.of(context).canvasColorLevel2,
          ),
        ),
      ),
    );
  }
}
