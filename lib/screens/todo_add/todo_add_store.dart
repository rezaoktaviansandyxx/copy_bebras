import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:mobx/mobx.dart';
import 'package:quiver/strings.dart';

import '../../appsettings.dart';

part 'todo_add_store.g.dart';

class TodoAddStore = _TodoAddStore with _$TodoAddStore;

abstract class _TodoAddStore extends BaseStore with Store {
  _TodoAddStore({
    AppServices? appServices,
  }) {
    appServices = appServices = sl.get<AppServices>();

    apply = Command(() async {
      if (todoAddModel.isValidReminder != true) {
        return;
      }

      if (isBlank(todoAddModel.taskName) ||
          (dueDateRequired == true && todoAddModel.dueDate == null)) {
        return;
      }

      appServices!.navigatorState!.pop(todoAddModel);
    });
  }

  TodoAddModel todoAddModel = TodoAddModel();

  bool dueDateRequired = false;

  late Command apply;
}
