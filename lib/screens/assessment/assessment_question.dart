import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/components/app_html.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_result_screen.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import './assessment_store.dart';

class AssessmentQuestion extends HookWidget {
  final AssessmentStore? store;

  const AssessmentQuestion({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorWidth = useMemoized(() => 54.0);
    final indicatorController = useScrollController();

    useEffect(
      () {
        final ds = List<Disposable>.empty(growable: true);

        {
          final d = autorun((_) async {
            final index = store!.currentQuestionIndex;
            if (indicatorController.hasClients) {
              final offset = index * (indicatorWidth + 10);
              await indicatorController.animateTo(
                offset,
                curve: Curves.bounceOut,
                duration: const Duration(milliseconds: 250),
              );
            }
          });
          ds.add(DisposableBuilder(disposeFunction: () {
            d.call();
          }));
        }

        {
          final d = store!.alertInteraction.registerHandler((f) async {
            await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(
                      f!,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'),
                      ),
                    ],
                  );
                });
            return null;
          });
          ds.add(DisposableBuilder(disposeFunction: () {
            d.dispose();
          }));
        }

        return () {
          ds.forEach((element) {
            element.dispose();
          });
          ds.clear();
        };
      },
      const [],
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Observer(
            builder: (BuildContext context) {
              return WidgetSelector(
                maintainState: true,
                selectedState: store!.state,
                states: {
                  [DataState.success]: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Stack(
                        children: [
                          AppClipPath(
                            height: 170,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            child: SafeArea(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  AppBar(
                                    centerTitle: true,
                                    backgroundColor: context.isLight
                                        ? Colors.transparent
                                        : null,
                                    iconTheme: IconThemeData(
                                      color: Color(0XFF00ADEE),
                                      // context.isLight ? Colors.white : null,
                                    ),
                                    title: Observer(
                                      builder: (BuildContext context) {
                                        if (store!.currentQuestion == null ||
                                            store!.assessment == null ||
                                            store!.assessment!.questions!
                                                .isEmpty) {
                                          return const SizedBox();
                                        }

                                        return Text(
                                          '${store!.currentQuestionIndex + 1} dari ${store!.assessment?.questions?.length}',
                                          style: TextStyle(
                                            fontSize: FontSizes.large,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0XFF00ADEE),
                                            // context.isLight
                                            //     ? Colors.white
                                            //     : null,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      },
                                    ),
                                    // title: Observer(
                                    //   builder: (BuildContext context) {
                                    //     if (store!.assessment == null ||
                                    //         store!.assessment!.questions!
                                    //             .isEmpty) {
                                    //       return const SizedBox();
                                    //     }

                                    //     return Container(
                                    //       height: 10,
                                    //       child: ListView.builder(
                                    //         itemCount: store!.assessment
                                    //                 ?.questions?.length ??
                                    //             0,
                                    //         scrollDirection: Axis.horizontal,
                                    //         addAutomaticKeepAlives: true,
                                    //         controller: indicatorController,
                                    //         itemBuilder: (
                                    //           BuildContext context,
                                    //           int index,
                                    //         ) {
                                    //           return Observer(
                                    //             builder:
                                    //                 (BuildContext context) {
                                    //               return Container(
                                    //                 margin: const EdgeInsets
                                    //                     .symmetric(
                                    //                   horizontal: 5,
                                    //                 ),
                                    //                 decoration: BoxDecoration(
                                    //                   borderRadius:
                                    //                       BorderRadius.circular(
                                    //                           50),
                                    //                   color: store!.currentQuestionIndex >=
                                    //                           index
                                    //                       ? (context
                                    //                               .isLight
                                    //                           ? const Color(
                                    //                               0xff14C48D)
                                    //                           : Theme.of(
                                    //                                   context)
                                    //                               .accentColor)
                                    //                       : (context
                                    //                               .isLight
                                    //                           ? const Color(
                                    //                               0xffC2CFE0)
                                    //                           : AppTheme.of(
                                    //                                   context)
                                    //                               .canvasColorLevel3),
                                    //                 ),
                                    //                 width: indicatorWidth,
                                    //                 height: 10,
                                    //               );
                                    //             },
                                    //           );
                                    //         },
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Observer(
                                    builder: (BuildContext context) {
                                      if (store!.currentQuestion == null) {
                                        return const SizedBox();
                                      }
                                      return Builder(
                                        builder: (context) {
                                          final checkedImage = store!
                                                  .currentQuestion!.imageUrl ??
                                              "";
                                          final checkedQuestion =
                                              store!.currentQuestion!.title ??
                                                  "";
                                          final splitQuestion =
                                              checkedQuestion.split("|");
                                          final splitImage =
                                              checkedImage.split("|");
                                          final count = [
                                            splitQuestion.length,
                                            splitImage.length
                                          ].reduce(max);
                                          List<Widget> list = [];
                                          for (int i = 0; i < count; i++) {
                                            if (i < splitQuestion.length) {
                                              list.add(
                                                AppHtml(
                                                  splitQuestion[i],
                                                ),
                                              );
                                            }
                                            if (i < splitImage.length) {
                                              list.add(
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                  child: InteractiveViewer(
                                                    minScale: 0.1,
                                                    maxScale: 2.0,
                                                    child: Image.asset(
                                                      'images/soala/${splitImage[i]}',
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              20 /
                                                              100,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                          if (list.length > 1) {
                                            return Column(
                                              children: list,
                                            );
                                          } else {
                                            return AppHtml(
                                              store!.currentQuestion!.topic ??
                                                  store!
                                                      .currentQuestion!.title ??
                                                  '',
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  Observer(
                                    builder: (BuildContext context) {
                                      return ListView.separated(
                                        padding: const EdgeInsets.all(0),
                                        itemCount: store!.currentQuestion
                                                ?.answers?.length ??
                                            0,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          final item = store!
                                              .currentQuestion!.answers![index];

                                          return Observer(
                                            builder: (BuildContext context) {
                                              final selectedAnswer = store!
                                                  .currentQuestion!
                                                  .selectedAnswer;
                                              final isSelected =
                                                  selectedAnswer?.id == item.id;

                                              return InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  15,
                                                ),
                                                onTap: () {
                                                  store!.tapAnswer
                                                      .executeIf(item);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? (context.isLight
                                                            ? const Color(
                                                                0xffD1F3FF)
                                                            : Theme.of(context)
                                                                .accentColor)
                                                        : (context.isLight
                                                            ? const Color(
                                                                0xffF3F8FF)
                                                            : AppTheme.of(
                                                                    context)
                                                                .canvasColorLevel3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      15,
                                                    ),
                                                    border: context.isLight
                                                        ? Border.all(
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xff0E9DE9)
                                                                : const Color(
                                                                    0xffC2CFE0),
                                                          )
                                                        : null,
                                                  ),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Positioned(
                                                        top: 0,
                                                        bottom: 0,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: SizedBox(
                                                            height: 30,
                                                            child:
                                                                IgnorePointer(
                                                              child: Radio<
                                                                  String?>(
                                                                activeColor: context
                                                                        .isDark
                                                                    ? Colors
                                                                        .white
                                                                    : const Color(
                                                                        0xff0E9DE9),
                                                                groupValue:
                                                                    item.id,
                                                                value:
                                                                    isSelected ==
                                                                            true
                                                                        ? item
                                                                            .id
                                                                        : '',
                                                                onChanged:
                                                                    (String?
                                                                        value) {},
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        bottom: 0,
                                                        left: 50,
                                                        child: Container(
                                                          width: 1,
                                                          height:
                                                              double.infinity,
                                                          color: context.isDark
                                                              ? AppTheme.of(
                                                                      context)
                                                                  .canvasColorLevel2
                                                              : isSelected
                                                                  ? const Color(
                                                                      0xff0E9DE9,
                                                                    )
                                                                  : const Color(
                                                                      0xffC2CFE0,
                                                                    ),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 64,
                                                            top: 15,
                                                            bottom: 15,
                                                            right: 0,
                                                          ),
                                                          child: item.imageUrl ==
                                                                      null ||
                                                                  item.imageUrl!
                                                                      .isEmpty
                                                              ? AppHtml(
                                                                  item.title ??
                                                                      '',
                                                                  color: context
                                                                          .isLight
                                                                      ? (isSelected
                                                                          ? const Color(
                                                                              0xff0E9DE9,
                                                                            )
                                                                          : Colors
                                                                              .black87)
                                                                      : null,
                                                                )
                                                              : Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Image
                                                                      .asset(
                                                                    'images/soala/${item.imageUrl}',
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Container(),
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        20 /
                                                                        100,
                                                                  ),
                                                                ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const SizedBox(
                                            height: 15,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        color: Theme.of(context).appBarTheme.color,
                        child: SafeArea(
                          top: false,
                          left: false,
                          right: false,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Observer(
                                    builder: (BuildContext context) {
                                      if (store!.currentQuestionIndex == 0) {
                                        return const SizedBox();
                                      }

                                      return TextButton(
                                        onPressed: () {
                                          store!.currentQuestionIndex--;
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            side: BorderSide.none,
                                          ),
                                          backgroundColor: AppTheme.of(context)
                                              .canvasColorLevel3,
                                        ),
                                        child: Text(
                                          'Prev',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                FontSizesWidget.of(context)!
                                                    .regular,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Observer(
                                    builder: (BuildContext context) {
                                      if (store!.assessment == null ||
                                          store!.assessment!.questions ==
                                              null ||
                                          store!.currentQuestion == null) {
                                        return const SizedBox();
                                      }

                                      final isLastQuestion = store!
                                              .currentQuestionIndex ==
                                          store!.assessment!.questions!.length -
                                              1;
                                      final notAnswered = store!
                                              .currentQuestion!
                                              .selectedAnswer ==
                                          null;

                                      if (store!.assessment == null ||
                                          notAnswered == true) {
                                        return const SizedBox();
                                      }

                                      return TextButton(
                                        onPressed: () async {
                                          if (isLastQuestion) {
                                            final sure = await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Confirmation'),
                                                    content: Text(
                                                      'You assessment will be submitted',
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                        child: Text('Submit'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                            if (sure == true) {
                                              Get.back();
                                              // store!.submitAssessment
                                              //     .executeIf();
                                            }
                                          } else {
                                            store!.currentQuestionIndex++;
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            side: BorderSide.none,
                                          ),
                                          backgroundColor: context.isLight
                                              ? const Color(0xff0E9DE9)
                                              : const Color(0xff5AD57F),
                                        ),
                                        child: Text(
                                          isLastQuestion ? 'Submit' : 'Next',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                FontSizesWidget.of(context)!
                                                    .regular,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  [DataState.loading]: Center(
                    child: CircularProgressIndicator(),
                  ),
                  [DataState.error]: ErrorDataWidget(
                    text: store!.state.message ?? '',
                    onReload: () {
                      store!.getAssessment.executeIf();
                    },
                  ),
                },
              );
            },
          ),
          Observer(
            builder: (BuildContext context) {
              if (store!.submitState != DataState.loading) {
                return const SizedBox();
              }

              return Container(
                color: Theme.of(context).canvasColor,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
