import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/screens/profile/user_change_password_screen.dart';
import 'package:fluxmobileapp/screens/profile/user_profile_screen.dart';
import 'package:fluxmobileapp/screens/settings/settings_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/app_shimmer.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../appsettings.dart';
import '../../stores/user_profile_store.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with BaseStateMixin<SettingsStore, SettingsScreen> {
  final _store = SettingsStore();
  @override
  SettingsStore get store => _store;

  final localization = sl.get<ILocalizationService>();
  final appServices = sl.get<AppServices>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfileStore = Provider.of<UserProfileStore>(
        context,
        listen: false,
      );
      userProfileStore.getProfile.executeIf();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );

    return Container(
      color: context.isLight ? const Color(0xffF3F8FF) : null,
      child: Stack(
        children: [
          AppClipPath(
            height: 150,
          ),
          Scaffold(
            backgroundColor: context.isLight ? Colors.transparent : null,
            appBar: AppBar(
              title: Text(
                localization!.getByKey(
                  'settings.title',
                ),
                style: context.isLight
                    ? TextStyle(
                        color: const Color(0xffF3F8FF),
                      )
                    : null,
              ),
              backgroundColor: context.isLight ? Colors.transparent : null,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: context.isLight ? const Color(0xffF3F8FF) : null,
                ),
                onPressed: () {
                  store.goBack.executeIf();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Profile section
                        Observer(
                          builder: (context) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: context.isLight
                                    ? const Color(0xffF3F8FF)
                                    : Theme.of(context)
                                        .inputDecorationTheme
                                        .fillColor,
                                border: context.isLight
                                    ? Border.all(
                                        color: const Color(
                                          0xff0398CD,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  WidgetSelector(
                                    selectedState:
                                        userProfileStore.getProfileState,
                                    states: {
                                      [DataState.success]: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              Get.toNamed(
                                                  '/user_profile_screen');
                                              // appServices!.navigatorState!
                                              //     .pushNamed(
                                              //   '/user_profile_screen',
                                              // );
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: ListTile(
                                                    dense: true,
                                                    leading: Container(
                                                      height: 45,
                                                      width: 45,
                                                      child: ClipOval(
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              userProfileStore
                                                                      .userProfile!
                                                                      .avatar ??
                                                                  '',
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context,
                                                              url, v) {
                                                            return ProfilePicture(
                                                                name:
                                                                    '${userProfileStore.userProfile?.fullname}',
                                                                radius: 25.0,
                                                                fontsize: 14);
                                                            // Icon(
                                                            //   Icons
                                                            //       .account_balance,
                                                            //   size: 42,
                                                            // );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      userProfileStore
                                                              .userProfile!
                                                              .fullname ??
                                                          '',
                                                      style: AppTheme.of(
                                                              context)
                                                          .listItemTitleSettings,
                                                    ),
                                                    subtitle: Text(
                                                      userProfileStore
                                                              .userProfile!
                                                              .email ??
                                                          '',
                                                      style: AppTheme.of(
                                                              context)
                                                          .listItemSubtitleSettings,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 15,
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.chevron_right,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          createDivider(context),
                                        ],
                                      ),
                                      [DataState.loading]: AppShimmer(
                                        baseColor:
                                            Theme.of(context).canvasColor,
                                        highlightColor: Theme.of(context)
                                            .canvasColor
                                            .withOpacity(0.5),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Container(
                                              height: 28,
                                              width: 28,
                                              color: Colors.white,
                                            ),
                                          ),
                                          dense: true,
                                          title: Container(
                                            height: 12,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                          ),
                                          subtitle: Container(
                                            height: 12,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      [DataState.error]: Container(
                                        height: 200,
                                        padding: const EdgeInsets.all(
                                          15,
                                        ),
                                        child: ErrorDataWidget(
                                          text: userProfileStore
                                                  .getProfileState.message ??
                                              '',
                                          onReload: () {
                                            userProfileStore.getProfile
                                                .executeIf();
                                          },
                                        ),
                                      ),
                                    },
                                  ),

                                  // Change profile
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(UserChangePasswordScreen());
                                      // Navigator.of(context).push(
                                      //     MaterialPageRoute(
                                      //         builder: (BuildContext context) {
                                      //   return UserChangePasswordScreen();
                                      // }));
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: ListTile(
                                            dense: true,
                                            title: Text(
                                              'Change Password',
                                              style: AppTheme.of(context)
                                                  .listItemTitleSettings,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.chevron_right,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // Settings?
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: context.isLight
                                ? const Color(0xffF3F8FF)
                                : Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                            border: context.isLight
                                ? Border.all(
                                    color: const Color(
                                      0xff0398CD,
                                    ),
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed('/termcondition', arguments: {
                                    'termConditionType':
                                        TermConditionType.aboutus
                                  });
                                  // appServices!.navigatorState!.pushNamed(
                                  //   '/termcondition',
                                  //   arguments: {
                                  //     'termConditionType':
                                  //         TermConditionType.aboutus,
                                  //   },
                                  // );
                                },
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    localization!.getByKey(
                                      'aboutus.title',
                                    ),
                                    style: AppTheme.of(context)
                                        .listItemTitleSettings,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: context.isLight
                                        ? const Color(0xff0398CD)
                                        : null,
                                  ),
                                ),
                              ),
                              createDivider(context),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed('/termcondition', arguments: {
                                    'termConditionType':
                                        TermConditionType.privacy
                                  });
                                  // appServices!.navigatorState!.pushNamed(
                                  //   '/termcondition',
                                  //   arguments: {
                                  //     'termConditionType':
                                  //         TermConditionType.privacy,
                                  //   },
                                  // );
                                },
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    localization!.getByKey(
                                      'privacypolicy.title',
                                    ),
                                    style: AppTheme.of(context)
                                        .listItemTitleSettings,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: context.isLight
                                        ? const Color(0xff0398CD)
                                        : null,
                                  ),
                                ),
                              ),
                              createDivider(context),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed('/faq');
                                  // appServices!.navigatorState!
                                  //     .pushNamed('/faq');
                                },
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    localization!.getByKey(
                                      'faq.title',
                                    ),
                                    style: AppTheme.of(context)
                                        .listItemTitleSettings,
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: context.isLight
                                        ? const Color(0xff0398CD)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // Logout
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: context.isLight
                                ? const Color(0xffF3F8FF)
                                : Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                            border: context.isLight
                                ? Border.all(
                                    color: const Color(
                                      0xff0398CD,
                                    ),
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        userProfileStore.logout.executeIf();
                                      },
                                      child: ListTile(
                                        dense: true,
                                        title: Text(
                                          localization!.getByKey(
                                            'settings.profile.logout',
                                          ),
                                          style: AppTheme.of(context)
                                              .listItemTitleSettings,
                                        ),
                                        trailing: Icon(
                                          FontAwesomeIcons.signOutAlt,
                                          color: context.isLight
                                              ? const Color(0xff0398CD)
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding createDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Divider(
        height: 1,
        color: context.isLight
            ? const Color(0xff0398CD)
            : Theme.of(context).canvasColor,
      ),
    );
  }
}
