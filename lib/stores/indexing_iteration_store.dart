import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:mobx/mobx.dart';

part 'indexing_iteration_store.g.dart';

class IndexingIterationStore<T> = _IndexingIterationStore<T>
    with _$IndexingIterationStore;

abstract class _IndexingIterationStore<T> extends BaseStore with Store {
  _IndexingIterationStore() {
    previous = Command(() async {
      if (currentIndex <= 0) {
        return;
      }

      currentIndex--;
    });

    next = Command(() async {
      if (currentIndex >= items.length) {
        return;
      }

      currentIndex++;
    });
  }

  late Command previous;
  late Command next;

  final items = ObservableList<T>();

  @observable
  int currentIndex = 0;

  @computed
  T? get currentItem {
    try {
      final _currentItem = currentIndex;
      return items.isNotEmpty ? items[_currentItem] : null;
    } catch (error) {
      logger.e(error);
      return null;
    }
  }

  @computed
  bool get isFirstItem => currentIndex == 0;

  @computed
  bool get isLastItem => currentIndex == items.length - 1;
}
