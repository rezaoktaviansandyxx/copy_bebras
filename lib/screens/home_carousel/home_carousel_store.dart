import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:mobx/mobx.dart';

part 'home_carousel_store.g.dart';

class HomeCarouselStore = _HomeCarouselStore with _$HomeCarouselStore;

abstract class _HomeCarouselStore extends BaseStore with Store {
  _HomeCarouselStore() {
    items.addAll([
      0,
      2123,
      0,
      2123,
      0,
      2123,
      0,
      2123,
    ]);
  }

  @observable
  ObservableList<int> items = ObservableList();
}
