import 'package:flutter/material.dart';
import 'package:fluxmobileapp/styles/styles.dart';

class CurveWidget extends CustomPainter {
  final Color? color;
  const CurveWidget({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = createCurvePath(size);
    canvas.drawPath(
      path,
      Paint()..color = color!,
    );
  }

  @override
  bool shouldRepaint(CurveWidget oldDelegate) {
    return oldDelegate.color != color;
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return createCurvePath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

Path createCurvePath(Size size) {
  final path = Path();
  path.lineTo(0.0, size.height - 40);

  var firstControlPoint = Offset(size.width / 2, size.height);
  var firstEndPoint = Offset(size.width, size.height - 40);
  path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy);

  path.lineTo(size.width, 0.0);
  path.close();
  return path;
}

class AppClipPath extends StatelessWidget {
  final double? height;
  const AppClipPath({
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurveClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0XFF00ADEE).withOpacity(0.25),
          // gradient: LinearGradient(
          //   transform: GradientRotation(
          //     360,
          //   ),
          //   colors: [
          //     AppTheme.of(context).gradientBgColor!.item1,
          //     AppTheme.of(context).gradientBgColor!.item2,
          //   ],
          // ),
        ),
        height: height ?? 265,
      ),
    );
  }
}
