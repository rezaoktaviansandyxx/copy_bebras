import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';

import '../appsettings.dart';
import 'localization_service.dart';

class LocalizationServiceImpl extends ILocalizationService {
  var _assetBundle = sl.get<AssetBundle>();

  LocalizationServiceImpl({
    AssetBundle? assetBundle,
  }) {
    _assetBundle = assetBundle ?? _assetBundle;
  }

  final rxPrefs = RxSharedPreferences.getInstance();

  Locale? _locale;
  Locale? get locale => _locale;

  Map<String, Object> _localeResources = {};
  Map<String, Object> _defaultResources = {};

  Future<bool> saveLanguage(LanguageModel language) async {
    return await rxPrefs
        .setString('app_locale', language.locale!.toLanguageTag())
        .then(
      (v) {
        _onLanguageChanged.add(language);
        return Future.value(true);
      },
    );
  }

  Future<LanguageModel> getSavedLanguage() async {
    var languageTag = await rxPrefs.getString('app_locale');
    var languages = getSupportedLanguages();
    var saved = languages.firstWhere(
      (t) => t.locale!.toLanguageTag() == languageTag,
      orElse: () => languages.firstWhere(
        (t) => t.locale!.toLanguageTag() == 'en-US',
      ),
    );
    return saved;
  }

  final _onLanguageChanged = PublishSubject<LanguageModel>();
  Stream<LanguageModel> get onLanguageChanged => _onLanguageChanged
      .asyncExpand(
        (v) => Rx.defer(() {
          return loadFromBundle(v.locale!).asStream().map((_) => v);
        }),
      )
      .asBroadcastStream();

  Future loadFromBundle(Locale l) async {
    _locale = l;

    // {
    //   _defaultResources.clear();
    //   var defaultResourcePath = p.join('assets', 'i18n', 'default.yaml');
    //   var raw = await _assetBundle.loadString(
    //     defaultResourcePath,
    //   );
    //   YamlMap r = loadYaml(raw);
    //   _defaultResources.addAll(Map.from(r));
    // }

    {
      try {
        _localeResources.clear();

        var defaultResourcePath = p.join(
          'assets',
          'i18n',
          '${l.toLanguageTag().replaceAll('-', '_')}.yaml',
        );
        var raw = await _assetBundle!.loadString(
          defaultResourcePath,
        );
        YamlMap r = loadYaml(raw);
        _localeResources.addAll(Map.from(r));
      } catch (e) {
        print(e);
      }
    }
  }

  String getByKey(String key) {
    return _localeResources[key] as String? ?? _defaultResources[key] as String? ?? '-';
  }

  var _neutralLocale = Locale('en-US');
  @override
  Locale get neutralLocale => _neutralLocale;

  List<LanguageModel> getSupportedLanguages() {
    return [
      LanguageModel()
        ..locale = Locale('en-US')
        ..name = 'English (United States)',
      LanguageModel()
        ..locale = Locale('en-US')
        ..name = 'Indonesian',
    ];
  }
}
