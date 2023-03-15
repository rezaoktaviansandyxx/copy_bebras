library tooltip;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import 'types.dart';
import 'dart:math' show pi;

part 'ballon_transition.dart';
part 'balloon.dart';
part 'balloon_positioner.dart';

class SimpleTooltip extends StatefulWidget {
  /// The [child] which the tooltip will target to
  final Widget child;

  /// Sets the tooltip direction
  /// defaults to [TooltipDirection.up]
  final TooltipDirection tooltipDirection;

  /// Defines the content that its placed inside the tooltip ballon
  final Widget content;

  /// If true, it will display the tool , if false it will hide it
  final bool show;

  final Function? onClose;

  /// Sets the content padding
  /// defautls to: `const EdgeInsets.symmetric(horizontal: 20, vertical: 16),`
  final EdgeInsets ballonPadding;

  /// sets the duration of the tooltip entrance animation
  /// defaults to [460] milliseconds
  final Duration animationDuration;

  /// [top], [right], [bottom], [left] position the Tooltip absolute relative to the whole screen
  double? top, right, bottom, left;

  /// [minWidth], [minHeight], [maxWidth], [maxHeight] optional size constraints.
  /// If a constraint is not set the size will ajust to the content
  double? minWidth, minHeight, maxWidth, maxHeight;

  ///
  /// The distance of the tip of the arrow's tip to the center of the target
  final double arrowTipDistance;

  ///
  /// The length of the Arrow
  final double arrowLength;

  ///
  /// the stroke width of the border
  final double borderWidth;

  ///
  /// The minium padding from the Tooltip to the screen limits
  final double minimumOutSidePadding;

  ///
  /// The corder radii of the border
  final double borderRadius;

  ///
  /// The width of the arrow at its base
  final double arrowBaseWidth;

  ///
  /// The color of the border
  final Color borderColor;

  ///
  /// The color of the border
  final Color backgroundColor;

  ///
  /// Set a custom list of [BoxShadow]
  /// defaults to `const BoxShadow(color: const Color(0x45222222), blurRadius: 8, spreadRadius: 2),`
  final List<BoxShadow> customShadows;

  ///
  /// Set a handler for listening to a `tap` event on the tooltip (This is the recommended way to put your logic for dismissing the tooltip)
  final Function()? tooltipTap;

  ///
  /// If you want to automatically dismiss the tooltip whenever a user taps on it, set this flag to [true]
  /// For more control on when to dismiss the tooltip please rely on the [show] property and [tooltipTap] handler
  /// defaults to [false]
  final bool hideOnTooltipTap;

  ///
  /// Pass a `RouteObserver` so that the widget will listen for route transition and will hide tooltip when
  /// the widget's route is not active
  final RouteObserver<PageRoute>? routeObserver;

  final EdgeInsets? margin;

  SimpleTooltip({
    Key? key,
    required this.child,
    this.tooltipDirection = TooltipDirection.up,
    required this.content,
    required this.show,
    this.onClose,
    this.ballonPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.maxWidth,
    this.minWidth,
    this.maxHeight,
    this.minHeight,
    this.arrowTipDistance = 6,
    this.arrowLength = 20,
    this.minimumOutSidePadding = 20.0,
    this.arrowBaseWidth = 20.0,
    this.borderRadius = 10,
    this.borderWidth = 2.0,
    this.borderColor = const Color(0xFF50FFFF),
    this.animationDuration = const Duration(milliseconds: 325),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.customShadows = const [
      const BoxShadow(
          color: const Color(0x45222222), blurRadius: 8, spreadRadius: 2),
    ],
    this.tooltipTap,
    this.hideOnTooltipTap = false,
    this.routeObserver,
    this.margin,
  })  : assert(show != null),
        super(key: key);

  @override
  SimpleTooltipState createState() => SimpleTooltipState();
}

class SimpleTooltipState extends State<SimpleTooltip> with RouteAware {
  bool _displaying = false;

  final LayerLink layerLink = LayerLink();

  bool get shouldShowTooltip =>
      widget.show && !_isBeingObfuscated && _routeIsShowing;

  // To avoid rebuild state of widget for each rebuild
  GlobalKey _transitionKey = GlobalKey();
  GlobalKey _positionerKey = GlobalKey();

  bool _routeIsShowing = true;

  bool _isBeingObfuscated = false;

  late OverlayEntry _overlayEntry;

  List<ObfuscateTooltipItemState> _obfuscateItems = [];
  _BallonSize? _ballonSize;

