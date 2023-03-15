import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxmobileapp/baselib/localization_service_impl.dart';
import 'package:fluxmobileapp/screens/login/login_store.dart';
import 'package:mobx/mobx.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  mainContext.config = mainContext.config.clone(
    writePolicy: ReactiveWritePolicy.never,
  );
  late RegistrationStore registrationStore;
  setUp(
    () {
      registrationStore = RegistrationStore(
        localization: LocalizationServiceImpl(),
      );
    },
  );
  group('Tes Register', () {
    test('Tes nama lengkap jika kosong', () {
      registrationStore.fullname.value = '';
      expect(true, registrationStore.fullname.value!.isEmpty);
    });
    test('Tes nama lengkap jika terisi', () {
      registrationStore.fullname.value = 'Example';
      expect(true, registrationStore.fullname.value!.isNotEmpty);
    });
    test('Tes email jika kosong', () {
      registrationStore.fullname.value = '';
      expect(true, registrationStore.fullname.value!.isEmpty);
    });
    test('Tes email jika terisi', () {
      registrationStore.fullname.value = 'example@example.com';
      expect(true, registrationStore.fullname.value!.isNotEmpty);
    });
    test('Tes email jika valid', () {
      registrationStore.email.value = 'example@example.com';
      registrationStore.email.validate();
      expect(true, registrationStore.email.isValid);
    });
    test('Tes email jika tidak valid', () {
      registrationStore.email.value = 'example.com';
      registrationStore.email.validate();
      expect(false, registrationStore.email.isValid);
    });
    test('Tes password jika kosong', () {
      registrationStore.password.value = '';
      registrationStore.confirmationPassword.value =
          ''; //menyambung dengan satu kesatuan
      expect(true, registrationStore.password.value!.isEmpty);
    });
    test('Tes password jika terisi', () {
      registrationStore.password.value = 'pass123';
      registrationStore.confirmationPassword.value =
          ''; //menyambung dengan satu kesatuan
      expect(true, registrationStore.password.value!.isNotEmpty);
    });
    test('Tes password jika valid', () {
      registrationStore.password.value = 'pass123';
      registrationStore.confirmationPassword.value =
          ''; //menyambung dengan satu kesatuan
      registrationStore.password.validate();
      expect(true, registrationStore.password.isValid);
    });
    test('Tes password jika tidak valid', () {
      registrationStore.password.value = '';
      registrationStore.confirmationPassword.value =
          ''; //menyambung dengan satu kesatuan
      registrationStore.password.validate();
      expect(false, registrationStore.password.isValid);
    });
    test('Tes konfirmasi password jika kosong', () {
      registrationStore.password.value = '';
      registrationStore.confirmationPassword.value =
          ''; //menyambung dengan satu kesatuan
      expect(true, registrationStore.confirmationPassword.value!.isEmpty);
    });
    test('Tes konfirmasi password jika terisi', () {
      registrationStore.password.value = 'pass123';
      registrationStore.confirmationPassword.value =
          'pass123'; //menyambung dengan satu kesatuan
      expect(true, registrationStore.confirmationPassword.value!.isNotEmpty);
    });
    test('Tes konfirmasi password jika sama ', () {
      registrationStore.password.value = 'pass123';
      registrationStore.confirmationPassword.value = 'pass123';
      registrationStore.confirmationPassword.validate();
      expect(true, registrationStore.confirmationPassword.isValid);
    });
    test('Tes konfirmasi password jika tidak sama ', () {
      registrationStore.password.value = '1234567';
      registrationStore.confirmationPassword.value = 'pass123';
      registrationStore.confirmationPassword.validate();
      expect(false, registrationStore.confirmationPassword.isValid);
    });
  });
}
