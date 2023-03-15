import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/screens/detail_article/detail_article_store.dart';
import 'package:fluxmobileapp/stores/app_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:get/get.dart';
import 'package:rxdart/subjects.dart';
import 'package:fluxmobileapp/stores/detail_accept_goals_store.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DetailArticleScreen extends StatefulWidget with BaseWidgetParameterMixin {
  DetailArticleScreen({Key? key}) : super(key: key);

  @override
  _DetailArticleScreenState createState() => _DetailArticleScreenState();
}

class _DetailArticleScreenState extends State<DetailArticleScreen>
    with BaseStateMixin<DetailArticleStore?, DetailArticleScreen> {
  DetailArticleStore? _store;
  @override
  DetailArticleStore? get store => _store;

  final scrollController = ScrollController();

  final appBarOpacity = BehaviorSubject<double>.seeded(0);

  static const double headerHeight = 250;

  final scrollnearbottomhandler = 'scrollnearbottom';

  final starclickhandler = 'starclick';

  final relatedContentClickHandler = 'relatedcontentclick';

  @override
  void initState() {
    super.initState();

    _store = DetailArticleStore(
      articleId: Get.arguments['articleId'],
    );

    scrollController.addListener(() {
      final opacity = scrollController.offset / headerHeight;
      appBarOpacity.add(opacity);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store!.getData.executeIf();

      showAlert(String? alert) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                alert ?? '',
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
      }

      {
        final d = acceptGoalsStore.alertInteraction.registerHandler((f) {
          showAlert(f);
          return Future.value(null);
        });
        store!.registerDispose(() {
          d.dispose();
        });
      }

      {
        final d =
            store!.contentRatingStore.alertInteraction.registerHandler((f) {
          showAlert(f);
          return Future.value(null);
        });
        store!.registerDispose(() {
          d.dispose();
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    appBarOpacity.close();

    super.dispose();
  }

  String getHtml(ArticleDetailItem articleDetailItem) {
    final rating = getContentRating(
        articleDetailItem.rating, articleDetailItem.totalUserRate);

    final todoGoalsApp = StringBuffer("""
    <div id="todo-goals-app">
        <div v-if="todoGoals && todoGoals.length">
          <div class="background-color-2" style="height: 95%; border-radius: 10px 10px 0px 0px;">
            <todo-goal-item-template v-for="(item, index) in todoGoals" :key="index" :id="item.id" :text-on="item.text"
              :text-off="item.text" v-model:checked="item.checked"></todo-goal-item-template>
          </div>
          <div style="position: relative;">
            <div class="background-color-2"
              style="position: absolute;width: 100%;height: 17px;border-radius: 0px 0px 10px 10px;">
            </div>
            <div
              style="width: 100%; display: flex; justify-content: center;position: absolute;/*! width: 100%; *//*! height: 100%; */">
              <button style="padding: 8px 15px;
      border-radius: 10px;
      border: none;
      background-color: #5AD57F;
      color: white;
      font-size: 18px;
      cursor: pointer;
      outline: none;" @click="acceptGoals()">Accept Goals</button>
            </div>

          </div>
        </div>
        <div style="height: 38px;"></div>
      </div>
    """);

    final contentRatingSection = articleDetailItem.userRated != true
        ? """
    <div class="content-rating-style" style="padding: 15px;">
            <div>
                <span style="font-size: 18px;">
                    How good this article for you?
                </span>
            </div>
            <div>
                <span style="font-size: 12px;">
                    Send your ratings here
                </span>
            </div>

            <div style="padding-top: 2px; font-size: 20px;">
                <span id="star-1" class="fa fa-star rating-style " onclick="window.flutter_inappwebview.callHandler('$starclickhandler', 1)"></span>
                <span id="star-2" class="fa fa-star rating-style " onclick="window.flutter_inappwebview.callHandler('$starclickhandler', 2)"></span>
                <span id="star-3" class="fa fa-star rating-style " onclick="window.flutter_inappwebview.callHandler('$starclickhandler', 3)"></span>
                <span id="star-4" class="fa fa-star rating-style " onclick="window.flutter_inappwebview.callHandler('$starclickhandler', 4)"></span>
                <span id="star-5" class="fa fa-star rating-style " onclick="window.flutter_inappwebview.callHandler('$starclickhandler', 5)"></span>
            </div>
        </div>
    """
        : '';

    final relatedContents = store!.relatedDetailContentStore.listRelatedContent;
    final jsonRelatedContent = relatedContents.isNotEmpty
        ? jsonEncode(relatedContents.map((element) {
            return {
              'id': element.id,
              'name': element.title,
              'category': element.type,
              'image': element.imageThumbnail,
            };
          }).toList())
        : '[]';
    final relatedContentSection = """
    <div id="relatedcontent">
    <div v-if="listRelatedContent && listRelatedContent.length" class="related-content-style" style="padding: 15px;">
      <div>
        <span style="font-size: 18px;">
          Related Content
        </span>
      </div>

      <div class="scrollmenu">
        <a v-for="item in listRelatedContent" @key="item.id" @click="relatedContentClick(item)">
          <div class="related-content-card">
            <div class="content-img-parent-parent">
              <div class="content-img-parent">
                <img class="content-img" v-bind:src="item.image">
              </div>
              <div class="content-caption-1">
                <div class="content-caption-2">
                  {{ item.category }}
                </div>
              </div>
            </div>
            <div class="caption-span-container">
                <span class="caption-span">
                  {{ item.name }}
                </span>
              </div>
          </div>
        </a>
      </div>
    </div>
  </div>
    """;

    final todoListArr = articleDetailItem.todoListArr;
    final jsonTodoListArr = todoListArr != null && todoListArr.isNotEmpty
        ? jsonEncode(todoListArr.map((e) {
            return {
              'id': e,
              'text': e,
              'checked': false,
            };
          }).toList())
        : '[]';

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
  <link href="https://fonts.googleapis.com/css2?family=Rubik:wght@300;400&display=swap"
    rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/pretty-checkbox@3.0/dist/pretty-checkbox.min.css" rel="stylesheet">
  <link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
  <script src="https://cdn.jsdelivr.net/npm/vue@3.0.0/dist/vue.global.min.js"></script>
  <script src="https://unpkg.com/vue-star-rating@2.1.0/dist/VueStarRating.umd.min.js"></script>
  <style>
        html.light-mode h2,
        html.light-mode h4 {
            color: #1B304D;
        }

        .rating-style-value {
          align-self: center;
          margin-left: 5px;
        }

        p,
        .rating-style {
            color: #fff !important;
        }

        html.light-mode p,
        html.light-mode .rating-style {
            color: #1B304D !important;
        }

        .box {
            border: none;
            border-color: transparent transparent transparent transparent;
            height: 250px;
            border-radius: 0 0 50% 50% / 25px;
            background-image: url('${articleDetailItem.imageUrl ?? articleDetailItem.imageThumbnail}');
            background-size: cover;
        }

        .border-tag {
            margin-bottom: 5px;
            margin-left: 15px;
            background-color: green;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 14px;
        }

        .parent {
            display: grid;
            grid-template-columns: 1fr 90px;
            grid-template-rows: 1fr;
            grid-column-gap: 0px;
            grid-row-gap: 0px;
        }

        .div1 {
            grid-area: 1 / 1 / 2 / 2;
        }

        .div2 {
            grid-area: 1 / 2 / 2 / 3;
        }

        .info {
            display: grid;
            grid-template-columns: 1fr auto;
            grid-template-rows: 1fr;
            grid-column-gap: 0px;
            grid-row-gap: 0px;
        }

        .checked,
        html.light-mode .checked {
            color: #ECCF71 !important;
        }

        div {
            word-wrap: break-word;
        }

        /* Overwriting some Pretty-Checkbox styles to allow for word wrapping */
        .pretty {
            width: 100%;
            white-space: normal;
            display: flex;
        }

        .pretty .state label {
            text-indent: 0;
            padding-left: 2rem;
        }

        .pretty .state label:after,
        .pretty .state label:before,
        .pretty.p-icon .state .icon {
            top: 0;
        }

        .body-class {
            height: 100%;
            margin: 0px;
        }

        .body-background {
            background-color: #1B304D;
            color: #fff;
            font-family: 'Rubik', sans-serif;
        }

        html.light-mode .body-background {
            background-color: #F3F8FF;
            color: #1B304D !important;
            font-family: 'Rubik', sans-serif;
        }

        .background-color-2 {
            background-color: #354C6B;
        }

        html.light-mode .background-color-2 {
            background-color: #FFFFFF;
        }

        .todo-style {
            color: #5A6E8F;
        }

        html.light-mode .todo-style {
            color: #5A6E8F;
        }

        .content-rating-style {
            background: #122237;
        }
        html.light-mode .content-rating-style {
          background: #E7EFF9;
        }
    </style>

    <!-- Related Content style -->
  <style>
    .related-content-style {
      background: #122237;
    }

    html.light-mode .related-content-style {
      background: #E7EFF9;
    }

    .scrollmenu {
      overflow: auto;
      white-space: nowrap;
    }

    .scrollmenu a {
      display: inline-block;
      padding: 5px 10px;
      text-decoration: none;
    }

    .related-content-card {
      width: 160px;
      display: flex;
      flex-direction: column;
    }

    .content-img-parent-parent {
      position: relative;
    }

    .content-img-parent {
      padding: 10px 0px;
    }

    .content-caption-1 {
      position: absolute;
      top: 0;
      padding: 15px 0px 0px 10px;
    }

    .content-caption-2 {
      background-color: red;
      border-radius: 12px;
      padding: 5px 10px;
      font-size: 14px;
      color: white;
    }

    .content-img {
      border-radius: 20px;
      width: 100%;
      height: 160px;
      object-fit: cover;
    }

    .caption-span-container {
      height: 50px;
    }

    .caption-span {
      white-space: normal;
    }
  </style>

    <script>
        ${appStore!.appTheme!.baseAppTheme == BaseAppTheme.light ? "document.documentElement.classList.add('light-mode');" : ""}
    </script>
</head>

<body class="body body-class body-background">
  <div id="content">
    <div style="margin: 0px">
      <div class="box"
        style="display: flex;">
        <div class="parent"
          style="display: flex; flex-flow: row nowrap; justify-content: space-between; align-self: flex-end; width: 100%">

          <div>
            <div class="border-tag"
              style="width: max-content; background-color: #74BCB0; color: white;">
              ${articleDetailItem.tags}
            </div>
          </div>
          <div class="border-tag"
            style="margin-right: 15px; text-align: center; background-color: #FF5064; color: white;">
            Article
          </div>

        </div>
      </div>
    </div>

    <div style="margin: 15px">
      <h2 style="font-weight: 500; margin: 0px 0px 10px 0px;">
        ${articleDetailItem.title}
      </h2>
      <div class="info">
        <div>
          <h4 style="margin: 0px">
          <span>by: </span>
          <span>${articleDetailItem.author}</span>
        </h4>
        </div>
        <div id="vue-view-rating" style="display: flex;">
          <star-rating
            :rating="rating"
            :round-start-rating="false"
            :show-rating="false"
            :star-size="18"
            read-only></star-rating>
          <div class="rating-style rating-style-value"> (${removeDecimalZeroFormat(rating)})</div>
        </div>
      </div>

      <div style="font-family: 'Rubik'; font-weight: 300;">
        ${articleDetailItem.htmlContent}
      </div>

      ${todoGoalsApp.toString()}
  </div>

  $contentRatingSection

  $relatedContentSection
</body>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.slim.min.js" integrity="sha256-4+XzXVhsDmqanXGHaHvgh1gMQKX40OUvDEBTu8JcmNs=" crossorigin="anonymous"></script>
<script>
\$(window).scroll(function() {
  var scrollY = \$(window).scrollTop() + \$(window).height()
   if(scrollY > \$(document).height() - 100) {
      window.flutter_inappwebview.callHandler('$scrollnearbottomhandler', scrollY)
   }
});
</script>

<!-- Related content -->
<script>

  const ListRendering = {
    data() {
      return {
        listRelatedContent: JSON.parse(JSON.stringify($jsonRelatedContent))
      }
    },
    methods: {
      relatedContentClick: function(item) {
        window.flutter_inappwebview.callHandler('$relatedContentClickHandler', item.id)
      }
    },
  }

  Vue.createApp(ListRendering).mount('#relatedcontent')

</script>

<!-- View rating -->
<script>
  const app = Vue.createApp({ 
    data() {
      return {
        rating: $rating
      }
    },
  })
  app.component('star-rating', VueStarRating.default)
  app.mount('#vue-view-rating')
</script>

<!-- Todo goals -->
<script id="todo-goal-item-template" type="text/x-template">
  <div style="padding: 5px 0px">
    <div class="pretty p-icon p-toggle p-plain" style="width: 100%; margin: 10px 15px;">
      <input type="checkbox" style="cursor: none;" :id="id"
        :checked="checked"
        @change="\$emit('update:checked', \$event.target.checked)">
      <div class="state p-off" style="padding-right: 20px;">
        <i class="icon fa fa-circle todo-style"></i>
        <label>{{ textOff }}</label>
      </div>
      <div class="state p-on" style="padding-right: 20px;">
        <i class="icon fa fa-check-circle"></i>
        <label>{{ textOn }}</label>
      </div>
    </div>
  </div>
</script>
<script>
  Vue.createApp({
    data() {
      return {
        todoGoals: JSON.parse(JSON.stringify($jsonTodoListArr))
      }
    },
    methods: {
      acceptGoals() {
        const choices = []
        for (let index = 0; index < this.todoGoals.length; index++) {
          const element = this.todoGoals[index];
          if (element.checked) {
            choices.push(element.text)
          }
        }
        window.flutter_inappwebview.callHandler('acceptgoals', choices)
      }
    },
  }).component('todo-goal-item-template', {
    template: '#todo-goal-item-template',
    props: {
      id: String,
      textOn: String,
      textOff: String,
      checked: Boolean,
    }
  }).mount('#todo-goals-app')
</script>

</html>
                          """;
    return html;
  }

  final acceptGoalsStore = DetailAcceptGoalsStore();

  final appStore = sl.get<AppStore>();

  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<int>(
        future: store!.tutorialWalkthroughStore!.getLastTutorialIndex
            .executeIf()
            .then(
              (e) =>
                  store!.tutorialWalkthroughStore!.currentTutorialIndex.value!,
            ),
        initialData: null,
        builder: (context, snapshot) {
          return Observer(
            builder: (context) {
              // ignore: unused_local_variable
              final theme = appStore!.appTheme;
              if (webViewController != null) {
                webViewController!.evaluateJavascript(
                  source:
                      'document.documentElement.classList.toggle("light-mode")',
                );
              }

              return SafeArea(
                top: false,
                child: Stack(
                  children: <Widget>[
                    Observer(
                      builder: (BuildContext context) {
                        return WidgetSelector(
                          selectedStates: [
                            store!.state,
                            acceptGoalsStore.state
                          ],
                          maintainState: true,
                          states: {
                            [DataState.success]: Observer(
                              builder: (BuildContext context) {
                                if (store!.articleDetailItem == null) {
                                  return const SizedBox();
                                }

                                return InAppWebView(
                                  initialData: InAppWebViewInitialData(
                                    data: getHtml(
                                      store!.articleDetailItem!,
                                    ),
                                  ),
                                  initialOptions: InAppWebViewGroupOptions(
                                    crossPlatform: InAppWebViewOptions(
                                      transparentBackground: true,
                                      useShouldOverrideUrlLoading: true,
                                    ),
                                  ),
                                  shouldOverrideUrlLoading:
                                      (controller, request) async {
                                    final url = request.request.url.toString();
                                    if (!url.startsWith('http')) {
                                      return NavigationActionPolicy.ALLOW;
                                    }

                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    }

                                    return Future.value(
                                      NavigationActionPolicy.CANCEL,
                                    );
                                  },
                                  onWebViewCreated: (c) {
                                    webViewController = c;

                                    c.addJavaScriptHandler(
                                      handlerName: scrollnearbottomhandler,
                                      callback: (List<dynamic> arguments) {
                                        store!.setComplete.executeIf();
                                      },
                                    );
                                    store!.registerDispose(() {
                                      c.removeJavaScriptHandler(
                                        handlerName: scrollnearbottomhandler,
                                      );
                                    });

                                    c.addJavaScriptHandler(
                                      handlerName: 'acceptgoals',
                                      callback: (List<dynamic> arguments) {
                                        final todos = List<String>.from(
                                          arguments.first,
                                        );
                                        final request = AcceptGoalRequest()
                                          ..goalName =
                                              store!.articleDetailItem!.title
                                          ..todos = todos;
                                        acceptGoalsStore.acceptGoals
                                            .executeIf(request);
                                      },
                                    );

                                    c.addJavaScriptHandler(
                                      handlerName: starclickhandler,
                                      callback: (args) {
                                        final int rating = args[0];
                                        final evalJsRateClick = StringBuffer();
                                        // Clear checked rating
                                        for (var i = 0; i < 5; i++) {
                                          evalJsRateClick.writeln(
                                            "document.getElementById('star-${i + 1}').classList.remove('checked')",
                                          );
                                        }
                                        for (var i = 0; i < rating; i++) {
                                          evalJsRateClick.writeln(
                                            "document.getElementById('star-${i + 1}').classList.toggle('checked')",
                                          );
                                        }
                                        final request = RateContentRequest()
                                          ..contentType = BrowseType.article
                                          ..id = store!.articleDetailItem!.id
                                          ..rating = rating;
                                        store!.contentRatingStore.rateContent
                                            .executeIf(
                                          request,
                                        )
                                            .then((value) {
                                          store!.getData
                                              .executeIf()
                                              .then((value) {
                                            c
                                                .loadData(
                                                    data: getHtml(
                                              store!.articleDetailItem!,
                                            ))
                                                .then((value) {
                                              Future.delayed(const Duration(
                                                      milliseconds: 750))
                                                  .then((_) {
                                                c.evaluateJavascript(
                                                  source: evalJsRateClick
                                                      .toString(),
                                                );
                                              });
                                            });
                                          });
                                        });
                                      },
                                    );

                                    c.addJavaScriptHandler(
                                      handlerName: relatedContentClickHandler,
                                      callback: (args) {
                                        final String? relatedContentId =
                                            args.first;
                                        final relatedContent = store!
                                            .relatedDetailContentStore
                                            .listRelatedContent
                                            .firstWhereOrNull(
                                          (e) {
                                            return e.id == relatedContentId;
                                          },
                                        );
                                        if (relatedContent != null) {
                                          store!.relatedDetailContentStore
                                              .goToDetail
                                              .executeIf(
                                            relatedContent,
                                          );
                                        }
                                      },
                                    );

                                    store!.registerDispose(() {
                                      c.removeJavaScriptHandler(
                                        handlerName: 'acceptgoals',
                                      );
                                      c.removeJavaScriptHandler(
                                        handlerName: starclickhandler,
                                      );
                                      c.removeJavaScriptHandler(
                                        handlerName: relatedContentClickHandler,
                                      );
                                    });
                                  },
                                );
                              },
                            ),
                            [DataState.loading]: const Center(
                              child: const CircularProgressIndicator(),
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
                      child: StreamBuilder<double>(
                        initialData: 0,
                        stream: appBarOpacity,
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<double> snapshot,
                        ) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.of(context).canvasColorLevel2!,
                                  AppTheme.of(context)
                                      .canvasColorLevel2!
                                      .withOpacity(
                                        snapshot.data! > 1.0
                                            ? 1.0
                                            : snapshot.data! < 0
                                                ? 0
                                                : snapshot.data!,
                                      ),
                                ],
                              ),
                            ),
                            child: AppBar(
                              centerTitle: false,
                              backgroundColor: Colors.transparent,
                              leading: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                ),
                                onPressed: () {
                                  store!.goBack.executeIf();
                                },
                              ),
                              actions: [
                                Observer(
                                  builder: (BuildContext context) {
                                    return TutorialWalkthroughBasic(
                                      selectedTutorialIndex: 0,
                                      store: store!.tutorialWalkthroughStore,
                                      child: Observer(
                                        builder: (context) {
                                          if (appStore!
                                                  .appTheme!.baseAppTheme ==
                                              BaseAppTheme.dark) {
                                            return IconButton(
                                              onPressed: () {
                                                final lightTheme =
                                                    appStore!.themes.firstWhere(
                                                  (element) =>
                                                      element.id == 'light',
                                                );
                                                appStore!.changeTheme
                                                    .executeIf(lightTheme);
                                              },
                                              icon: Image.asset(
                                                'images/ic_bulb_off.png',
                                                color: context.isLight
                                                    ? const Color(0xff0E9DE9)
                                                    : null,
                                              ),
                                            );
                                          }

                                          return IconButton(
                                            onPressed: () {
                                              final lightTheme =
                                                  appStore!.themes.firstWhere(
                                                (element) =>
                                                    element.id == 'dark',
                                              );
                                              appStore!.changeTheme
                                                  .executeIf(lightTheme);
                                            },
                                            icon: Image.asset(
                                                'images/ic_bulb_on.png',
                                                color: context.isLight
                                                    ? const Color(0xff0E9DE9)
                                                    : null),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
