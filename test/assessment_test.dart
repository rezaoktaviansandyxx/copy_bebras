import 'package:flutter_test/flutter_test.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_store.dart';

import 'mock_app_client_service.dart';
import 'mock_secure_storage.dart';

main() {
  test("Tes apakah ada soal atau tidak", () async {
    AssessmentStore store = AssessmentStore(
      secureStorage: MockSecureStorage(),
      appClientServices: MockAppClientService(),
    );
    await store.getAssessment.executeIf();
    expect(store.indexingAssessmentStore.items.isNotEmpty, true);
  });
  test("Tes Jika di klik jawaban, maka akan terisi jawaban yang dipilih", () async {
    AssessmentStore store = AssessmentStore(
      secureStorage: MockSecureStorage(),
      appClientServices: MockAppClientService(),
    );
    await store.tapAnswer.executeIf();
    expect(store.currentQuestion!.id, true);
  });
}
