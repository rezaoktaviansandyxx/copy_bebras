import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/widgets.dart';

class WidgetSelector<T> extends StatelessWidget {
  final Map<List<T>, Widget> states;
  final T? selectedState;
  final List<T>? selectedStates;
  final bool maintainState;

  WidgetSelector({
    this.selectedStates,
    this.selectedState,
    required this.states,
    this.maintainState = false,
  });

  @override
  Widget build(BuildContext context) {
    if (maintainState == true) {
      return Stack(
        children: states.entries.map((f) {
          getSelectedStates() {
            final i = selectedStates!.firstWhereOrNull(
              (t) => f.key.contains(t),
            );
            return i;
          }
          return Visibility(
            maintainState: true,
            maintainAnimation: true,
            visible: selectedState != null
                ? f.key.contains(selectedState)
                : getSelectedStates() != null,
            child: f.value,
          );
        }).toList(),
      );
    }

    final state = states.entries.firstWhereOrNull(
      (t) => selectedState != null
          ? t.key.contains(selectedState)
          : selectedStates!.every((f) => t.key.contains(f)),
    );
    return state?.value ?? Container();
  }
}

class DataState {
  static DataState none = DataState(
    enumSelector: EnumSelector.none,
  );
  static DataState loading = DataState(
    enumSelector: EnumSelector.loading,
  );
  static DataState error = DataState(
    enumSelector: EnumSelector.error,
  );
  static DataState success = DataState(
    enumSelector: EnumSelector.success,
  );
  static DataState empty = DataState(
    enumSelector: EnumSelector.empty,
  );

  final EnumSelector enumSelector;
  String? message;

  DataState({
    required this.enumSelector,
    this.message,
  });

  bool operator ==(o) {
    if (o is DataState) {
      var b = enumSelector == o.enumSelector;
      return b;
    }
    return false;
  }

  @override
  int get hashCode => enumSelector.hashCode;

  @override
  String toString() {
    return '$enumSelector - $message';
  }
}

enum EnumSelector {
  none,
  loading,
  error,
  success,
  empty,
}
