import 'package:flutter_test/flutter_test.dart';
import 'package:fluxmobileapp/screens/splash/splash_store.dart';

void main() {
  SplashStore splashStore;
  splashStore = SplashStore();
  test('Tes Pertama Login', () {
    expect(splashStore.initialize, isNotNull);
  });
}
