import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:mobx/mobx.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';

part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore extends BaseStore with Store {
  _AppStore() {
    themes.addAll([
      AppThemeModel()
        ..id = 'light'
        ..name = 'Light'
        ..baseAppTheme = BaseAppTheme.light,
      AppThemeModel()
        ..id = 'dark'
        ..name = 'Dark'
        ..baseAppTheme = BaseAppTheme.dark,
    ]);

    final secureStorage = sl.get<SecureStorage>();
    const String appThemeKey = 'app_theme';

    changeTheme = Command.parameter((p) async {
      await secureStorage!.write(appThemeKey, p!.id);
      appTheme = p;
    });

    getTheme = Command(() async {
      final themeId = await secureStorage!.getValue(appThemeKey);
      final theme = themes.firstWhere(
        (element) => element.id == themeId,
        orElse: () => themes[1],
      );
      await changeTheme.executeIf(theme);
    });
  }

  @observable
  AppThemeModel? appTheme;

  @observable
  var themes = ObservableList<AppThemeModel>();

  late Command<AppThemeModel> changeTheme;

  late Command getTheme;
}
