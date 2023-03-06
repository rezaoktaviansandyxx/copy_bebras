import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class TutorialWalkthroughBasicData {
  late String title;
  late String description;
  late String status;
}

class TutorialWalkthroughBasic extends StatefulWidget {
  final Widget child;
  final TutorialWalkthroughStore? store;
  final int selectedTutorialIndex;
  final TooltipDirection tooltipDirection;

  const TutorialWalkthroughBasic({
    Key? key,
    required this.child,
    required this.store,
    required this.selectedTutorialIndex,
    this.tooltipDirection = TooltipDirection.down,
  }) : super(key: key);

  @override
  _TutorialWalkthroughBasicState createState() =>
      _TutorialWalkthroughBasicState();
}

class _TutorialWalkthroughBasicState extends State<TutorialWalkthroughBasic> {
  late TutorialWalkthroughController controller;

  final List<StreamSubscription> d = [];

  bool get showTutorial =>
      widget.store!.currentTutorialIndex.value == widget.selectedTutorialIndex;

  TutorialWalkthroughBasicData get data =>
      widget.store!.tutorials[widget.selectedTutorialIndex];

  bool get isFirst => widget.selectedTutorialIndex == 0;

  bool get isLast =>
      widget.selectedTutorialIndex == widget.store!.tutorials.length - 1;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      d.add(MobxUtils.toStream(() => widget.store!.currentTutorialIndex.value)
          .listen((event) {
        final i = widget.store!.currentTutorialIndex.value;
        if (i == widget.selectedTutorialIndex) {
          controller.showTutorial();
        } else {
          controller.hideTutorial();
        }
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return TutorialWalkthrough(
      showOnInit: false,
      controllerCreated: (c) {
        if (c == null) {
          return;
        }
        controller = c;

        if (showTutorial == true) {
          controller.showTutorial();
        }
      },
      tooltipDirection: widget.tooltipDirection ?? TooltipDirection.down,
      tooltipContent: Material(
        textStyle: TextStyle(
          color: Color(0xff354c6b),
        ),
        borderOnForeground: false,
        type: MaterialType.transparency,
        child: Theme(
          data: ThemeData(
            buttonTheme: ButtonThemeData(
              minWidth: 32,
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
            ),
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.description,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Color(
                                  0xff354C6B,
                                ),
                              ),
                            ),
                            onPressed: () {
                              widget.store!.skipTutorial.executeIf();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Text(
                        data.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isFirst
                                ? const SizedBox()
                                : TextButton(
                                    child: Text(
                                      'Prev',
                                      style: TextStyle(
                                        color: Color(
                                          0xff354C6B,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      widget.store!.prevTutorial.executeIf();
                                    },
                                  ),
                            TextButton(
                              child: Text(
                                isLast == true ? 'End' : 'Next',
                                style: TextStyle(
                                  color: Color(
                                    isLast == true ? 0xffFF5064 : 0xff354C6B,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                widget.store!.nextTutorial.executeIf();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
