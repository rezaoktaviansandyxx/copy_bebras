import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/services/firebase_service.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/stores/tutorial_walkthrough_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/widgets/tutorial_walkthrough_basic.dart';
import 'package:mobx/mobx.dart';

import '../api_services/api_services.dart';
import '../appsettings.dart';

part 'user_profile_store.g.dart';

class UserProfileStore = _UserProfileStore with _$UserProfileStore;

abstract class _UserProfileStore extends BaseStore with Store {
  var appClient = sl.get<AppClientServices>();

  _UserProfileStore({
    AppClientServices? appClient,
    AppServices? appServices,
    SecureStorage? secureStorage,
  }) {
    this.appClient = appClient ?? (appClient = this.appClient);
    appServices = appServices ?? sl.get<AppServices>();
    secureStorage = secureStorage ?? sl.get<SecureStorage>();

    getProfile = Command(() async {
      try {
        getProfileState = DataState.loading;

        final user = await appClient!.getUserProfile();
        userProfile = user.payload;

        // if (kDebugMode) {
        //   await Future.delayed(const Duration(hours: 10));
        // }

        getProfileState = DataState.success;
      } catch (error) {
        userProfile = UserProfile();
        getProfileState = DataState.error
          ..message = getErrorMessage(
            error,
          );
      }
    });

    goToSettings = Command(() async {
      appServices!.navigatorState!.pushNamed('/settings');
    });

    logout = Command(() async {
      try {
        // await firebaseMessagingInstance!.deleteToken();
        await secureStorage!.removeAll();
        appServices!.navigatorState!.pushNamedAndRemoveUntil(
          '/',
          (_) => false,
        );
      } catch (error) {
        logger.e(error);
      }
    });

    changePassword = Command.parameter((fromIsFirstTimeUser) async {
      try {
        changePasswordState = DataState.loading;

        await appClient!.changePassword(
          currentPassword,
          newPassword,
          confirmNewPassword,
        );

        changePasswordInteraction.handle('Password updated');

        currentPassword = '';
        newPassword = '';
        confirmNewPassword = '';

        if (fromIsFirstTimeUser != true) {
          if (appServices!.navigatorState!.canPop()) {
            appServices.navigatorState!.pop();
          }
        } else {
          // Change the flag, change is first time login to false
          final loginResponse = await (secureStorage!.getLoginResponse());
          if (loginResponse != null) {
            loginResponse.isFirstLogin = false;
            await secureStorage.removeLogin();
            await secureStorage.setLoginResponse(loginResponse);
          }

          appServices!.navigatorState!.pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      } catch (error) {
        logger.e(error);

        changePasswordInteraction.handle(getErrorMessage(error));
      } finally {
        changePasswordState = DataState.success;
      }
    });

    forgotPassword = Command(() async {
      try {
        forgotPasswordState = DataState.loading;

        final response = await appClient!.forgotPassword(
          forgotPasswordEmail,
        );

        final message = response.data['payload'];
        forgotPasswordInteraction.handle(message ?? '');

        forgotPasswordEmail = '';
      } catch (error) {
        logger.e(error);

        forgotPasswordInteraction.handle(getErrorMessage(error));
      } finally {
        forgotPasswordState = DataState.success;
      }
    });

    _tutorialWalkthroughStore = TutorialWalkthroughStore(
      'tutorial_profile',
    );
    tutorialWalkthroughStore!.tutorials.addAll([
      TutorialWalkthroughBasicData()
        ..title = 'Self Assessment Statistic'
        ..description = ''
        ..status = '1/4',
      TutorialWalkthroughBasicData()
        ..title = 'Topic Score'
        ..description = ''
        ..status = '2/4',
      TutorialWalkthroughBasicData()
        ..title = 'Update Topic Interest'
        ..description = ''
        ..status = '3/4',
      TutorialWalkthroughBasicData()
        ..title = 'Topic Interest'
        ..description = ''
        ..status = '4/4',
    ]);
  }

  @observable
  DataState getProfileState = DataState.none;

  late Command getProfile;

  @observable
  UserProfile? userProfile;

  late Command goToSettings;

  late Command logout;

  @observable
  String? currentPassword;

  @observable
  String? newPassword;

  @observable
  String? confirmNewPassword;

  late Command<bool> changePassword;

  @observable
  var changePasswordState = DataState.success;

  final changePasswordInteraction = Interaction<String?, Object>();

  @observable
  String? forgotPasswordEmail;

  late Command forgotPassword;

  @observable
  var forgotPasswordState = DataState.success;

  final forgotPasswordInteraction = Interaction<String?, Object>();

  TutorialWalkthroughStore? _tutorialWalkthroughStore;
  TutorialWalkthroughStore? get tutorialWalkthroughStore =>
      _tutorialWalkthroughStore;
}
