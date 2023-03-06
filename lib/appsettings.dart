import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:logger/logger.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart'
    as rx_shared_preferences;

import 'baselib/service_locator.dart';

final _sl = ServiceLocator();
ServiceLocator get sl => _sl;

final logger = Logger();

const int pageLimit = 15;

final rxPrefs = rx_shared_preferences.RxSharedPreferences.getInstance();

const String companySuffix = '.anugra.id';

String? latestRoute = '';