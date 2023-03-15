import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/screens/interest/interest_picker_badge.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';

class AssessmentResultScreen extends HookWidget {
  final AssessmentModel? assessmentModel;
  final bool isLastItem;
  const AssessmentResultScreen({
    Key? key,
    required this.assessmentModel,
    required this.isLastItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const heightCurve = 130.0;

    final items = assessmentModel!.questions ?? [];

    final appServices = useMemoized(() => sl.get<AppServices>());

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heightCurve,
                    child: CustomPaint(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          top: 15,
                          right: 15,
                          bottom: 50,
                        ),
                        child: Text(
                          'Self Assessment Result',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      painter: CurveWidget(
                        color: Theme.of(context).appBarTheme.color,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: heightCurve / 2,
                      ),
                      SizedBox(
                        height: 100,
                        child: InterestPickerBadge(
                          includeText: false,
                          item: TopicItem()
                            ..name = assessmentModel!.title
                            ..color = '#fff',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        assessmentModel!.title ?? '',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _RowTableContainer(
              mainContent: Container(
                color: AppTheme.of(context).canvasColorLevel3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Text(
                  'Key Behaviour',
                ),
              ),
              suffix: Container(
                color: AppTheme.of(context).canvasColorLevel3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  'Score',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item.selectedAnswer == null) {
                    return const SizedBox();
                  }

                  return _RowTableContainer(
                    mainContent: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Text(
                        item.topic ?? item.title ?? '',
                      ),
                    ),
                    suffix: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: item.selectedAnswer!.score! / 4.0,
                            backgroundColor: context.isLight
                                ? const Color(0xffC2CFE0)
                                : Theme.of(context).appBarTheme.color,
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.of(context).selectedColor,
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                item.selectedAnswer!.score.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: context.isLight
                  ? const Color(0xffE7EFF9)
                  : Theme.of(context).appBarTheme.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RowTableContainer(
                    mainContent: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'Total score',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    suffix: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        assessmentModel!.totalScore.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: const SizedBox(),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          bottom: 10,
                        ),
                        child: TextButton(
                          onPressed: () {
                            if (!isLastItem) {
                              if (appServices!.navigatorState!.canPop()) {
                                appServices.navigatorState!.popUntil((route) {
                                  return route.settings.name ==
                                      '/assessment_introduction';
                                });
                              }
                            } else {
                              appServices!.navigatorState!
                                  .pushNamedAndRemoveUntil(
                                '/',
                                (_) => false,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: AppTheme.of(context).selectedColor,
                          ),
                          child: isLastItem
                              ? Text('Ok')
                              : Text('Next Self Assessment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AssessmentResultScreenV2 extends HookWidget {
  final MyAssessmentModelV2? assessmentModel;
  final bool? isLastItem;
  final bool? viewFromProfile;
  const AssessmentResultScreenV2({
    Key? key,
    required this.assessmentModel,
    required this.isLastItem,
    this.viewFromProfile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const heightCurve = 130.0;

    final items = assessmentModel!.keyBehaviorResults!;

    final appServices = useMemoized(() => sl.get<AppServices>());

    final content = Scaffold(
      backgroundColor: const Color(0xffF3F8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Stack(
                children: [
                  AppClipPath(
                    height: 125,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          left: 15,
                          top: 15,
                          right: 15,
                        ),
                        child: Stack(
                          children: [
                            Navigator.of(context).canPop() == true
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () {
                                        if (Navigator.canPop(context)) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Center(
                              child: Text(
                                'Self Assessment Result',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  color: context.isLight ? Colors.white : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 20),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: heightCurve / 2,
                      ),
                      SizedBox(
                        height: 100,
                        child: InterestPickerBadge(
                          includeText: false,
                          item: TopicItem()
                            ..name = assessmentModel!.assessmentTitle ?? ''
                            ..color = assessmentModel!.topicColor ?? ''
                            ..iconUrl = assessmentModel!.iconUrl ?? '',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        assessmentModel!.assessmentTitle ?? '',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _RowTableContainer(
              mainContent: Container(
                color: context.isLight
                    ? const Color(0xffE7EFF9)
                    : AppTheme.of(context).canvasColorLevel3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Text(
                  'Key Behaviour',
                ),
              ),
              suffix: Container(
                color: context.isLight
                    ? const Color(0xffE7EFF9)
                    : AppTheme.of(context).canvasColorLevel3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  'Score',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // if (item.selectedAnswer == null) {
                  //   return const SizedBox();
                  // }

                  return _RowTableContainer(
                    mainContent: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: Text(
                        item.title ?? '',
                      ),
                    ),
                    suffix: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: item.score! / 4.0,
                            backgroundColor: context.isLight
                                ? const Color(0xffC2CFE0)
                                : Theme.of(context).appBarTheme.color,
                            valueColor: AlwaysStoppedAnimation(
                              AppTheme.of(context).selectedColor,
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                item.score.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: context.isLight
                  ? const Color(0xffE7EFF9)
                  : Theme.of(context).appBarTheme.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RowTableContainer(
                    mainContent: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'Total score',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    suffix: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        assessmentModel!.totalScore!.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  viewFromProfile!
                      ? assessmentModel!.assessmentVersion == 1
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  appServices!.navigatorState!.pushNamed(
                                    '/assessment_introduction',
                                    arguments: {
                                      'assessmentId':
                                          assessmentModel!.assessmentId,
                                    },
                                  );
                                },
                                child: Text(
                                  'Retake self assessment',
                                ),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 50,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()
                      : Row(
                          children: [
                            const Expanded(
                              child: const SizedBox(),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                                bottom: 10,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (!isLastItem!) {
                                    if (appServices!.navigatorState!.canPop()) {
                                      appServices.navigatorState!
                                          .popUntil((route) {
                                        return route.settings.name ==
                                            '/assessment_introduction';
                                      });
                                    }
                                  } else {
                                    appServices!.navigatorState!
                                        .pushNamedAndRemoveUntil(
                                      '/',
                                      (_) => false,
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.of(context).selectedColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isLastItem!
                                    ? Text('Ok')
                                    : Text('Next Self Assessment'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );

    FutureOr<bool> _onWillPop() {
      if (viewFromProfile!) {
        if (appServices!.navigatorState!.canPop()) {
          appServices.navigatorState!.pop();
        }
      } else {
        appServices!.navigatorState!.popUntil(
          (v) {
            return v.settings.name == '/user_profile_screen';
          },
        );
      }
      return false;
    }

    return WillPopScope(
      onWillPop: () {
        return _onWillPop() as Future<bool>;
      },
      child: content,
    );
  }
}

class _RowTableContainer extends StatelessWidget {
  final Widget mainContent;
  final Widget suffix;

  const _RowTableContainer({
    Key? key,
    required this.mainContent,
    required this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: mainContent,
        ),
        const SizedBox(
          width: 1,
        ),
        suffix,
      ],
    );
  }
}
