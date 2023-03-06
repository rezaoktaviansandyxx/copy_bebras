import 'package:flutter/widgets.dart';

abstract class ILocalizationService {
  Locale? get locale;

  Locale get neutralLocale;

  Future loadFromBundle(Locale locale);

  String getByKey(String key);

  List<LanguageModel> getSupportedLanguages();

  Future<bool> saveLanguage(LanguageModel language);

  Future<LanguageModel> getSavedLanguage();

  Stream<LanguageModel> get onLanguageChanged;
}

class LanguageModel {
  Locale? locale;

  String? name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel && locale == other.locale;
  }

  @override
  int get hashCode {
    return locale.hashCode;
  }
}
