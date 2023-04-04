import 'package:flutter/material.dart';
import 'package:fluxmobileapp/api_services/api_services.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_store.dart';
import 'package:fluxmobileapp/baselib/command.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/interest/interest_picker.dart';
import 'package:fluxmobileapp/screens/profile/user_change_password_screen.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/services/settings_helpers.dart';
import 'package:mobx/mobx.dart';

import '../../appsettings.dart';

part 'splash_store.g.dart';

class SplashStore = _SplashStore with _$SplashStore;

abstract class _SplashStore extends BaseStore with Store {
  var appServices = sl.get<AppServices>();
  var localization = sl.get<ILocalizationService>();
  var secureStorage = sl.get<SecureStorage>();

  _SplashStore({
    AppClientServices? appClientServices,
    AppServices? appServices,
    ILocalizationService? localization,
    SecureStorage? secureStorage,
  }) {
    appClientServices = appClientServices ?? sl.get<AppClientServices>();
    this.appServices = appServices ?? (appServices = this.appServices);
    this.localization = localization ?? (localization = this.localization);
    this.secureStorage = secureStorage ?? (secureStorage = this.secureStorage);

    initialize = Command(() async {
      try {
        dataState = DataState.loading;

        await isFirstTimeLaunch(
          runBeforeWrite: () async {
            await secureStorage!.removeAll();
          },
        );
        // if (kDebugMode) {
        //   await secureStorage.removeAll();
        // }

        String? route;

        await Future.delayed(const Duration(milliseconds: 250));
        final loginResponse = await secureStorage!.getLoginResponse();
        final isAuthenticated = loginResponse != null;
        await localization!.loadFromBundle(Locale('en-US'));

        if (isAuthenticated) {
          // // In last assessment when Skipped, this property will be set to false
          // if (loginResponse!.isFirstLoginAndEmptyAssessment == true) {
          //   route = '/assessment_introduction';
          // } else
          if (loginResponse!.isFirstLogin == true) {
            // final myAssessmentv2 =
            //     await appClientServices.getUserAssessmentV2();
            // final myAssessmentv2 = null;
            final myInterest = await appClientServices!.getMyInterest();
            if (myInterest == null ||
                myInterest.payload == null ||
                myInterest.payload!.isEmpty) {
              appServices!.navigatorState!.pushAndRemoveUntil(
                MaterialPageRoute(
                    settings: RouteSettings(
                      name: '/splash_interest_picker',
                    ),
                    builder: (BuildContext context) {
                      return InterestPicker(
                        firstTime: true,
                      );
                    }),
                (_) => false,
              );
              return;
            } else {
              route = '/main';
            }
          } else {
              route = '/main';
          }
          // else {
          //   appServices!.navigatorState!.pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (BuildContext context) {
          //       return UserChangePasswordScreen(
          //         fromIsFirstTimeUser: true,
          //       );
          //     }),
          //     (route) => false,
          //   );
          //   return;
          // }
        } else {
          route = '/get_started';
        }

        if (route != null) {
          appServices!.navigatorState!.pushNamedAndRemoveUntil(
            route,
            (_) => false,
          );
        }

        dataState = DataState.none;
      } catch (error) {
        dataState = DataState(
          enumSelector: EnumSelector.error,
          message: error.toString(),
        );
      }
    });
  }

  late Command initialize;

  @observable
  var dataState = DataState.loading;
}
