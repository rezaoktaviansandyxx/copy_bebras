import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserForgotPasswordScreen extends StatefulWidget {
  UserForgotPasswordScreen({Key? key}) : super(key: key);

  _UserForgotPasswordScreenState createState() =>
      _UserForgotPasswordScreenState();
}

class _UserForgotPasswordScreenState extends State<UserForgotPasswordScreen> {
  late Disposable d;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileStore = Provider.of<UserProfileStore>(
        context,
        listen: false,
      );
      d = profileStore.forgotPasswordInteraction.registerHandler((f) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(f!),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Get.back();
                    // Navigator.of(context).pop();
                  },
                  child: Text('Ok'),
                )
              ],
            );
          },
        );
        return Future.value(null);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    d.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileStore = Provider.of<UserProfileStore>(
      context,
      listen: false,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        10,
      ),
      borderSide: BorderSide.none,
    );

    final content = Stack(
      children: <Widget>[
        CustomPaint(
          child: Container(
            height: 150,
          ),
          painter: CurveWidget(
            color: Color(0XFF00ADEE).withOpacity(
              0.25,
            ),
            // Theme.of(context).appBarTheme.color,
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
            ),
            child: SvgPicture.asset(
              'images/logo_bebras.svg',
              height: 70,
            ),
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 40,
            ),
            child: Observer(
              builder: (BuildContext context) {
                return WidgetSelector(
                  selectedState: profileStore.forgotPasswordState,
                  states: {
                    [DataState.success]: Stack(
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
                              child: SvgPicture.asset(
                                'images/maskot_bebras.svg',
                                height: MediaQuery.of(context).size.height *
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
                                    SizedBox(
                                      height: 105.0,
                                    ),
                                    Builder(
                                      builder: (BuildContext context) {
                                        var initalValue =
                                            profileStore.forgotPasswordEmail;
                                        return Observer(
                                          builder: (BuildContext context) {
                                            return TextFormField(
                                              onChanged: (v) {
                                                profileStore
                                                        .forgotPasswordEmail =
                                                    v.trim();
                                              },
                                              autocorrect: false,
                                              initialValue: initalValue,
                                              decoration: InputDecoration(
                                                border: inputBorder,
                                                // prefixIcon: Container(
                                                //   height: 50,
                                                //   width: 50,
                                                //   child: Image.asset(
                                                //       'images/mail.png'),
                                                // ),
                                                hintText: 'Email kamu',
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
                                            profileStore.forgotPassword
                                                .executeIf();
                                          },
                                          child: Text(
                                            'Kirim',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            // context.isDark
                                            //     ? Theme.of(context).accentColor
                                            //     : const Color(0xffF3F8FF),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                              horizontal: 50,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                      ],
                    ),
                    [DataState.loading]: const Center(
                      child: const CircularProgressIndicator(),
                    ),
                  },
                );
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Get.back();
            // Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: content,
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
      ),
    );
  }
}
