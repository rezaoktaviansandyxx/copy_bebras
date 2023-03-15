// library spider_chart;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

import 'package:touchable/touchable.dart';

class SpiderChartExtended extends StatelessWidget {
  final List<double> data;
  final double maxValue;
  final List<Color> colors;
  final List<String>? labels;
  final decimalPrecision;
  final Size size;
  final double fallbackHeight;
  final double fallbackWidth;
  final Color? textColor;
  final Color? fillColor;
  final List<String?>? dataIds;
  final Function(String?)? onLabelTap;

  SpiderChartExtended({
    Key? key,
    required this.data,
    required this.colors,
    required this.maxValue,
    this.fillColor,
    this.labels,
    this.size = Size.infinite,
    this.decimalPrecision = 0,
    this.fallbackHeight = 200,
    this.fallbackWidth = 200,
    this.textColor = Colors.black,
    this.onLabelTap,
    this.dataIds,
  })  : assert(data.length == colors.length,
            'Length of data and color lists must be equal'),
        assert(labels != null ? data.length == labels.length : true,
            'Length of data and labels lists must be equal'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: fallbackWidth,
      maxHeight: fallbackHeight,
      child: CanvasTouchDetector(
        gesturesToOverride: [GestureType.onTapDown],
        builder: (context) {
          return CustomPaint(
            size: size,
            painter: SpiderChartExtendedPainter(
              data,
              maxValue,
              colors,
              labels,
              decimalPrecision,
              textColor,
              fillColor,
              context,
              onLabelTap,
              dataIds,
            ),
          );
        },
      ),
    );
  }
}

class SpiderChartExtendedPainter extends CustomPainter {
  final List<double> data;
  final double maxNumber;
  final List<Color> colors;
  final List<String>? labels;
  final decimalPrecision;
  final Color? textColor;
  final Color? fillColor;
  final BuildContext context;
  final Function(String?)? onLabelTap;
  final List<String?>? dataIds;

  final Paint spokes = Paint()..color = Colors.black.withOpacity(0.5);

  final Paint stroke = Paint()
    ..color = Color.fromARGB(255, 50, 50, 50)
    ..style = PaintingStyle.stroke;

  SpiderChartExtendedPainter(
    this.data,
    this.maxNumber,
    this.colors,
    this.labels,
    this.decimalPrecision,
    this.textColor,
    this.fillColor,
    this.context,
    this.onLabelTap,
    this.dataIds,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final myCanvas = TouchyCanvas(context, canvas);
    Offset center = size.center(Offset.zero);

    double angle = (2 * pi) / data.length;

    List<Offset> dataPoints = [];

    for (var i = 0; i < data.length; i++) {
      var scaledRadius = (data[i] / maxNumber) * center.dy;
      var x = scaledRadius * cos(angle * i - pi / 2);
      var y = scaledRadius * sin(angle * i - pi / 2);

      dataPoints.add(Offset(x, y) + center);
    }

    List<Offset> outerPoints = [];

    for (var i = 0; i < data.length; i++) {
      var x = center.dy * cos(angle * i - pi / 2);
      var y = center.dy * sin(angle * i - pi / 2);

      outerPoints.add(Offset(x, y) + center);
    }

    if (this.labels != null) {
      paintLabels(canvas, center, outerPoints, this.labels);
    }
    paintGraphOutline(canvas, center, outerPoints, size);
    paintDataLines(canvas, dataPoints);
    paintDataPoints(myCanvas, dataPoints);
    // paintText(canvas, center, dataPoints, data);
  }

  void paintDataLines(Canvas canvas, List<Offset> points) {
    Path path = Path()..addPolygon(points, true);
    final fill = Paint()
      ..color = fillColor!
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      path,
      fill,
    );

    canvas.drawPath(path, stroke);
  }

  void paintDataPoints(TouchyCanvas canvas, List<Offset> points) {
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        6.75,
        Paint()..color = colors[i],
        onTapUp: (v) {
          if (onLabelTap != null) {
            final label = dataIds![i];
            onLabelTap!(label);
          }
        },
      );
    }
  }

  void paintText(
      Canvas canvas, Offset center, List<Offset> points, List<double> data) {
    var textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < points.length; i++) {
      String s = data[i].toStringAsFixed(decimalPrecision);
      textPainter.text = TextSpan(
          text: s,
          style: TextStyle(
            color: textColor,
          ));
      textPainter.layout();
      if (points[i].dx < center.dx) {
        textPainter.paint(
            canvas, points[i].translate(-(textPainter.size.width + 5.0), 0));
      } else if (points[i].dx > center.dx) {
        textPainter.paint(canvas, points[i].translate(5.0, 0));
      } else if (points[i].dy < center.dy) {
        textPainter.paint(
            canvas, points[i].translate(-(textPainter.size.width / 2), -20));
      } else {
        textPainter.paint(
            canvas, points[i].translate(-(textPainter.size.width / 2), 4));
      }
    }
  }

  void paintGraphOutline(
      Canvas canvas, Offset center, List<Offset> points, Size size) {
    //TODO: this could cause a rendering issue later if the rendering order is ever changed
    //        using the spread operator in 'drawPoints' would fix this, but would require a
    //        dart version bump.
    points.add(points[0]);

    // canvas.drawPoints(PointMode.points, points, spokes);
    canvas.drawCircle(
      center,
      size.height / 2,
      Paint()
        ..color = const Color(0xffADBED5)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      size.height / 2.45,
      Paint()
        ..color = const Color(0xffB6C6DB)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      size.height / 3.2,
      Paint()
        ..color = const Color(0xffC7D7EC)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      size.height / 4.5,
      Paint()
        ..color = const Color(0xffD6E1F0)
        ..style = PaintingStyle.fill,
    );

    for (var i = 0; i < points.length; i++) {
      canvas.drawLine(center, points[i], spokes);
    }
  }

  void paintLabels(
      Canvas canvas, Offset center, List<Offset> points, List<String>? labels) {
    var textPainter = TextPainter(textDirection: TextDirection.ltr);
    var textStyle =
        TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold);

    for (var i = 0; i < points.length; i++) {
      textPainter.text = TextSpan(text: labels![i], style: textStyle);
      textPainter.layout();
      if (points[i].dx < center.dx) {
        textPainter.paint(
            canvas, points[i].translate(-(textPainter.size.width + 5.0), -15));
      } else if (points[i].dx > center.dx) {
        textPainter.paint(canvas, points[i].translate(5.0, -15));
      } else if (points[i].dy < center.dy) {
        textPainter.paint(
            canvas, points[i].translate(-(textPainter.size.width / 2), -35));
      } else {
        textPainter.paint(
            canvas, points[i].translate(-(textPainter.size.width / 2), 20));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
