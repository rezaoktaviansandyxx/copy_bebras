import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_chart_spider_popup.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_result_screen.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/spider_chart_extended.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'assessment_chart_store.dart';

class AssessmentChartScreen extends HookWidget {
  const AssessmentChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AssessmentChartStore>(
      context,
      listen: false,
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        store.dataRefresher.add(null);
      });
      return () {};
    }, const []);

    return Scaffold(
      body: Observer(
        builder: (BuildContext context) {
          return WidgetSelector(
            maintainState: true,
            selectedState: store.state,
            states: {
              [DataState.success]: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomPaint(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Self Assessment Result',
                              style: TextStyle(
                                fontSize: FontSizes.large,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    painter: CurveWidget(
                      color: Theme.of(context).appBarTheme.color,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Observer(
                            builder: (BuildContext context) {
                              return AssessmentChart(
                                items: store.items,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              [DataState.loading]: Center(
                child: CircularProgressIndicator(),
              ),
              [DataState.error]: ErrorDataWidget(
                text: store.state.message ?? '',
                onReload: () {
                  store.getData.executeIf();
                },
              ),
            },
          );
        },
      ),
    );
  }
}

class AssessmentChart extends HookWidget {
  // final List<MyAssessmentModel> items;
  final List<MyAssessmentModelV2> items;
  final TutorialWalkthroughStore? tutorialWalkthroughStore;

  const AssessmentChart({
    Key? key,
    required this.items,
    this.tutorialWalkthroughStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appServices = useMemoized(() => sl.get<AppServices>());
    const double maxPercentage = 100.0;
    final scoresInPercentage = items.map((e) {
      final maxScore = e.keyBehaviorResults!.length * 4;
      final score = e.keyBehaviorResults!
          .map((e) => e.score ?? 0.0)
          .fold<double>(0.0, (a, b) => a + b);
      final scoreInPercentage = (score / maxScore) * maxPercentage;
      return scoreInPercentage;
    }).toList();

    final spiderChart = SpiderChartExtended(
      textColor: Theme.of(context).textTheme.bodyText1!.color,
      fillColor: context.isLight
          ? const Color(0xffADBED5)
          : Theme.of(context).accentColor.withOpacity(0.6),
      data: scoresInPercentage,
      maxValue: maxPercentage,
      colors: items
          .map((f) => (() {
                try {
                  return f.topicColor != null
                      ? hexToColor(f.topicColor!)
                      : Theme.of(context).accentColor;
                } catch (error) {
                  return Theme.of(context).accentColor;
                }
              })())
          .toList(),
      dataIds: items.map((e) => e.topicName).toList(),
      onLabelTap: (v) {
        final i = items.firstWhereOrNull((element) => element.topicName == v);
        if (i != null) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: AssessmentChartSpiderPopup(
                  topicItem: TopicItem()
                    ..name = i.topicName
                    ..color = i.topicColor
                    ..iconUrl = i.iconUrl ?? '',
                ),
              );
            },
          );
        }
      },
    );

    final chartList = ListView.separated(
      itemCount: scoresInPercentage.length,
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 15,
        top: 15,
      ),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 15);
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        final color = (() {
          try {
            return item.topicColor != null
                ? hexToColor(item.topicColor!)
                : Theme.of(context).accentColor;
          } catch (error) {
            return Theme.of(context).accentColor;
          }
        })();

        final scoreInPercentage = scoresInPercentage[index];

        return GestureDetector(
          onTap: () {
            final isLastItem = index == items.length - 1;

            appServices!.navigatorState!.pushNamed(
              '/assessment_chart_tap_item_result',
              arguments: Map.from(
                {
                  'isLastItem': isLastItem,
                  'assessmentModel': item,
                  'viewFromProfile': true,
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: context.isLight
                      ? const Color(0xffE7EFF9)
                      : AppTheme.of(context).canvasColorLevel3,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.isLight
                              ? const Color(0xffE7EFF9)
                              : AppTheme.of(context).canvasColorLevel3,
                        ),
                        height: 58,
                        width: 58,
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                          child: Image.network(item.iconUrl ?? ''),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              item.assessmentTitle ?? '',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w500,
                                fontSize: FontSizes.regular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: context.isLight
                      ? const Color(0xffCEDCEE)
                      : AppTheme.of(context)
                          .canvasColorLevel3!
                          .withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${scoreInPercentage.toStringAsFixed(0)} ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Total Score',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Click for details',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: scoreInPercentage / maxPercentage,
                          backgroundColor:
                              AppTheme.of(context).canvasColorLevel2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.width / 1.35,
          child: tutorialWalkthroughStore == null
              ? spiderChart
              : TutorialWalkthroughBasic(
                  selectedTutorialIndex: 0,
                  store: tutorialWalkthroughStore,
                  child: spiderChart,
                  tooltipDirection: TooltipDirection.up,
                ),
        ),
        tutorialWalkthroughStore == null
            ? chartList
            : TutorialWalkthroughBasic(
                selectedTutorialIndex: 1,
                store: tutorialWalkthroughStore,
                child: chartList,
                tooltipDirection: TooltipDirection.up,
              ),
      ],
    );
  }
}
