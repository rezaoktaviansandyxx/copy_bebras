import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/related_detail_content/related_detail_content_screen.dart';
import 'package:fluxmobileapp/screens/content_rating/content_rating_widget.dart';
import 'package:fluxmobileapp/screens/detail_todo_list/detail_todo_list_screen.dart';
import 'package:fluxmobileapp/screens/detail_video/detail_video_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/rating_widget.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DetailVideoScreen extends StatefulWidget with BaseWidgetParameterMixin {
  DetailVideoScreen({Key? key}) : super(key: key);

  @override
  _DetailVideoScreenState createState() => _DetailVideoScreenState();
}

class _DetailVideoScreenState extends State<DetailVideoScreen>
    with BaseStateMixin<DetailVideoStore?, DetailVideoScreen> {
  DetailVideoStore? _store;
  @override
  DetailVideoStore? get store => _store;

  @override
  void initState() {
    super.initState();

    _store = DetailVideoStore(
      videoId: Get.arguments['videoId'],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store!.getData.executeIf();
    });
  }

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
                                      YoutubePlayer(
                                        controller: YoutubePlayerController(
                                          initialVideoId: store!
                                                  .videoDetailItem
                                                  ?.externalVideoId ??
                                              '',
                                          flags: YoutubePlayerFlags(
                                            autoPlay: false,
                                          ),
                                        ),
                                        onEnded: (v) {
                                          store!.setComplete.executeIf();
                                        },
                                      ),
                                      const SizedBox(
                                        height: 10,
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
                                                alignment:
                                                    Alignment.centerLeft,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: const Color(
                                                        0xffAAA292),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  child: Text(
                                                    store!.videoDetailItem!
                                                            .tags ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .veryThin,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center,
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
                                                    'Video',
                                                    style: TextStyle(
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .veryThin,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign:
                                                        TextAlign.center,
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

                                // Content
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        store!.videoDetailItem!.title ?? '',
                                        style: TextStyle(
                                          fontSize:
                                              FontSizesWidget.of(context)!.h4,
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
                                                          ? const Color(
                                                              0xff5A6E8F)
                                                          : AppTheme.of(context)
                                                              .sectionTitle
                                                              .color,
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .veryThin,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: store!.videoDetailItem
                                                            ?.publisher ??
                                                        '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          FontSizesWidget.of(
                                                                  context)!
                                                              .veryThin,
                                                      color: context.isLight
                                                          ? const Color(
                                                              0xff1B304D)
                                                          : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          RatingWidget(
                                            rating: getContentRating(
                                              store!.videoDetailItem!.rating,
                                              store!.videoDetailItem!
                                                  .totalUserRate,
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
                                        store!.videoDetailItem!.description ??
                                            '',
                                        style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontWeight: FontWeight.w300,
                                          fontSize: FontSizesWidget.of(context)!
                                              .regular,
                                        ),
                                      ),
                                    ),

                                    // Todo list
                                    DetailTodoListScreen(
                                      goalName: store!.videoDetailItem?.title,
                                      todos: store!.todos,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),

                                store!.videoDetailItem!.userRated != true
                                    ? ContentRatingWidget(
                                        title:
                                            'How good this single video for you?',
                                        request: RateContentRequest()
                                          ..id = store!.videoDetailItem!.id
                                          ..contentType = BrowseType.video,
                                        onRated: () {
                                          store!.getData.executeIf();
                                        },
                                      )
                                    : const SizedBox(),
                                RelatedDetailContentScreen(
                                  contentId: store!.videoDetailItem!.id,
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
                        text: store!.state.message,
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
