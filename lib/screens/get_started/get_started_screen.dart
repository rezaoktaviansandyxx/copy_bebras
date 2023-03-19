import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/screens/get_started/get_started_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../appsettings.dart';

class GetStartedScreen extends StatefulWidget {
  GetStartedScreen({Key? key}) : super(key: key);

  @override
  _GetStartedScreenState createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final appServices = sl.get<AppServices>();
  final localization = sl.get<ILocalizationService>();

  final store = GetStartedStore();
  final pageController = PageController();
  final List<StreamSubscription> d = [];

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      d.add(MobxUtils.toStream(() => store.currentPageIndex).listen((event) {
        pageController.jumpToPage(store.currentPageIndex);
      }, onError: (e) {
        logger.e(e);
      }));
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        // decoration: AppTheme.of(context).getStartedColor?.gradientBgColor !=
        //         null
        //     ? BoxDecoration(
        //         gradient: LinearGradient(
        //         transform: GradientRotation(
        //           360,
        //         ),
        //         colors: [
        //           AppTheme.of(context).getStartedColor!.gradientBgColor!.item1,
        //           AppTheme.of(context).getStartedColor!.gradientBgColor!.item2,
        //         ],
        //       ))
        //     : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Observer(
                builder: (context) {
                  // ignore: unused_local_variable
                  final length = store.pages.length;
                  return PageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: store.pages.map((e) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ClipPath(
                              child: Container(
                                color: Color(0XFF00ADEE).withOpacity(0.25),
                                // AppTheme.of(context).canvasColorLevel2,
                                padding: const EdgeInsets.only(
                                  bottom: 72,
                                  left: 15,
                                  right: 15,
                                  top: 38,
                                ),
                                child: SafeArea(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        alignment: Alignment.topCenter,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'images/logo_bebras.png',
                                              height: 72,
                                            ),
                                            // Text(
                                            //   'Anugra',
                                            //   style: TextStyle(
                                            //     color: const Color(0xff0F9EEA),
                                            //     fontFamily: 'Quicksand',
                                            //     fontWeight: FontWeight.bold,
                                            //     fontSize: 38,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              clipper: CurveClipper(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    e.title,
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 33,
                                      color: Colors.black,
                                      // AppTheme.of(context)
                                      //     .getStartedColor
                                      //     ?.titleColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    e.description,
                                    style: TextStyle(
                                      fontSize: FontSizesWidget.of(context)!
                                          .semiLarge,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      // AppTheme.of(context)
                                      //         .getStartedColor
                                      //         ?.subtitleColor ??
                                      //     AppTheme.of(context).sectionTitle.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    e.subtitle,
                                    style: TextStyle(
                                      fontSize:
                                          FontSizesWidget.of(context)!.regular,
                                      color: Colors.black,
                                      // AppTheme.of(context)
                                      //         .getStartedColor
                                      //         ?.subtitleColor ??
                                      //     AppTheme.of(context).sectionTitle.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Image.asset(
                                      e.imagePath,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              35 /
                                              100,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SmoothPageIndicator(
                controller: pageController,
                count: store.pages.length,
                effect: SlideEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Theme.of(context).accentColor,
                ),
                // effect: WormEffect(),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                child: Column(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 1,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      child: Observer(
                        builder: (BuildContext context) {
                          return Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    store.currentPageIndex != 0
                                        ? TextButton.icon(
                                            onPressed: () {
                                              store.prev.executeIf();
                                            },
                                            icon: Icon(
                                              Icons.arrow_back,
                                              color: AppTheme.of(context)
                                                  .getStartedColor
                                                  ?.button2,
                                            ),
                                            label: Text(
                                              'Kembali',
                                              style: AppTheme.of(context)
                                                          .getStartedColor
                                                          ?.button2 !=
                                                      null
                                                  ? TextStyle(
                                                      color:
                                                          AppTheme.of(context)
                                                              .getStartedColor
                                                              ?.button2,
                                                    )
                                                  : null,
                                            ),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                              if (store.isLastPageIndex != true)
                                TextButton(
                                  onPressed: () {
                                    store.skip.executeIf();
                                  },
                                  child: Text(
                                    'Lewati',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600
                                        // color: AppTheme.of(context)
                                        //         .getStartedColor
                                        //         ?.button1 ??
                                        //     Theme.of(context).accentColor,
                                        ),
                                  ),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    store.isLastPageIndex
                                        ? TextButton(
                                            onPressed: () {
                                              Get.toNamed('/login',
                                                  arguments: {'pageIndex': 0});
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Text(
                                                'Masuk',
                                                style: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? TextStyle(
                                                        color: Colors.white
                                                        // AppTheme.of(context)
                                                        //     .getStartedColor
                                                        //     ?.subtitleColor,
                                                        )
                                                    : null,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: Colors.blue
                                                // Theme.of(context)
                                                //             .brightness ==
                                                //         Brightness.dark
                                                //     ? Theme.of(context)
                                                //         .accentColor
                                                //     : Colors.white,
                                                ),
                                          )
                                        : TextButton(
                                            onPressed: () {
                                              store.next.executeIf();
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Lanjut',
                                                  style: AppTheme.of(context)
                                                              .getStartedColor
                                                              ?.button2 !=
                                                          null
                                                      ? TextStyle(
                                                          color: AppTheme.of(
                                                                  context)
                                                              .getStartedColor
                                                              ?.button2,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: AppTheme.of(context)
                                                      .getStartedColor
                                                      ?.button2,
                                                ),
                                              ],
                                            ),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     appServices.navigatorState
                    //         .pushNamed('/login', arguments: {
                    //       'pageIndex': 0,
                    //     });
                    //   },
                    //   child: RichText(
                    //     text: TextSpan(children: [
                    //       TextSpan(
                    //         text: localization.getByKey(
                    //           'get_started.button.question.sub1',
                    //         ),
                    //       ),
                    //       TextSpan(
                    //         text: ' ' +
                    //             localization.getByKey(
                    //               'get_started.button.question.sub2',
                    //             ),
                    //         style: TextStyle(
                    //           color: Theme.of(context).accentColor,
                    //         ),
                    //       ),
                    //     ]),
                    //   ),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
