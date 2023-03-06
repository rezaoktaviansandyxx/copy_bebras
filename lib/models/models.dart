import 'package:mobx/mobx.dart';

part 'models.g.dart';

class TileItem<T> = _TileItem<T> with _$TileItem<T>;

abstract class _TileItem<T> with Store {
  final _value = Observable<T?>(null);
  T? get value => _value.value;
  set value(T? value) => _value.value = value;

  @observable
  bool isSelected = false;
}

enum BaseAppTheme {
  dark,
  light,
}

class AppThemeModel {
  String? id;
  String? name;
  BaseAppTheme? baseAppTheme;
}

enum TermConditionType {
  privacy,
  aboutus,
}
