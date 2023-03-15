import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class FontSizes {
  static const double thin = 14;

  static const double regular = 16;

  static const double large = 20;

  static const double cardTitle = 26;
}

class FontSizesWidget extends InheritedWidget {
  final double veryThin = 12;
  final double thin = FontSizes.thin;
  final double regular = FontSizes.regular;
  final double semiLarge = 18;
  final double large = FontSizes.large;
  final double h4 = 22;
  final double cardTitle = FontSizes.cardTitle;

  const FontSizesWidget({
    Key? key,
    required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static FontSizesWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FontSizesWidget>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class AppThemeData {
  var caption = TextStyle();
  var sectionTitle = TextStyle();
  var sectionSubtitle = TextStyle();
  var listItemTitleSettings = TextStyle();
  var listItemSubtitleSettings = TextStyle();

  var filterHeaderColor = const Color(0xffACB6C5);

  Color? canvasColorLevel2;
  Color? canvasColorLevel3;
  var canvasColor4 = const Color(0xff122237);

  Color? okButtonColor;

  Color? selectedColor;

  Color? popupButtonColor;

  Color? disabledColor1;

  GetStartedTheme? getStartedColor;

  final Tuple2<Color, Color>? gradientBgColor;

  AppThemeData({
    TextStyle? caption,
    TextStyle? sectionTitle,
    TextStyle? sectionSubtitle,
    Color? canvasColorLevel2,
    Color? canvasColorLevel3,
    this.getStartedColor,
    this.gradientBgColor,
  }) {
    this.caption = caption ?? this.caption;

    this.sectionTitle = sectionTitle ?? this.sectionTitle;
    this.sectionSubtitle = sectionSubtitle ?? this.sectionSubtitle;
    this.canvasColorLevel2 = canvasColorLevel2 ?? this.canvasColorLevel2;
    this.canvasColorLevel3 = canvasColorLevel3 ?? this.canvasColorLevel3;
  }
}

class AppTheme extends InheritedWidget {
  final AppThemeData appThemeData;
  AppTheme({
    Key? key,
    required this.appThemeData,
    required this.child,
  }) : super(key: key, child: child);

  final Widget child;

  static AppThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheme>()!.appThemeData;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return true;
  }
}

class GetStartedTheme {
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? bgColor;
  final Tuple2<Color, Color>? gradientBgColor;
  final Color? button1;
  final Color? button2;

  GetStartedTheme({
    this.titleColor,
    this.subtitleColor,
    this.bgColor,
    this.gradientBgColor,
    this.button1,
    this.button2,
  });
}
