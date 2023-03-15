import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/localization_service_impl.dart';
import 'package:fluxmobileapp/screens/login/login_store.dart';
import 'package:mobx/mobx.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  mainContext.config = mainContext.config.clone(
    writePolicy: ReactiveWritePolicy.never,
  );
  late LoginStore loginStore;
  late AppClientServicesImpl appClientServicesImpl;
  setUp(() {
    loginStore = LoginStore(
      localization: LocalizationServiceImpl(),
    );
    appClientServicesImpl = AppClientServicesImpl();
  });
  group('Tes Login', () {
    test('Tes email valid dari store', () {
      loginStore.email.value = 'example@example.com';
      loginStore.email.validate();
      expect(true, loginStore.email.isValid);
    });
    test('Tes email tidak valid dari store', () {
      loginStore.email.value = 'example@.com';
      loginStore.email.validate();
      expect(false, loginStore.email.isValid);
    });
    test('Tes email kosong', () {
      loginStore.email.value = '';
      expect(true, loginStore.email.value!.isEmpty);
    });
    test('Tes email terisi', () {
      loginStore.email.value = 'indraokisandy1@gmail.com';
      expect(true, loginStore.email.value!.isNotEmpty);
    });
    test('Tes password kosong', () {
      loginStore.password.value = '';
      expect(true, loginStore.password.value!.isEmpty);
    });
    test('Tes password terisi', () {
      loginStore.password.value = 'pass123';
      expect(true, loginStore.password.value!.isNotEmpty);
    });
    test('Tes password jika valid', () {
      loginStore.password.value = 'pass123';
      loginStore.password.validate();
      expect(true, loginStore.password.isValid);
    });
    test('Tes password jika tidak valid', () {
      loginStore.password.value = '';
      loginStore.password.validate();
      expect(false, loginStore.password.isValid);
    });
    test('Tes password salah', () async {
      bool isSukses = false;
      try {
        await appClientServicesImpl.auth(
          LoginRequest()
            ..username = 'example@example.com'
            ..password = 'pass12345'
            ..companySite = '',
        );
        isSukses = true;
      } catch (e) {
        print(e);
      }
      expect(false, isSukses);
    });
    test('Tes password benar', () async {
      bool isSuccess = false;
      try {
        await appClientServicesImpl.auth(
          LoginRequest()
            ..username = 'indraokisandy1@gmail.com'
            ..password = 'pass123'
            ..companySite = '',
        );
        isSuccess = true;
      } catch (e) {
        print(e);
      }
      expect(true, isSuccess);
    });
  });
}