  addObfuscateItem(ObfuscateTooltipItemState item) {
    _obfuscateItems.add(item);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doCheckForObfuscation();
      doShowOrHide();
    });
  }

  removeObsfuscateItem(ObfuscateTooltipItemState item) {
    _obfuscateItems.remove(item);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doCheckForObfuscation();
      doShowOrHide();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // widget.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    _removeTooltip();
    widget.routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shouldShowTooltip) {
        _showTooltip();
      }
      widget.routeObserver?.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    });
  }

  @override
  void didUpdateWidget(SimpleTooltip oldWidget) {
    if (oldWidget.routeObserver != widget.routeObserver) {
      oldWidget.routeObserver?.unsubscribe(this);
      widget.routeObserver?.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (oldWidget.tooltipDirection != widget.tooltipDirection ||
          (oldWidget.show != widget.show && widget.show)) {
        _transitionKey = GlobalKey();
      }
      if (!_routeIsShowing || _isBeingObfuscated) {
        return;
      }
      doShowOrHide();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: widget.child,
    );
  }

  void _showTooltip({
    bool buildHidding = false,
  }) {
    if (_displaying || !mounted) {
      return;
    }
    _overlayEntry = _buildOverlay(
      buildHidding: buildHidding,
    );
    Overlay.of(context, rootOverlay: false)!.insert(_overlayEntry);
    _displaying = true;
  }

  void _removeTooltip() {
    if (!_displaying) {
      return;
    }
    this._overlayEntry.remove();
    _displaying = false;
  }

  doShowOrHide() {
    final wasDisplaying = _displaying;
    _removeTooltip();
    if (shouldShowTooltip) {
      _showTooltip();
    } else if (wasDisplaying) {
      _showTooltip(buildHidding: true);
    }
  }

  doCheckForObfuscation() {
    if (_ballonSize == null) return;
    for (var obfuscateItem in _obfuscateItems) {
      final d = obfuscateItem.getPositionAndSize()!;
      // final obfuscateItemSize = d.size;
      // final obfuscateItemPosition = d.globalPosition;
      // final ballonSize = _ballonSize.size;
      // final balloPosition = _ballonSize.globalPosition;
      final Rect obfuscateItemRect = d.globalPosition & d.size;
      final Rect ballonRect = _ballonSize!.globalPosition & _ballonSize!.size;
      final bool overlaps = ballonRect.overlaps(obfuscateItemRect);
      if (overlaps) {
        _isBeingObfuscated = true;
        // no need to keep searching
        return;
      }
    }
    _isBeingObfuscated = false;
  }

  final _contentKey = GlobalKey();

  OverlayEntry _buildOverlay({
    bool buildHidding = false,
  }) {
    final RenderBox _renderBox = context.findRenderObject() as RenderBox;
    var size = _renderBox.size;
    var offset = _renderBox.localToGlobal(Offset.zero);

    final tipDx =
        offset.dx <= 20 ? size.width / 2 - widget.arrowBaseWidth : offset.dx;

    var topTip = 0.0;
    var topBallon = 0.0;
    if (widget.tooltipDirection == TooltipDirection.down) {
      topTip = offset.dy + size.height;
      topBallon = topTip + widget.arrowLength - 1;
      if (topBallon < 0) {
        topBallon = 0;
      }
    } else if (widget.tooltipDirection == TooltipDirection.up) {
      final heightContent = _contentKey.currentContext?.size?.height ?? 0.0;
      final paddingTop = 38;
      topTip = offset.dy + widget.arrowLength + 2 - paddingTop;
      topBallon = offset.dy - heightContent - widget.arrowLength - paddingTop;
    }

    final customPaintTriangle = CustomPaint(
      painter: TrianglePainter(
        strokeColor: Colors.white,
        paintingStyle: PaintingStyle.fill,
      ),
    );

    return OverlayEntry(
      builder: (overlayContext) {
        return Container(
          margin: widget.margin ??
              const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
          child: _BalloonTransition(
            key: _transitionKey,
            duration: widget.animationDuration,
            tooltipDirection: widget.tooltipDirection,
            hide: buildHidding,
            animationEnd: (status) {
              if (status == AnimationStatus.dismissed) {
                _removeTooltip();
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  top: topTip,
                  left: tipDx,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: widget.tooltipDirection == TooltipDirection.up
                          ? Transform.rotate(
                              angle: pi,
                              child: customPaintTriangle,
                            )
                          : customPaintTriangle,
                      height: widget.arrowLength,
                      width: widget.arrowBaseWidth,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: topBallon,
                  ),
                  child: _Ballon(
                    content: widget.tooltipDirection == TooltipDirection.up
                        ? Container(
                            key: _contentKey,
                            child: widget.content,
                          )
                        : widget.content,
                    borderRadius: widget.borderRadius,
                    arrowBaseWidth: widget.arrowBaseWidth,
                    // arrowLength: widget.arrowLength,
                    arrowLength: 0,
                    arrowTipDistance: widget.arrowTipDistance,
                    ballonPadding: widget.ballonPadding,
                    borderColor: widget.borderColor,
                    borderWidth: widget.borderWidth,
                    tooltipDirection: widget.tooltipDirection,
                    backgroundColor: widget.backgroundColor,
                    shadows: widget.customShadows,
                    onTap: () {
                      if (widget.hideOnTooltipTap) {
                        _removeTooltip();
                        _showTooltip(buildHidding: true);
                      }
                      if (widget.tooltipTap != null) {
                        widget.tooltipTap!();
                      }
                    },
                    onSizeChange: (ballonSize) {
                      if (!mounted) return;
                      _ballonSize = ballonSize;
                      doCheckForObfuscation();
                      doShowOrHide();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // RenderBox renderBox = context.findRenderObject();
    // var size = renderBox.size;
    // var offset = renderBox.localToGlobal(Offset.zero);

    // final tipDx = offset.dx <= 0
    //     ? size.width / 2 - widget.arrowBaseWidth - (widget.arrowBaseWidth / 2)
    //     : offset.dx;

    // return OverlayEntry(
    //   builder: (overlayContext) {
    //     return Container(
    //       margin: widget.margin ??
    //           const EdgeInsets.symmetric(
    //             horizontal: 15,
    //             vertical: 5,
    //           ),
    //       child: _BalloonTransition(
    //         key: _transitionKey,
    //         duration: widget.animationDuration,
    //         tooltipDirection: widget.tooltipDirection,
    //         hide: buildHidding,
    //         animationEnd: (status) {
    //           if (status == AnimationStatus.dismissed) {
    //             _removeTooltip();
    //           }
    //         },
    //         child: Stack(
    //           children: [
    //             Positioned.fill(
    //               top: offset.dy + size.height,
    //               left: tipDx,
    //               child: Align(
    //                 alignment: Alignment.topLeft,
    //                 child: Container(
    //                   child: CustomPaint(
    //                     painter: TrianglePainter(
    //                       strokeColor: Colors.white,
    //                       paintingStyle: PaintingStyle.fill,
    //                     ),
    //                   ),
    //                   height: widget.arrowLength,
    //                   width: widget.arrowBaseWidth,
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(
    //                 top: offset.dy + size.height + widget.arrowLength - 1,
    //               ),
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Container(
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(10),
    //                       child: widget.content,
    //                     ),
    //                   )

    //                   // child: _Ballon(
    //                   //   content: widget.content,
    //                   //   borderRadius: widget.borderRadius,
    //                   //   arrowBaseWidth: widget.arrowBaseWidth,
    //                   //   arrowLength: widget.arrowLength,
    //                   //   arrowTipDistance: widget.arrowTipDistance,
    //                   //   ballonPadding: widget.ballonPadding,
    //                   //   borderColor: widget.borderColor,
    //                   //   borderWidth: widget.borderWidth,
    //                   //   tooltipDirection: widget.tooltipDirection,
    //                   //   backgroundColor: widget.backgroundColor,
    //                   //   shadows: widget.customShadows,
    //                   //   onTap: () {
    //                   //     if (widget.hideOnTooltipTap) {
    //                   //       _removeTooltip();
    //                   //       _showTooltip(buildHidding: true);
    //                   //     }
    //                   //     if (widget.tooltipTap != null) {
    //                   //       widget.tooltipTap();
    //                   //     }
    //                   //   },
    //                   //   onSizeChange: (ballonSize) {
    //                   //     if (!mounted) return;
    //                   //     _ballonSize = ballonSize;
    //                   //     doCheckForObfuscation();
    //                   //     doShowOrHide();
    //                   //   },
    //                   // ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  @override
  void didPush() {
    _routeIsShowing = true;
    // Route was pushed onto navigator and is now topmost route.
    if (shouldShowTooltip) {
      _removeTooltip();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (!mounted) return;
        _showTooltip();
      });
    }
  }

  @override
  void didPushNext() {
    _routeIsShowing = false;
    _removeTooltip();
  }

  @override
  void didPopNext() async {
    _routeIsShowing = true;
    if (shouldShowTooltip) {
      // Covering route was popped off the navigator.
      _removeTooltip();
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) _showTooltip();
    }
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
