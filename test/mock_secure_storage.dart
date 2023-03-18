import 'dart:convert';

import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';

class MockSecureStorage extends SecureStorage {
  @override
  Future<bool> containsKey(String key) {
    // TODO: implement containsKey
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getAll() {
    return Future.value(Map<String, String>());
  }

  @override
  Future<String?> getValue(String key) {
    UserProfile userProfile = UserProfile()
      ..birthDay = DateTime.now()
      ..createdDate = DateTime.now()
      ..assessmentVersion = 0;
    var coded = jsonEncode(userProfile.toJson());
    return Future.value(coded);
  }

  @override
  Future remove(String key) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future removeAll() {
    // TODO: implement removeAll
    throw UnimplementedError();
  }

  @override
  Future write(String key, String? value) {
    return Future.value();
  }
}
