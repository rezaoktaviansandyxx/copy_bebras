import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/profile/user_forgot_password_screen.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/widget_utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:quiver/strings.dart';

import '../../appsettings.dart';
import 'login_store.dart';

class LoginScreen extends StatefulWidget with BaseWidgetParameterMixin {
  LoginScreen({Key? key}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var localization = sl.get<ILocalizationService>();
  PageController? pageViewController;
  final loginStore = LoginStore();
  final registrationStore = RegistrationStore();
  final appServices = sl.get<AppServices>();

  final titleStream = BehaviorSubject<String>();

  final urlCompanyController = TextEditingController();

  //variabel
  bool isHiddenPassword = true;
  bool isHiddenPassword2 = true;
  bool isHiddenPassword3 = true;

  void _togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  void _togglePasswordView2() {
    setState(() {
      isHiddenPassword2 = !isHiddenPassword2;
    });
  }

  void _togglePasswordView3() {
    setState(() {
      isHiddenPassword3 = !isHiddenPassword3;
    });
  }

  @override
  void initState() {
    super.initState();

    changeTitle(double? pageIndex) {
      if (pageIndex == 0) {
        // titleStream.add('Sign in');
        titleStream.add('images/logo_bebras.png');
      } else {
        // titleStream.add('Register');
        // titleStream.add('Company sign in');
        titleStream.add('images/logo_bebras.png');
      }
    }

    if (widget is BaseWidgetParameterMixin) {
      final int index = Get.arguments['pageIndex'];
      pageViewController = PageController(
        initialPage: index,
      );
      changeTitle(index.toDouble());
      pageViewController!.addListener(() {
        changeTitle(pageViewController!.page);
      });
    }

    {
      final d = loginStore.alertInteraction.registerHandler((i) async {
        final result = await createAlertDialog(i, context);
        return result;
      });
      loginStore.registerDispose(() {
        d.dispose();
      });
    }

    {
      final d = registrationStore.alertInteraction.registerHandler((i) async {
        final result = await createAlertDialog(i, context);
        return result;
      });
      registrationStore.registerDispose(() {
        d.dispose();
      });
    }
  }

  @override
  void dispose() {
    pageViewController!.dispose();
    loginStore.dispose();
    registrationStore.dispose();
    titleStream.close();
    // urlCompanyController.dispose();

    super.dispose();
  }

  FutureOr<bool> _onWillPop() {
    return Future.sync(() {
      if (pageViewController!.page == 1) {
        pageViewController!.jumpToPage(0);
        return false;
      }

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        10,
      ),
      borderSide: BorderSide.none,
    );

    final content = SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        color: Colors.white,
        // decoration: AppTheme.of(context).gradientBgColor != null
        //     ? BoxDecoration(
        //         gradient: LinearGradient(
        //           transform: GradientRotation(
        //             360,
        //           ),
        //           colors: [
        //             AppTheme.of(context).gradientBgColor!.item1,
        //             AppTheme.of(context).gradientBgColor!.item2,
        //           ],
        //         ),
        //       )
        //     : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Stack(
              children: <Widget>[
                CustomPaint(
                  child: Container(
                    height: 150,
                  ),
                  painter: CurveWidget(
                    color: Color(0XFF00ADEE).withOpacity(0.25),
                    // Theme.of(context).appBarTheme.color,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(
                    top: 30.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        titleStream.value,
                        height: 72,
                      ),
                    ],
                  ),
                ),
                AppBar(
                  // title: StreamBuilder(
                  //   stream: titleStream,
                  //   initialData: '',
                  //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //     return Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset(
                  //           snapshot.data,
                  //           height: 72,
                  //         ),
                  //       ],
                  //     );
                  // Text(
                  //   snapshot.data,
                  //   style: context.isLight
                  //       ? TextStyle(
                  //           color: Theme.of(context)
                  //               .appBarTheme
                  //               .textTheme!
                  //               .headline6!
                  //               .color,
                  //         )
                  //       : null,
                  // );
                  // },
                  // ),
                  // centerTitle: true,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () async {
                      final isPop = await _onWillPop();
                      if (isPop) {
                        Get.back();
                        // appServices!.navigatorState!.pop();
                      }
                    },
                  ),
                )
              ],
            ),
            Expanded(
              child: PageView(
                controller: pageViewController,
                pageSnapping: false,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        top: 30,
                      ),
                      child: Observer(
                        builder: (BuildContext context) {
                          return WidgetSelector(
                            selectedState: loginStore.state,
                            states: {
                              [DataState.none]: Stack(
                                children: <Widget>[
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: -100,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Image.asset(
                                          'images/maskot_bebras.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              35 /
                                              100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Text(
                                                // 'Enter email address and password below to login into your account',
                                                'Minta bantuan orang tua untuk masuk melalui email',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  color: Colors.black,
                                                  // context.isDark
                                                  //     ? Theme.of(context)
                                                  //         .iconTheme
                                                  //         .color
                                                  //     : const Color(0xffE3E3E3),
                                                  fontSize: FontSizesWidget.of(
                                                          context)!
                                                      .regular,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              // Observer(builder: (
                                              //   context,
                                              // ) {
                                              //   final initialValue = untracked(
                                              //     () => loginStore.urlCompany,
                                              //   );
                                              //   return TextFormField(
                                              //     autocorrect: false,
                                              //     initialValue: initialValue,
                                              //     readOnly: true,
                                              //     decoration: InputDecoration(
                                              //       border: inputBorder,
                                              //       fillColor: AppTheme.of(context)
                                              //           .disabledColor1,
                                              //       prefixIcon: Container(
                                              //         width: 50,
                                              //         height: 50,
                                              //         child: Image.asset(
                                              //           'images/ic_company.png',
                                              //         ),
                                              //       ),
                                              //       suffixText: companySuffix,
                                              //     ),
                                              //   );
                                              // }),
                                              // const SizedBox(
                                              //   height: 20,
                                              // ),
                                              Builder(
                                                builder:
                                                    (BuildContext context) {
                                                  var initalValue =
                                                      loginStore.email.value;
                                                  return Observer(
                                                    builder:
                                                        (BuildContext context) {
                                                      return TextFormField(
                                                        onChanged: (v) {
                                                          loginStore.email
                                                              .value = v.trim();
                                                        },
                                                        autocorrect: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                        initialValue:
                                                            initalValue,
                                                        decoration:
                                                            InputDecoration(
                                                          border: inputBorder,
                                                          errorText: loginStore
                                                              .email.error,
                                                          // prefixIcon: Container(
                                                          //   height: 50,
                                                          //   width: 50,
                                                          //   child: Image.asset(
                                                          //       'images/mail.png'),
                                                          // ),
                                                          hintText:
                                                              localization!
                                                                  .getByKey(
                                                            'login.placeholder.emailaddress',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Builder(
                                                builder:
                                                    (BuildContext context) {
                                                  final initialValue =
                                                      loginStore.password.value;
                                                  return Observer(
                                                    builder:
                                                        (BuildContext context) {
                                                      return TextFormField(
                                                        onChanged: (v) {
                                                          loginStore.password
                                                              .value = v;
                                                        },
                                                        obscureText:
                                                            isHiddenPassword3,
                                                        autocorrect: false,
                                                        initialValue:
                                                            initialValue,
                                                        decoration:
                                                            InputDecoration(
                                                          border: inputBorder,
                                                          errorText: loginStore
                                                                  .password
                                                                  .isValid
                                                              ? null
                                                              : loginStore
                                                                  .password
                                                                  .error,
                                                          // prefixIcon: Container(
                                                          //   width: 50,
                                                          //   height: 50,
                                                          //   child: Image.asset(
                                                          //     'images/password.png',
                                                          //   ),
                                                          // ),
                                                          hintText:
                                                              localization!
                                                                  .getByKey(
                                                            'login.placeholder.password',
                                                          ),
                                                          suffixIcon:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _togglePasswordView3();
                                                            },
                                                            child: Icon(
                                                              isHiddenPassword3
                                                                  ? Icons
                                                                      .visibility
                                                                  : Icons
                                                                      .visibility_off,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Observer(
                                                builder:
                                                    (BuildContext context) {
                                                  return TextButton(
                                                    onPressed: () {
                                                      if (!loginStore
                                                          .canLogin) {
                                                        return;
                                                      }
                                                      loginStore.login
                                                          .executeIf();
                                                    },
                                                    child: Text(
                                                      // 'Sign in',
                                                      'Masuk',
                                                      style:
                                                          TextStyle().copyWith(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      // context
                                                      //         .isDark
                                                      //     ? loginStore.canLogin
                                                      //         ? Theme.of(context)
                                                      //             .accentColor
                                                      //         : Theme.of(context)
                                                      //             .disabledColor
                                                      //     : const Color(0xffE3E3E3),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 18,
                                                        horizontal: 50,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      elevation: 5,
                                                      shadowColor:
                                                          Colors.grey[500],
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(
                                                height: 20.0,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  var _text =
                                                      urlCompanyController.text
                                                          .trim();
                                                  if (isBlank(_text)) {
                                                    pageViewController!
                                                        .jumpToPage(1);
                                                    return;
                                                  }
                                                  // Navigator.of(context).push(
                                                  //     MaterialPageRoute(builder:
                                                  //         (BuildContext context) {
                                                  //   return UserForgotPasswordScreen();
                                                  // }));
                                                },
                                                child: Text(
                                                  // 'Forgot password?',
                                                  'Belum punya akun? Daftar',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontFamily: 'Rubik',
                                                    color: Colors.blue,
                                                    // context.isDark
                                                    //     ? Theme.of(context)
                                                    //         .iconTheme
                                                    //         .color
                                                    //     : const Color(0xffE3E3E3),
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Get.to(
                                                      UserForgotPasswordScreen());
                                                  // Navigator.of(context).push(
                                                  //     MaterialPageRoute(builder:
                                                  //         (BuildContext context) {
                                                  //   return UserForgotPasswordScreen();
                                                  // }));
                                                },
                                                child: Text(
                                                  // 'Forgot password?',
                                                  'Lupa Password?',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontFamily: 'Rubik',
                                                    color: Colors.blue,
                                                    // context.isDark
                                                    //     ? Theme.of(context)
                                                    //         .iconTheme
                                                    //         .color
                                                    //     : const Color(0xffE3E3E3),
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Column(
                                  //   children: <Widget>[
                                  //     TextButton(
                                  //       onPressed: () {
                                  //         pageViewController.animateToPage(
                                  //           1,
                                  //           curve: Curves.linear,
                                  //           duration: const Duration(
                                  //             milliseconds: 200,
                                  //           ),
                                  //         );
                                  //       },
                                  //       child: RichText(
                                  //         text: TextSpan(children: [
                                  //           TextSpan(
                                  //             text: 'Not a member yet? ',
                                  //           ),
                                  //           TextSpan(
                                  //             text: 'Register here',
                                  //             style: TextStyle(
                                  //               color: Theme.of(context)
                                  //                   .accentColor,
                                  //             ),
                                  //           ),
                                  //         ]),
                                  //       ),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(10),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                              [DataState.loading]: Center(
                                child: CircularProgressIndicator(),
                              ),
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // // Register
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        top: 30,
                      ),
                      child: Observer(
                        builder: (BuildContext context) {
                          return WidgetSelector(
                            selectedState: registrationStore.state,
                            states: {
                              [DataState.none]: Stack(
                                children: <Widget>[
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: -100,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Image.asset(
                                          'images/maskot_bebras.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              35 /
                                              100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Text(
                                                'Siapa nama panggilanmu?',
                                                textAlign: TextAlign.center,
                                                // 'Enter your URL Company below',
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  color: Colors.black,
                                                  // context.isDark
                                                  //     ? Theme.of(context)
                                                  //         .iconTheme
                                                  //         .color
                                                  //     : const Color(0xffF3F8FF),
                                                  fontSize:
                                                      FontSizesWidget.of(context)!
                                                          .regular,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Builder(
                                                builder: (BuildContext context) {
                                                  final initialValue =
                                                      registrationStore
                                                          .fullname.value;
                                                  return Observer(
                                                    builder:
                                                        (BuildContext context) {
                                                      return TextFormField(
                                                        autocorrect: false,
                                                        initialValue: initialValue,
                                                        onChanged: (v) {
                                                          registrationStore.fullname
                                                              .value = v.trim();
                                                        },
                                                        decoration: InputDecoration(
                                                          border: inputBorder,
                                                          errorText:
                                                              registrationStore
                                                                  .fullname.error,
                                                          // prefixIcon: Container(
                                                          //   width: 50,
                                                          //   height: 50,
                                                          //   child: Icon(
                                                          //     Icons.person_outline,
                                                          //     color:
                                                          //         Theme.of(context)
                                                          //             .iconTheme
                                                          //             .color,
                                                          //   ),
                                                          // ),
                                                          hintText: localization!
                                                              .getByKey(
                                                            'login.placeholder.fullname',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(
                                                height: 30.0,
                                              ),
                                              Text(
                                                'Minta bantuan orang tua untuk daftar melalui email',
                                                textAlign: TextAlign.center,
                                                // 'Enter your URL Company below',
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  color: Colors.black,
                                                  // context.isDark
                                                  //     ? Theme.of(context)
                                                  //         .iconTheme
                                                  //         .color
                                                  //     : const Color(0xffF3F8FF),
                                                  fontSize:
                                                      FontSizesWidget.of(context)!
                                                          .regular,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Builder(
                                                builder: (BuildContext context) {
                                                  final initialValue =
                                                      registrationStore.email.value;
                                                  return Observer(
                                                    builder:
                                                        (BuildContext context) {
                                                      return TextFormField(
                                                        autocorrect: false,
                                                        initialValue: initialValue,
                                                        onChanged: (v) {
                                                          registrationStore.email
                                                              .value = v.trim();
                                                        },
                                                        decoration: InputDecoration(
                                                          border: inputBorder,
                                                          errorText:
                                                              registrationStore
                                                                  .email.error,
                                                          // prefixIcon: Container(
                                                          //   width: 50,
                                                          //   height: 50,
                                                          //   child: Image.asset(
                                                          //       'images/mail.png'),
                                                          // ),
                                                          hintText: localization!
                                                              .getByKey(
                                                            'login.placeholder.emailaddress',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Builder(
                                                builder: (BuildContext context) {
                                                  final initialValue =
                                                      registrationStore
                                                          .password.value;
                                                  return Observer(
                                                    builder:
                                                        (BuildContext context) {
                                                      return TextFormField(
                                                        autocorrect: false,
                                                        initialValue: initialValue,
                                                        onChanged: (v) {
                                                          registrationStore
                                                              .password.value = v;
                                                        },
                                                        obscureText:
                                                            isHiddenPassword,
                                                        decoration: InputDecoration(
                                                          border: inputBorder,
                                                          errorText:
                                                              registrationStore
                                                                  .password.error,
                                                          // prefixIcon: Container(
                                                          //   width: 50,
                                                          //   height: 50,
                                                          //   child: Image.asset(
                                                          //       'images/password.png'),
                                                          // ),
                                                          hintText: localization!
                                                              .getByKey(
                                                            'login.placeholder.password',
                                                          ),
                                                          suffixIcon:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _togglePasswordView();
                                                            },
                                                            child: Icon(
                                                              isHiddenPassword
                                                                  ? Icons.visibility
                                                                  : Icons
                                                                      .visibility_off,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Builder(
                                                builder: (BuildContext context) {
                                                  final initialValue =
                                                      registrationStore
                                                          .confirmationPassword
                                                          .value;
                                                  return Observer(
                                                    builder:
                                                        (BuildContext context) {
                                                      return TextFormField(
                                                        autocorrect: false,
                                                        initialValue: initialValue,
                                                        onChanged: (v) {
                                                          registrationStore
                                                              .confirmationPassword
                                                              .value = v;
                                                        },
                                                        obscureText:
                                                            isHiddenPassword2,
                                                        decoration: InputDecoration(
                                                          border: inputBorder,
                                                          errorText: registrationStore
                                                              .confirmationPassword
                                                              .error,
                                                          // prefixIcon: Container(
                                                          //   width: 50,
                                                          //   height: 50,
                                                          //   child: Image.asset(
                                                          //       'images/password.png'),
                                                          // ),
                                                          hintText: localization!
                                                              .getByKey(
                                                            'login.placeholder.confirmation_password',
                                                          ),
                                                          suffixIcon:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _togglePasswordView2();
                                                            },
                                                            child: Icon(
                                                              isHiddenPassword2
                                                                  ? Icons.visibility
                                                                  : Icons
                                                                      .visibility_off,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Observer(
                                                builder: (BuildContext context) {
                                                  return TextButton(
                                                    onPressed: () {
                                                      if (!registrationStore
                                                          .canRegister) {
                                                        return;
                                                      }
                                                      registrationStore.register!
                                                          .executeIf();
                                                    },
                                                    child: Text(
                                                      localization!.getByKey(
                                                        'login.button.register',
                                                      ),
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          registrationStore
                                                                  .canRegister
                                                              ? Theme.of(context)
                                                                  .accentColor
                                                              : Colors.blue,
                                                      // Theme.of(context)
                                                      //     .disabledColor,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 18,
                                                        horizontal: 50,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Column(
                                  //   children: <Widget>[
                                  //     TextButton(
                                  //       onPressed: () {
                                  //         pageViewController.animateToPage(
                                  //           0,
                                  //           curve: Curves.linear,
                                  //           duration: const Duration(
                                  //             milliseconds: 200,
                                  //           ),
                                  //         );
                                  //       },
                                  //       child: RichText(
                                  //         text: TextSpan(children: [
                                  //           TextSpan(
                                  //             text: localization.getByKey(
                                  //               'get_started.button.question.sub1',
                                  //             ),
                                  //           ),
                                  //           TextSpan(
                                  //             text: ' ' +
                                  //                 localization.getByKey(
                                  //                   'get_started.button.question.sub2',
                                  //                 ),
                                  //             style: TextStyle(
                                  //               color: Theme.of(context)
                                  //                   .accentColor,
                                  //             ),
                                  //           ),
                                  //         ]),
                                  //       ),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(10),
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                              [DataState.loading]: Center(
                                child: CircularProgressIndicator(),
                              ),
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Company sign in
                  // Container(
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(
                  //       left: 30,
                  //       right: 30,
                  //       top: 30,
                  //     ),
                  //     child: Observer(
                  //       builder: (BuildContext context) {
                  //         return WidgetSelector(
                  //           selectedState: loginStore.urlCompanyState,
                  //           states: {
                  //             [DataState.none]: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.stretch,
                  //               children: <Widget>[
                  //                 Expanded(
                  //                   child: SingleChildScrollView(
                  //                     child: Column(
                  //                       crossAxisAlignment:
                  //                           CrossAxisAlignment.stretch,
                  //                       children: <Widget>[
                  //                         Text(
                  //                           'Siapa nama panggilanmu?',
                  //                           textAlign: TextAlign.center,
                  //                           // 'Enter your URL Company below',
                  //                           style: TextStyle(
                  //                             fontFamily: 'Rubik',
                  //                             color: Colors.black,
                  //                             // context.isDark
                  //                             //     ? Theme.of(context)
                  //                             //         .iconTheme
                  //                             //         .color
                  //                             //     : const Color(0xffF3F8FF),
                  //                             fontSize:
                  //                                 FontSizesWidget.of(context)!
                  //                                     .regular,
                  //                           ),
                  //                         ),
                  //                         const SizedBox(
                  //                           height: 20,
                  //                         ),
                  //                         Observer(
                  //                           builder: (BuildContext context) {
                  //                             return TextFormField(
                  //                               autocorrect: false,
                  //                               controller: nameController,
                  //                               decoration: InputDecoration(
                  //                                 border: inputBorder,
                  //                                 // prefixIcon: Container(
                  //                                 //   width: 50,
                  //                                 //   height: 50,
                  //                                 //   child: Image.asset(
                  //                                 //     'images/ic_company.png',
                  //                                 //   ),
                  //                                 // ),
                  //                                 hintText:
                  //                                     localization!.getByKey(
                  //                                   // 'login.urlcompany.placeholder',
                  //                                   'login.placeholder.fullname',
                  //                                 ),
                  //                                 // suffixText: companySuffix,
                  //                               ),
                  //                             );
                  //                           },
                  //                         ),
                  //                         SizedBox(
                  //                           height: 55.0,
                  //                         ),
                  //                         Text(
                  //                           'Minta bantuan orang tua untuk daftar melalui email',
                  //                           textAlign: TextAlign.center,
                  //                           // 'Enter your URL Company below',
                  //                           style: TextStyle(
                  //                             fontFamily: 'Rubik',
                  //                             color: Colors.black,
                  //                             // context.isDark
                  //                             //     ? Theme.of(context)
                  //                             //         .iconTheme
                  //                             //         .color
                  //                             //     : const Color(0xffF3F8FF),
                  //                             fontSize:
                  //                                 FontSizesWidget.of(context)!
                  //                                     .regular,
                  //                           ),
                  //                         ),
                  //                         const SizedBox(
                  //                           height: 20,
                  //                         ),
                  //                         Observer(
                  //                           builder: (BuildContext context) {
                  //                             return TextFormField(
                  //                               autocorrect: false,
                  //                               controller: emailController,
                  //                               decoration: InputDecoration(
                  //                                 border: inputBorder,
                  //                                 // prefixIcon: Container(
                  //                                 //   width: 50,
                  //                                 //   height: 50,
                  //                                 //   child: Image.asset(
                  //                                 //     'images/ic_company.png',
                  //                                 //   ),
                  //                                 // ),
                  //                                 hintText:
                  //                                     localization!.getByKey(
                  //                                   'login.placeholder.emailaddress',
                  //                                 ),
                  //                                 // suffixText: companySuffix,
                  //                               ),
                  //                             );
                  //                           },
                  //                         ),
                  //                         SizedBox(
                  //                           height: 20,
                  //                         ),
                  //                         Observer(
                  //                           builder: (BuildContext context) {
                  //                             return TextFormField(
                  //                               autocorrect: false,
                  //                               controller: passwordController,
                  //                               obscureText: isHiddenPassword2,
                  //                               decoration: InputDecoration(
                  //                                 border: inputBorder,
                  //                                 // prefixIcon: Container(
                  //                                 //   width: 50,
                  //                                 //   height: 50,
                  //                                 //   child: Image.asset(
                  //                                 //     'images/ic_company.png',
                  //                                 //   ),
                  //                                 // ),
                  //                                 hintText:
                  //                                     localization!.getByKey(
                  //                                   'login.placeholder.password',
                  //                                 ),
                  //                                 // suffixText: companySuffix,
                  //                                 suffixIcon: GestureDetector(
                  //                                   onTap: () {
                  //                                     _togglePasswordView2();
                  //                                   },
                  //                                   child: Icon(
                  //                                     isHiddenPassword2
                  //                                         ? Icons.visibility
                  //                                         : Icons
                  //                                             .visibility_off,
                  //                                     color: Colors.white,
                  //                                   ),
                  //                                 ),
                  //                               ),
                  //                             );
                  //                           },
                  //                         ),
                  //                         SizedBox(
                  //                           height: 20,
                  //                         ),
                  //                         Observer(
                  //                           builder: (BuildContext context) {
                  //                             return TextFormField(
                  //                               autocorrect: false,
                  //                               controller: cPasswordController,
                  //                               obscureText: isHiddenPassword,
                  //                               decoration: InputDecoration(
                  //                                 border: inputBorder,
                  //                                 // prefixIcon: Container(
                  //                                 //   width: 50,
                  //                                 //   height: 50,
                  //                                 //   child: Image.asset(
                  //                                 //     'images/ic_company.png',
                  //                                 //   ),
                  //                                 // ),
                  //                                 hintText:
                  //                                     localization!.getByKey(
                  //                                   'login.placeholder.confirmation_password',
                  //                                 ),
                  //                                 suffixIcon: GestureDetector(
                  //                                   onTap: () {
                  //                                     _togglePasswordView();
                  //                                   },
                  //                                   child: Icon(
                  //                                     isHiddenPassword
                  //                                         ? Icons.visibility
                  //                                         : Icons
                  //                                             .visibility_off,
                  //                                     color: Colors.white,
                  //                                   ),
                  //                                 ),
                  //                                 // suffixText: companySuffix,
                  //                               ),
                  //                             );
                  //                           },
                  //                         ),
                  //                         const SizedBox(
                  //                           height: 20,
                  //                         ),
                  //                         TextButton(
                  //                           onPressed: () {
                  //                             var _text = urlCompanyController
                  //                                     .text
                  //                                     ?.trim() ??
                  //                                 '';
                  //                             if (isBlank(_text)) {
                  //                               pageViewController!
                  //                                   .jumpToPage(0);
                  //                               return;
                  //                             }
                  //                             loginStore.urlCompany = _text;
                  //                             loginStore.verifyCompany
                  //                                 .executeIf()
                  //                                 .then((value) {
                  //                               pageViewController!
                  //                                   .jumpToPage(0);
                  //                             });
                  //                           },
                  //                           child: Text(
                  //                             'Daftar',
                  //                             style: TextStyle().copyWith(
                  //                               color: Colors.white,
                  //                             ),
                  //                           ),
                  //                           style: TextButton.styleFrom(
                  //                             backgroundColor: Colors.blue,
                  //                             // context.isDark
                  //                             //     ? Theme.of(context)
                  //                             //         .accentColor
                  //                             //     : const Color(0xffF3F8FF),
                  //                             padding:
                  //                                 const EdgeInsets.symmetric(
                  //                               vertical: 18,
                  //                               horizontal: 50,
                  //                             ),
                  //                             shape: RoundedRectangleBorder(
                  //                               borderRadius:
                  //                                   BorderRadius.circular(10),
                  //                             ),
                  //                           ),
                  //                         ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 20,
                  //   ),
                  //   child: SvgPicture.asset(
                  //     'images/bebras_image.svg',
                  //     height: MediaQuery.of(context)
                  //             .size
                  //             .height *
                  //         35 /
                  //         100,
                  //     width: MediaQuery.of(context)
                  //         .size
                  //         .width,
                  //   ),
                  // ),

                  // Find company
                  // Column(
                  //   crossAxisAlignment:
                  //       CrossAxisAlignment.stretch,
                  //   children: [
                  //     Text(
                  //       "Don't know your URL?",
                  //       style: TextStyle(
                  //         color: context.isDark
                  //             ? Theme.of(context)
                  //                 .iconTheme
                  //                 .color
                  //             : const Color(0xffF3F8FF),
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //     TextButton(
                  //       onPressed: () {
                  //         Get.toNamed('/findcompany');
                  //         // Navigator.of(context)
                  //         //     .pushNamed(
                  //         //   '/findcompany',
                  //         // );
                  //       },
                  //       child: Text(
                  //         'Find your company here',
                  //         style: TextStyle(
                  //           decoration: TextDecoration
                  //               .underline,
                  //           fontFamily: 'Rubik',
                  //           color: context.isDark
                  //               ? Theme.of(context)
                  //                   .iconTheme
                  //                   .color
                  //               : const Color(
                  //                   0xffF3F8FF),
                  //         ),
                  //       ),
                  //       style: TextButton.styleFrom(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius:
                  //               BorderRadius.circular(
                  //                   10),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //             [DataState.loading]: Center(
                  //               child: CircularProgressIndicator(),
                  //             ),
                  //           },
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      // backgroundColor: Theme.of(context).canvasColor,
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () {
          return _onWillPop() as Future<bool>;
        },
        child: content,
      ),
    );
  }
}
