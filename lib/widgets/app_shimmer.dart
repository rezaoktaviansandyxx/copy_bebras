import 'package:flutter/material.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    required this.child,
    this.baseColor,
    this.highlightColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightShimmer = Colors.grey.withOpacity(0.25);
    return Shimmer.fromColors(
      baseColor: context.isDark
          ? baseColor ?? Theme.of(context).inputDecorationTheme.fillColor!
          : lightShimmer,
      highlightColor: context.isDark
          ? highlightColor ??
              Theme.of(context).inputDecorationTheme.fillColor!.withOpacity(0.5)
          : lightShimmer.withOpacity(0.5),
      period: const Duration(
        milliseconds: 1000,
      ),
      child: child,
    );
  }
}
