import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/interaction.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/login/login_screen.dart';
import 'package:fluxmobileapp/services/firebase_service.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';
import 'package:fluxmobileapp/utils/error_handling_utils.dart';
import 'package:fluxmobileapp/utils/mobx_utils.dart';
import 'package:fluxmobileapp/validations/mobx_forms.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:uuid/uuid.dart';

import '../../appsettings.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore extends BaseStore with Store {
  var localization = sl.get<ILocalizationService>();
  var appServices = sl.get<AppServices>();
  var apiClient = sl.get<AppClientServices>();
  var secureStorage = sl.get<SecureStorage>();

  _LoginStore({
    ILocalizationService? localization,
    AppServices? appServices,
    AppClientServices? apiClient,
    SecureStorage? secureStorage,
  }) {
    this.localization = localization ?? (localization = this.localization);
    this.appServices = appServices ?? (appServices = this.appServices);
    this.apiClient = apiClient ?? (apiClient = this.apiClient);
    this.secureStorage = secureStorage ?? (secureStorage = this.secureStorage);

    email.validations.add(
      StringNotNullValidator()
        ..errorMessage = localization!.getByKey(
          'common.cantbenull',
        ),
    );
    email.validations.add(
      EmailValidator()
        ..errorMessage = localization.getByKey(
          'common.invalidemail',
        ),
    );

    password.validations.add(
      StringNotNullValidator()
        ..errorMessage = localization.getByKey(
          'common.cantbenull',
        ),
    );

    {
      final emailObservable = MobxUtils.toStream(
        () => email.value,
      ).skip(1).map((_) {
        return email.validate();
      });
      final passwordObservable = MobxUtils.toStream(
        () => password.value,
      ).skip(1).map((_) {
        return password.validate();
      });
      final observables = [
        emailObservable,
        passwordObservable,
      ];
      final d = rx.MergeStream(observables).doOnData((_) {
        final validations = [
          email.isValid,
          password.isValid,
        ];
        canLogin = !validations.any((t) => !t);
      }).listen(null);
      registerDispose(() {
        d.cancel();
      });
    }

    login = Command(() async {
      final prevState = state;
      try {
        state = DataState.loading;

        final response = await apiClient!.auth(
          LoginRequest()
            ..username = email.value
            ..password = password.value
            ..companySite = '',
        );

        final loginPayload = response.payload!;

        await secureStorage!.setLoginResponse(
          loginPayload,
        );
        if (loginPayload.isFirstLogin == true) {
          final userProfileStore = sl.get<UserProfileStore>()!;
          userProfileStore.currentPassword = password.value;
        }

        // final fcmToken = await firebaseMessagingInstance!.getToken();
        // logger.i('Get FCM token after login $fcmToken');
        // await apiClient.updateFcmToken(fcmToken);

        final _userProfileResponse = await apiClient.getUserProfile();
        final _userProfile = _userProfileResponse.payload!;
        await secureStorage.setUserProfile(_userProfile);

        final myAssessmentv2 = await apiClient.getUserAssessmentV2(
          _userProfile.assessmentVersion,
        );
        loginPayload.isFirstLoginAndEmptyAssessment =
            ((myAssessmentv2 == null ||
                    myAssessmentv2.payload == null ||
                    myAssessmentv2.payload!.isEmpty) &&
                loginPayload.isFirstLogin == true);
        await secureStorage.setLoginResponse(loginPayload);

        await appServices!.navigatorState!.pushNamedAndRemoveUntil(
          '/splash_screen',
          (_) => false,
        );
      } catch (error) {
        alertInteraction.handle(getErrorMessage(error));
      } finally {
        state = prevState;
      }
    });

    verifyCompany = Command(() async {
      try {
        urlCompanyState = DataState.loading;

        final urlCompanyIsFound = await apiClient!.verifyCompany(urlCompany);
        if (urlCompanyIsFound.payload != true) {
          throw localization!.getByKey('urlcompany.notfound');
        }
      } catch (error) {
        logger.e(error);
        alertInteraction.handle(error.toString());
        throw error;
      } finally {
        urlCompanyState = DataState.none;
      }
    });
  }

  @observable
  String? urlCompany;

  final email = ValidatableObject<String>();

  final password = ValidatableObject<String>();

  final confirmationPassword = ValidatableObject<String>();

  @observable
  bool canLogin = false;

  late Command login;

  @observable
  DataState state = DataState.none;

  @observable
  DataState urlCompanyState = DataState.none;

  final alertInteraction = Interaction<String?, dynamic>();

  late Command verifyCompany;
}

