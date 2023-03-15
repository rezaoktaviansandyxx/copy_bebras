import 'package:flutter/widgets.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';

int getPageFromOffset(int limit, int offset) {
  final page = ((limit + offset) / limit).ceil();
  return page;
}

// https://stackoverflow.com/a/50382196/7855627
Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

String getTextByReminderType(ReminderTypeEnum type) {
  String text;
  if (type == ReminderTypeEnum.daily) {
    text = 'Daily';
  } else if (type == ReminderTypeEnum.montly) {
    text = 'Monthly (Same as due date)';
  } else if (type == ReminderTypeEnum.none) {
    text = 'None';
  } else if (type == ReminderTypeEnum.once) {
    text = 'Once';
  } else if (type == ReminderTypeEnum.weekly) {
    text = 'Weekly (Same as due date)';
  } else {
    text = '';
  }

  return text;
}

String twoDigits(int n) {
  if (n >= 10) {
    return "$n:00";
  }
  return "0$n:00";
}

double getTabTextScaleFactor(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final tabTextScaleFactor =
      mediaQuery.textScaleFactor > 1.25 ? 1.25 : mediaQuery.textScaleFactor;
  return tabTextScaleFactor;
}

// https://stackoverflow.com/a/55168907
String removeDecimalZeroFormat(double n) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
}

double getContentRating(int? totalRating, int? totalUserRate) {
  final _rating = (totalRating ?? 0) / (totalUserRate ?? 0);
  final rating = _rating.isFinite ? _rating : 0.0;
  return rating;
}
