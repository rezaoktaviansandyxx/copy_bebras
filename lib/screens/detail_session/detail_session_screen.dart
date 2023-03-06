import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/related_detail_content/related_detail_content_screen.dart';
import 'package:fluxmobileapp/screens/content_rating/content_rating_widget.dart';
import 'package:fluxmobileapp/screens/detail_podcast/detail_podcast_screen.dart';
import 'package:fluxmobileapp/screens/detail_session/detail_session_store.dart';
import 'package:fluxmobileapp/screens/detail_todo_list/detail_todo_list_screen.dart';
import 'package:fluxmobileapp/services/cached_image_manager.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/checkbox_solid_widget.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/rating_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluxmobileapp/stores/detail_accept_goals_store.dart';
import 'package:get/get.dart';

class DetailSessionScreen extends StatefulWidget with BaseWidgetParameterMixin {
  DetailSessionScreen({Key? key}) : super(key: key);

  @override
  _DetailSessionScreenState createState() => _DetailSessionScreenState();
}

class _DetailSessionScreenState extends State<DetailSessionScreen>
    with BaseStateMixin<DetailSessionStore?, DetailSessionScreen> {
  DetailSessionStore? _store;
  @override
  DetailSessionStore? get store => _store;

  final acceptGoalsStore = DetailAcceptGoalsStore();

  @override
  void initState() {
    super.initState();

    _store = DetailSessionStore(
      sessionId: Get.arguments['sessionId'],
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
                      Get.back();
                      // Navigator.of(context).pop();
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
  }

  Widget buildListSeriesEpisodes(
    BuildContext context,
    List<SeriesEpisode> list,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListView.separated(
          padding: const EdgeInsets.all(0),
          itemCount: list.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            final item = list[index];
            final number = ++index;

            return InkWell(
              onTap: () {
                store!.goToDetail.executeIf(
                  item,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  color: context.isLight
                      ? const Color(0xffF3F8FF)
                      : AppTheme.of(context).canvasColorLevel3,
                ),
                clipBehavior: Clip.antiAlias,
                child: Observer(
                  builder: (context) {
                    const double imageWidth = 120;
                    return Stack(
                      children: <Widget>[
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: imageWidth,
                          child: CachedNetworkImage(
                            imageUrl: item.imageThumbnail!,
                            fit: BoxFit.cover,
                            errorWidget: (context, v, vv) => const SizedBox(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: imageWidth + 10,
                            top: 10,
                            right: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      item.title ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                        fontSize: FontSizesWidget.of(context)!
                                            .regular,
                                        // color: item
                                        //         .isSelected
                                        //     ? AppTheme.of(context)
                                        //         .selectedColor
                                        //     : Theme.of(context)
                                        //         .textTheme
                                        //         .bodyText2
                                        //         .color,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'EPISODE $number',
                                      style: TextStyle(
                                        fontSize:
                                            FontSizesWidget.of(context)!.thin,
                                        // color: item
                                        //         .isSelected
                                        //     ? AppTheme.of(context)
                                        //         .selectedColor
                                        //     : Theme.of(context)
                                        //         .textTheme
                                        //         .bodyText2
                                        //         .color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const EpisodePlayButton(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 10,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            Observer(
              builder: (BuildContext context) {
                return WidgetSelector(
                  maintainState: true,
                  selectedState: store!.state,
                  states: {
                    [DataState.success]: SingleChildScrollView(
                      child: Builder(
                        builder: (BuildContext context) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ClipPath(
                                clipper: CurveClipper(),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 250,
                                        child: Builder(
                                          builder: (BuildContext context) {
                                            return CachedNetworkImage(
                                              imageUrl: store?.seriesDetailItem
                                                      ?.imageThumbnail ??
                                                  '',
                                              cacheManager:
                                                  NoCachedImageManager(),
                                              fit: BoxFit.cover,
                                              errorWidget: (context, v, vv) =>
                                                  const SizedBox(),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  bottom: 10,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: const Color(0xffAAA292),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          child: Text(
                                            store!.seriesDetailItem!.tags ?? '',
                                            style: TextStyle(
                                              fontSize:
                                                  FontSizesWidget.of(context)!
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
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          child: Text(
                                            'Series',
                                            style: TextStyle(
                                              fontSize:
                                                  FontSizesWidget.of(context)!
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

                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  bottom: 10,
                                ),
                                child: Text(
                                  store!.seriesDetailItem!.title ?? '',
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
                                                fontSize:
                                                    FontSizesWidget.of(context)!
                                                        .veryThin,
                                              ),
                                            ),
                                            TextSpan(
                                              text: store!.seriesDetailItem
                                                      ?.publisher ??
                                                  '',
                                              style: TextStyle(
                                                fontSize:
                                                    FontSizesWidget.of(context)!
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
                                        store!.seriesDetailItem!.rating,
                                        store!.seriesDetailItem!.totalUserRate,
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
                                  store!.seriesDetailItem!.description ?? '',
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
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    buildListSeriesEpisodes(
                                      context,
                                      store!.seriesDetailItem!.items!,
                                    ),
                                  ],
                                ),
                              ),

                              // Todo list
                              DetailTodoListScreen(
                                goalName: store!.seriesDetailItem?.title,
                                todos: store!.todos,
                              ),

                              store!.seriesDetailItem!.userRated != true
                                  ? ContentRatingWidget(
                                      title: 'How good this series for you?',
                                      request: RateContentRequest()
                                        ..id = store!.seriesDetailItem!.id
                                        ..contentType = BrowseType.series,
                                      onRated: () {
                                        store!.getData.executeIf();
                                      },
                                    )
                                  : const SizedBox(),
                              RelatedDetailContentScreen(
                                contentId: store!.seriesDetailItem!.id,
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
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.of(context).canvasColorLevel2!,
                      // AppTheme.of(context).canvasColorLevel2.withOpacity(
                      //       snapshot.data > 1.0
                      //           ? 1.0
                      //           : snapshot.data < 0 ? 0 : snapshot.data,
                      //     ),
                      AppTheme.of(context).canvasColorLevel2!.withOpacity(0.1),
                    ],
                  ),
                ),
                child: AppBar(
                  centerTitle: false,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () {
                      store!.goBack.executeIf();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