class RegistrationStore = _RegistrationStore with _$RegistrationStore;

abstract class _RegistrationStore extends BaseStore with Store {
  var localization = sl.get<ILocalizationService>();
  var appServices = sl.get<AppServices>();
  var apiClient = sl.get<AppClientServices>();

  _RegistrationStore({
    ILocalizationService? localization,
    AppServices? appServices,
    AppClientServices? apiClient,
  }) {
    this.localization = localization ?? (localization = this.localization);
    this.appServices = appServices ?? (appServices = this.appServices);
    this.apiClient = apiClient ?? (apiClient = this.apiClient);

    email.validations.add(
      StringNotNullValidator()
        ..errorMessage = localization!.getByKey(
          'common.cantbenull',
        ),
    );
    email.validations.add(
      EmailValidator()
        ..errorMessage = localization.getByKey(
          'common.invalidemail',
        ),
    );

    fullname.validations.add(
      StringNotNullValidator()
        ..errorMessage = localization.getByKey(
          'common.cantbenull',
        ),
    );

    password.validations.add(
      StringNotNullValidator()
        ..errorMessage = localization.getByKey(
          'common.cantbenull',
        ),
    );

    confirmationPassword.validations.add(
      StringNotNullValidator()
        ..errorMessage = localization.getByKey(
          'common.cantbenull',
        ),
    );
    confirmationPassword.validations.add(
      InlineValidator<String>(validator: (String value) {
        return value == password.value;
      })
        ..errorMessage = localization.getByKey(
          'common.validation.password_confirmation',
        ),
    );
    // .addAll(
    //   [
    //     StringNotNullValidator()
    //       ..errorMessage = localization.getByKey(
    //         'common.cantbenull',
    //       ),
    //     InlineValidator(
    //       validator: (value) {
    //       return value == password.value;
    //     })
    //       ..errorMessage = localization.getByKey(
    //         'common.validaton.password_confirmation',
    //       ),
    //   ]
    // );

    {
      final emailObservable = MobxUtils.toStream(
        () => email.value,
      ).skip(1).map((_) {
        return email.validate();
      });
      final passwordObservable = MobxUtils.toStream(
        () => password.value,
      ).skip(1).map((_) {
        final validations = [
          password.validate(),
          confirmationPassword.validate(),
        ];
        final validated = validations.where((t) => t == true).length == 0;
        return validated;
      });
      final confirmationPasswordObservable = MobxUtils.toStream(
        () => confirmationPassword.value,
      ).skip(1).map((_) {
        return confirmationPassword.validate();
      });
      final observables = [
        emailObservable,
        passwordObservable,
        confirmationPasswordObservable,
      ];
      final d = rx.MergeStream(observables).doOnData((_) {
        final validations = [
          email.isValid,
          password.isValid,
          confirmationPassword.isValid
        ];
        canRegister = !validations.any((t) => !t);
      }).listen(null);
      registerDispose(() {
        d.cancel();
      });
    }

    var uuid = Uuid();
    register = Command(() async {
      final prevState = state;
      try {
        state = DataState.loading;

        await apiClient!.registerUser(RegisterUserRequest(
          avatar: '',
          birthDay: DateTime.now().subtract(
            const Duration(
              days: 365 * 20,
            ),
          ),
          birthPlace: '',
          id: uuid.v4(),
          email: email.value,
          username: email.value,
          password: password.value,
          fullname: fullname.value,
          userType: 2,
        ));

        await alertInteraction.handle(
          localization!.getByKey('login.button.register_success'),
        );
        // Get.back();
        // Get.toNamed(
        //   '/login',
        //   arguments: {'pageIndex': 0},
        // );
        if (appServices!.navigatorState!.canPop()) {
          // appServices.navigatorState!.pop();
          Get.back();
          Get.toNamed(
            '/login',
            arguments: {'pageIndex': 0},
          );
        } else {
          // appServices.navigatorState!.pushNamed('/');
          Get.toNamed('/splash_screen');
        }
      } catch (error) {
        final message = getErrorMessage(error);
        await alertInteraction.handle(message);
      } finally {
        state = prevState;
      }
    });
  }

  final email = ValidatableObject<String>();

  final fullname = ValidatableObject<String>();

  final password = ValidatableObject<String>();

  final confirmationPassword = ValidatableObject<String>();

  @observable
  bool canRegister = false;

  Command? register;

  @observable
  DataState state = DataState.none;

  final alertInteraction = Interaction<String?, dynamic>();
}
