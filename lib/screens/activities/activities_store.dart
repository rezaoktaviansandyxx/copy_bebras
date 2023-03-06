import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:mobx/mobx.dart';

part 'activities_store.g.dart';

class ActivitiesStore = _ActivitiesStore with _$ActivitiesStore;

abstract class _ActivitiesStore extends BaseStore with Store {
  _ActivitiesStore() {
    registerDispose(() {});
  }
}
