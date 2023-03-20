// ignore: unused_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_interceptor.dart';
// ignore: unused_import
import 'package:fluxmobileapp/api_services/api_services_mockup.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/screens/agendas/agendas_store.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_question.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_result_screen.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_store.dart';
import 'package:fluxmobileapp/screens/browse/browse_screen.dart';
import 'package:fluxmobileapp/screens/get_started/get_started_store.dart';
import 'package:fluxmobileapp/screens/goals/goals_store.dart';
import 'package:fluxmobileapp/screens/goals_create/goals_create_screen.dart';
import 'package:fluxmobileapp/screens/profile/user_profile_screen.dart';
import 'package:fluxmobileapp/screens/splash/splash_screen_first.dart';
import 'package:fluxmobileapp/screens/todo_detail/todo_detail_screen.dart';
import 'package:fluxmobileapp/term_condition/term_condition_screen.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_chart.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_introduction.dart';
import 'package:fluxmobileapp/screens/detail/detail_screen.dart';
import 'package:fluxmobileapp/screens/detail_article/detail_article_screen.dart';
import 'package:fluxmobileapp/screens/detail_podcast/detail_podcast_screen.dart';
import 'package:fluxmobileapp/screens/detail_session/detail_session_screen.dart';
import 'package:fluxmobileapp/screens/detail_video/detail_video_screen.dart';
import 'package:fluxmobileapp/screens/faq/faq_screen.dart';
import 'package:fluxmobileapp/screens/find_url_company/find_url_company_screen.dart';
import 'package:fluxmobileapp/screens/get_started/get_started_screen.dart';
import 'package:fluxmobileapp/screens/goals_detail/goals_detail_screen.dart';
import 'package:fluxmobileapp/screens/interest/interest_picker.dart';
import 'package:fluxmobileapp/screens/login/login_screen.dart';
import 'package:fluxmobileapp/screens/main_tab/main_tab_screen.dart';
import 'package:fluxmobileapp/screens/profile/user_registered_success_screen.dart';
import 'package:fluxmobileapp/screens/settings/settings_screen.dart';
import 'package:fluxmobileapp/services/api_services_interceptor_logout_provider_impl.dart';
import 'package:fluxmobileapp/services/firebase_service.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/stores/app_store.dart';
import 'package:fluxmobileapp/stores/interest_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:get/get.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import "appsettings.dart";
import 'baselib/app_services.dart';
import 'baselib/localization_service.dart';
import 'baselib/localization_service_impl.dart';
import 'screens/splash/splash_screen.dart';
import 'api_services/api_services.dart';
import './screens/assessment/assessment_chart_store.dart';
import 'stores/user_profile_store.dart';

void registerInjector() {
  sl.registerLazySingleton<ILocalizationService>(() {
    return LocalizationServiceImpl();
  });
  sl.registerLazySingleton<AppServices>(() {
    return AppServicesImplementation();
  });
  sl.registerBuilder<AssetBundle>(() {
    return PlatformAssetBundle();
  });
  sl.registerLazySingleton<ApiServicesInterceptorLogoutProvider>(() {
    return ApiServicesInterceptorLogoutProviderImpl();
  });
  sl.registerLazySingleton<AppClientServices>(() {
    // final client =
    //     kReleaseMode ? AppClientServicesImpl() : AppClientMockupServices();
    final client = AppClientServicesImpl();
    return client;
  });
  sl.registerLazySingleton<SecureStorage>(() {
    return SecureStorageImpl();
  });
}

Future<void> main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  registerInjector();

  mainContext.config = mainContext.config.clone(
    writePolicy: ReactiveWritePolicy.never,
  );

  // await initFirebase();

  sl.registerLazySingleton<AppStore>(() => AppStore());
  runApp(MyApp());
}

final routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  final appServices = sl.get<AppServices>();

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      canvasColor: const Color(0xff1B304D),
      disabledColor: Colors.grey.withOpacity(0.5),
      fontFamily: 'Rubik',
      textTheme: TextTheme(
        headline4: const TextStyle(
          fontSize: FontSizes.cardTitle,
        ),
        bodyText1: const TextStyle(
          fontFamily: 'Rubik',
          color: const Color(0xffE3E3E3),
          fontSize: FontSizes.regular,
        ),
      ),
      accentColor: const Color(0xffFF5064),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xff354C6B),
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
      appBarTheme: AppBarTheme(
        color: const Color(0xff152233),
        elevation: 0,
        textTheme: const TextTheme(
          headline6: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.cardTitle,
            letterSpacing: 0.5,
            color: const Color(0xffE3E3E3),
          ),
        ),
        iconTheme: IconThemeData(
          color: const Color(0xFFE3E3E3),
        ),
      ),
      iconTheme: IconThemeData(
        color: const Color(0xff9FADBF),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
    );
    final lightTheme = ThemeData(
      canvasColor: const Color(0xffEDF3FC),
      disabledColor: Colors.grey.withOpacity(0.5),
      fontFamily: 'Rubik',
      textTheme: TextTheme(
        headline4: const TextStyle(
          fontSize: FontSizes.cardTitle,
        ),
        bodyText1: const TextStyle(
          fontFamily: 'Rubik',
          color: const Color(0xffE3E3E3),
          fontSize: FontSizes.regular,
        ),
        subtitle1: const TextStyle(
          color: const Color(0xffE3E3E3),
        ),
      ),
      dialogTheme: DialogTheme(
        contentTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'Rubik',
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'Rubik',
        ),
      ),
      accentColor: const Color(0xff0E9DE9),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: const Color(0xff354C6B),
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        hintStyle: TextStyle(
          color: const Color(0xff9FADBF),
        ),
      ),
      appBarTheme: AppBarTheme(
        color: const Color(0xffF3F8FF),
        elevation: 0,
        textTheme: const TextTheme(
          headline6: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.cardTitle,
            letterSpacing: 0.5,
            color: const Color(0xff0E9DE9),
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontFamily: 'Rubik',
          letterSpacing: 0.3,
          fontWeight: FontWeight.w500,
          color: const Color(0xff0E9DE9),
        ),
        iconTheme: IconThemeData(
          color: const Color(0xff0E9DE9),
        ),
      ),
      iconTheme: IconThemeData(
        color: const Color(0xff9FADBF),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xff0E9DE9),
        ),
      ),
    );
    final theme = lightTheme;

    final routes = {
      '/': (context, dynamic args) => SplashScreenV2(),
      '/splash_screen':(context, dynamic args) => SplashScreen(),
      '/get_started': (context, dynamic args) => GetStartedScreen(),
      '/login': (context, dynamic args) => LoginScreen(),
      '/main': (context, dynamic args) => MainTabScreen(),
      '/settings': (context, dynamic args) {
        return SettingsScreen();
      },
      '/detail': (context, dynamic args) {
        return DetailScreen();
      },
      '/detail_article': (context, dynamic args) {
        return DetailArticleScreen();
      },
      '/detail_podcast': (context, dynamic args) {
        return DetailPodcastScreen();
      },
      '/detail_video': (context, dynamic args) {
        return DetailVideoScreen();
      },
      '/detail_session': (context, dynamic args) {
        return DetailSessionScreen();
      },
      '/detail_goals': (context, dynamic args) {
        return GoalsDetailScreen(
          item: Get.arguments['item'],
          goalsStore: Get.arguments['goalsStore'],
          titleMode: Get.arguments['titleMode'],
        );
      },
      '/assessment_introduction': (context, dynamic args) {
        return AssessmentIntroduction(
          parameters: Map.from(Get.arguments ?? {}),
        );
      },
      '/assessment_chart': (context, dynamic args) {
        return AssessmentChartScreen();
      },
      '/interest': (context, dynamic args) {
        return InterestPicker();
      },
      '/user_registered_success': (context, dynamic args) {
        return UserRegisteredSuccessScreen();
      },
      '/faq': (context, dynamic args) {
        return FaqScreen();
      },
      '/termcondition': (context, dynamic args) {
        final termConditionType = Get.arguments['termConditionType'];
        return TermConditionScreen(
          termConditionType: termConditionType,
        );
      },
      '/findcompany': (context, dynamic args) {
        return FindUrlCompanyScreen();
      },
      '/agendas_screen_listview_tap_detail': (context, dynamic args) {
        final map = Map.from(Get.arguments);
        final AgendaItemStore? itemStore = map['itemStore'];
        final AgendasStore? store = map['store'];
        return Observer(
          builder: (BuildContext context) {
            return TodoDetailScreen(
              todoItem: itemStore!.item,
              state: itemStore.editTodoState,
              provider: TodoDetailProvider(
                onDelete: () {
                  store!.deleteTodo.executeIf(
                    itemStore.item,
                  );
                },
                onMarkAsDone: () {
                  store!.completeTodo.executeIf(
                    itemStore,
                  );
                },
                onSaved: (v) {
                  store!.editTodo.executeIf(
                    Tuple2(itemStore, v),
                  );
                },
              ),
            );
          },
        );
      },
      '/assessment_chart_tap_item_result': (context, Map? args) {
        return AssessmentResultScreenV2(
          isLastItem: Get.arguments['isLastItem'],
          assessmentModel: Get.arguments['assessmentModel'],
          viewFromProfile: Get.arguments['viewFromProfile'],
        );
      },
      '/assessment_question': (context, dynamic args) {
        final AssessmentStore? store = Get.arguments['store'];
        return AssessmentQuestion(
          store: store,
        );
      },
      '/user_profile_screen': (context, dynamic args) {
        return UserProfileScreen();
      },
      '/add_goals': (context, dynamic args) {
        return GoalsCreateScreen();
      },
    };

    final userProfileStore = UserProfileStore();

    sl.registerBuilder<UserProfileStore>(() {
      return userProfileStore;
    });

    final assessmentChartStore = AssessmentChartStore();

    final appStore = sl.get<AppStore>();

    return FutureBuilder<AppThemeModel?>(
      future: Future(
        () async {
          await appStore!.getTheme.executeIf();
          return appStore.appTheme;
        },
      ),
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox();
        }

        var darkAppThemeData = AppThemeData(
          canvasColorLevel2: const Color(0xff152233),
          canvasColorLevel3: const Color(0xff354C6B),
        );
        darkAppThemeData = darkAppThemeData
          ..sectionTitle = darkAppThemeData.sectionTitle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.large,
            color: const Color(0xff9FADBF),
            fontFamily: 'Quicksand',
          )
          ..sectionSubtitle = darkAppThemeData.sectionSubtitle.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: FontSizes.regular,
            color: const Color(0xffE3E3E3),
          )
          ..listItemSubtitleSettings =
              darkAppThemeData.listItemSubtitleSettings.copyWith(
            fontSize: FontSizes.thin,
            fontFamily: 'Rubik',
            color: const Color(0xff9FADBF),
          )
          ..listItemTitleSettings =
              darkAppThemeData.listItemTitleSettings.copyWith(
            color: const Color(0xffE3E3E3),
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.large,
          )
          ..okButtonColor = const Color(
            0xff5AD57F,
          )
          ..selectedColor = const Color(0xff5AD57F)
          ..popupButtonColor = const Color(0xff5AD57F)
          ..disabledColor1 = const Color(0xff243A58);

        var lightAppThemeData = AppThemeData(
          canvasColorLevel2: const Color(0xffF3F8FF),
          // canvasColorLevel3: const Color(0xffF3F8FF),
          canvasColorLevel3: const Color(0xff354C6B),
          gradientBgColor: Tuple2(
            const Color(0xFF0E9DE9),
            const Color(0xFF4BC6A0),
          ),
          getStartedColor: GetStartedTheme(
            titleColor: const Color(0xFF14C48D),
            subtitleColor: const Color(0xFF0398CD),
            gradientBgColor: Tuple2(
              const Color(0xFF0E9DE9),
              const Color(0xFF4BC6A0),
            ),
            bgColor: const Color(0xFFF3F8FF),
            button1: const Color(0xFFF3F8FF),
            button2: const Color(0xFF5A6E8F),
          ),
        );
        lightAppThemeData = lightAppThemeData
          ..sectionTitle = lightAppThemeData.sectionTitle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.large,
            color: const Color(0xff0E9DE9),
            fontFamily: 'Quicksand',
          )
          ..sectionSubtitle = lightAppThemeData.sectionSubtitle.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: FontSizes.regular,
            // color: const Color(0xff5A6E8F),
          )
          ..listItemSubtitleSettings =
              lightAppThemeData.listItemSubtitleSettings.copyWith(
            fontSize: FontSizes.thin,
            fontFamily: 'Rubik',
            color: const Color(0xff5A6E8F),
          )
          ..listItemTitleSettings =
              lightAppThemeData.listItemTitleSettings.copyWith(
            color: const Color(0xff0398CD),
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
            fontSize: FontSizes.large,
          )
          ..okButtonColor = const Color(
            0xff0E9DE9,
          )
          ..selectedColor = const Color(0xff5AD57F)
          ..popupButtonColor = const Color(0xff5AD57F)
          ..disabledColor1 = const Color(0xff243A58);

        return AppTheme(
          appThemeData: theme.brightness == Brightness.dark
              ? darkAppThemeData
              : lightAppThemeData,
          child: FontSizesWidget(
            child: MultiProvider(
              providers: [
                Provider.value(
                  value: userProfileStore,
                ),
                Provider.value(
                  value: assessmentChartStore,
                ),
                Provider(
                  create: (BuildContext context) {
                    return InterestStore();
                  },
                ),
              ],
              child: GetMaterialApp(
                title: 'Aplikasi Bebras',
                debugShowCheckedModeBanner: false,
                theme: theme,
                scrollBehavior: MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch
                  },
                ),
                navigatorKey: appServices!.navigatorStateKey,
                navigatorObservers: [
                  routeObserver,
                ],
                getPages: routes.entries
                    .map(
                      (entry) => GetPage(
                          name: entry.key, page: () => entry.value(null, null)),
                    )
                    .toList(),
                // onGenerateRoute: (s) {
                //   latestRoute = s.name;
                //   var widgetBuilder = routes[s.name];
                //   return CupertinoPageRoute(
                //     settings: RouteSettings(
                //       name: s.name,
                //     ),
                //     builder: (BuildContext context) {
                //       final args = s.arguments != null
                //           ? Map<dynamic, dynamic>.from(
                //               s.arguments as Map<dynamic, dynamic>)
                //           : Map<dynamic, dynamic>();
                //       args.removeWhere((key, value) => value == null);
                //       var widget = widgetBuilder!(context, args);
                //       if (widget is BaseWidgetParameterMixin) {
                //         var baseWidgetParameterMixin = widget;
                //         if (s.arguments != null) {
                //           baseWidgetParameterMixin.parameter.addAll(
                //             Map.from(
                //               args,
                //             ),
                //           );
                //         }
                //       }
                //       return widget;
                //     },
                //   );
                // },
              ),
            ),
          ),
        );
      },
    );
  }
}
