import 'dart:async';

import 'package:mobx/mobx.dart' as mobx;
import 'package:rxdart/rxdart.dart';

class MobxUtils {
  static Stream toStream(Function function) {
    final controller = StreamController();
    var value;
    final ds = mobx.autorun((c) {
      controller.add(null);
      value = function();
    });

    return controller.stream.doOnCancel(() {
      ds.call();
      controller.close();
    }).map((_) {
      return value;
    });
  }
}
