import 'package:fluxmobileapp/appsettings.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

const String isFirstTimeLaunchKey = 'settingshelpers_isFirstTimeLaunch';

Future<bool> isFirstTimeLaunch({
  Future Function()? runBeforeWrite,
}) async {
  final _isFirstTimeLaunch = !(await rxPrefs.containsKey(isFirstTimeLaunchKey));
  if (_isFirstTimeLaunch) {
    if (runBeforeWrite != null) {
      await runBeforeWrite();
    }
    await rxPrefs.setBool(isFirstTimeLaunchKey, false);
  }
  return _isFirstTimeLaunch;
}
