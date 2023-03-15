import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluxmobileapp/main.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:tuxin_tutorial_overlay/TutorialOverlayUtil.dart';
import 'package:tuxin_tutorial_overlay/WidgetData.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class TutorialWalkthrough extends StatefulWidget {
  final Widget child;
  final Widget tooltipContent;
  final bool showOnInit;
  final TutorialWalkthroughController? controller;
  final Function(TutorialWalkthroughController?)? controllerCreated;
  final TooltipDirection tooltipDirection;

  TutorialWalkthrough({
    Key? key,
    required this.child,
    this.controller,
    this.showOnInit = true,
    required this.tooltipContent,
    this.controllerCreated,
    this.tooltipDirection = TooltipDirection.down,
  }) : super(key: key);

  @override
  _TutorialWalkthroughState createState() => _TutorialWalkthroughState();
}

class _TutorialWalkthroughState extends State<TutorialWalkthrough> {
  final _key = GlobalKey();
  final List<StreamSubscription> d = [];

  TutorialWalkthroughController? _controller;
  TutorialWalkthroughController? get controller => _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TutorialWalkthroughController();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.controllerCreated != null) {
        widget.controllerCreated!(controller);
      }

      final tagName = 'tutorial_${_uuid.v4()}';

      d.add(controller!.stateChanged.listen(
        (event) {
          if (event == true) {
            showOverlayEntry(
              tagName: tagName,
            );
            // this._overlayEntry = this._createOverlayEntry();
            // Overlay.of(context).insert(this._overlayEntry);
          } else {
            hideOverlayEntryIfExists();
          }
        },
      ));

      createTutorialOverlay(
        context: context,
        tagName: tagName,
        bgColor: Colors.black.withOpacity(0.7),
        enableHolesAnimation: false,
        defaultPadding: 10,
        widgetsData: [
          WidgetData(
            key: _key,
            isEnabled: false,
            shape: WidgetShape.RRect,
          ),
        ],
        description: Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(decoration: TextDecoration.none),
        ),
      );

      if (widget.showOnInit == true) {
        controller!.showTutorial();
      }
    });
  }

  @override
  void dispose() {
    for (var item in d) {
      item.cancel();
    }
    d.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return controller!.stateChanged.take(1).last.then((value) {
          final canPop = !value;
          if (!canPop) {
            controller!.hideTutorial();
          }
          return canPop;
        });
      },
      child: StreamBuilder<bool>(
        stream: controller!.stateChanged,
        initialData: widget.showOnInit ?? true,
        builder: (context, snapshot) {
          return SimpleTooltip(
            tooltipTap: () {
              print("Tooltip tap");
            },
            show: snapshot.data!,
            tooltipDirection: widget.tooltipDirection,
            content: widget.tooltipContent,
            borderWidth: 0,
            arrowBaseWidth: 20,
            arrowLength: 10,
            // minWidth: mediaQuery.size.width - 48,
            routeObserver: routeObserver,
            backgroundColor: Colors.white,
            ballonPadding: const EdgeInsets.only(),
            child: Container(
              key: _key,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class TutorialWalkthroughController {
  final _controller = BehaviorSubject<bool>.seeded(false);

  void showTutorial() {
    _controller.add(true);
  }

  void hideTutorial() {
    _controller.add(false);
  }

  Stream<bool> get stateChanged => _controller.stream;
}
