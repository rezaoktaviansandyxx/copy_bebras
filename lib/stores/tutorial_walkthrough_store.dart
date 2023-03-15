import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:mobx/mobx.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class TutorialWalkthroughStore {
  TutorialWalkthroughStore(String tutorialSettingsKey) {
    tutorialSettingsKey =
        '${tutorialSettingsKey}_a701006ef3224ec1906e11481438b28d';
    nextTutorial = Command(() async {
      if (isLastTutorial) {
        await skipTutorial.executeIf();
      } else {
        currentTutorialIndex.value++;
      }
    });

    prevTutorial = Command(() async {
      if (currentTutorialIndex.value <= 0) {
        return;
      }

      currentTutorialIndex.value--;
    });

    skipTutorial = Command(() async {
      currentTutorialIndex.value = -1;
      await rxPrefs.setInt(tutorialSettingsKey, currentTutorialIndex.value);
    });

    getLastTutorialIndex = Command(() async {
      if (await rxPrefs.containsKey(tutorialSettingsKey) == true) {
        final tutorialHomeIndex = await rxPrefs.getInt(tutorialSettingsKey);
        currentTutorialIndex.value = tutorialHomeIndex ?? 0;
      } else {
        currentTutorialIndex.value = 0;
      }
    });
  }

  final tutorials = ObservableList<TutorialWalkthroughBasicData>();

  final currentTutorialIndex = Observable(-1);

  TutorialWalkthroughBasicData get currentTutorial {
    return tutorials[currentTutorialIndex.value];
  }

  get isLastTutorial => currentTutorialIndex.value >= tutorials.length - 1;

  late Command nextTutorial;

  late Command prevTutorial;

  late Command skipTutorial;

  late Command getLastTutorialIndex;
}
