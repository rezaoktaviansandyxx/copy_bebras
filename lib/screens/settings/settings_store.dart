import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:mobx/mobx.dart';

import '../../appsettings.dart';  

part 'settings_store.g.dart';

class SettingsStore = _SettingsStore with _$SettingsStore;

abstract class _SettingsStore extends BaseStore with Store {
  var appServices = sl.get<AppServices>();
  _SettingsStore({
    AppServices? appServices,
  }) {
    this.appServices = appServices ?? (appServices = this.appServices);

    goBack = Command.sync(() {
      appServices!.navigatorState!.pop();
    });
  }

  late Command goBack;
}
