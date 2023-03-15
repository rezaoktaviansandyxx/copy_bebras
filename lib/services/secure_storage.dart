import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';

abstract class SecureStorage {
  Future<String?> getValue(String key);

  Future write(String key, String? value);

  Future remove(String key);

  Future<bool> containsKey(String key);

  Future removeAll();

  Future<Map<String, String>> getAll();
}

class SecureStorageImpl extends SecureStorage {
  final storage = FlutterSecureStorage();

  @override
  Future<String?> getValue(String key) async {
    final value = await storage.read(
      key: key,
    );
    return value;
  }

  @override
  Future write(String key, String? value) async {
    await storage.write(
      key: key,
      value: value,
    );
  }

  @override
  Future remove(String key) async {
    await storage.delete(
      key: key,
    );
  }

  @override
  Future<bool> containsKey(String key) async {
    final value = await getValue(key);
    return value != null;
  }

  @override
  Future removeAll() async {
    await storage.deleteAll();
  }

  @override
  Future<Map<String, String>> getAll() async {
    final _keys = await storage.readAll();
    return _keys;
  }
}

extension AuthExtension on SecureStorage {
  Future<LoginResponse?> getLoginResponse() async {
    final json = await this.getValue('user_auth');
    if (json == null) {
      return null;
    }

    final loginResponse = LoginResponse.fromJson(jsonDecode(json));
    return loginResponse;
  }

  Future setLoginResponse(LoginResponse loginResponse) async {
    final json = jsonEncode(loginResponse.toJson());
    await this.write('user_auth', json);
  }

  Future removeLogin() async {
    await this.remove('user_auth');
  }

  Future setUserProfile(UserProfile userProfile) async {
    final json = jsonEncode(userProfile.toJson());
    await this.write('userprofile', json);
  }

  Future<UserProfile?> getUserProfile() async {
    final json = await this.getValue('userprofile');
    if (json == null) {
      return null;
    }

    return UserProfile.fromJson(jsonDecode(json));
  }

  Future removeUserProfile() async {
    await this.remove('userprofile');
  }
}
