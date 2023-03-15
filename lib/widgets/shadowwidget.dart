import 'package:flutter/material.dart';

class ShadowWidget extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets? padding;

  ShadowWidget({
    required this.child,
    required this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            100,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(0.8),
              blurRadius: 30,
              offset: const Offset(0, 2.5),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
