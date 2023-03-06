import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/disposable.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserChangePasswordScreen extends HookWidget {
  final bool fromIsFirstTimeUser;
  const UserChangePasswordScreen({
    Key? key,
    this.fromIsFirstTimeUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Disposable d;
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profileStore = Provider.of<UserProfileStore>(
          context,
          listen: false,
        );
        d = profileStore.changePasswordInteraction.registerHandler((f) {
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
      return () {
        d.dispose();
      };
    }, const []);

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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Change Password'),
        leading: fromIsFirstTimeUser != true
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Get.back();
                  // Navigator.of(context).pop();
                },
              )
            : null,
      ),
      body: Stack(
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
                    selectedState: profileStore.forgotPasswordState,
                    states: {
                      [DataState.success]: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Builder(
                                    builder: (BuildContext context) {
                                      var initalValue =
                                          profileStore.currentPassword;
                                      return Observer(
                                        builder: (BuildContext context) {
                                          return TextFormField(
                                            onChanged: (v) {
                                              profileStore.currentPassword = v;
                                            },
                                            autocorrect: false,
                                            initialValue: initalValue,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              border: inputBorder,
                                              prefixIcon: Container(
                                                height: 50,
                                                width: 50,
                                                child: Image.asset(
                                                    'images/password.png'),
                                              ),
                                              hintText: 'Current password',
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
                                          profileStore.newPassword;
                                      return Observer(
                                        builder: (BuildContext context) {
                                          return TextFormField(
                                            onChanged: (v) {
                                              profileStore.newPassword = v;
                                            },
                                            obscureText: true,
                                            autocorrect: false,
                                            initialValue: initialValue,
                                            decoration: InputDecoration(
                                              border: inputBorder,
                                              prefixIcon: Container(
                                                width: 50,
                                                height: 50,
                                                child: Image.asset(
                                                  'images/password.png',
                                                ),
                                              ),
                                              hintText: 'New password',
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
                                          profileStore.confirmNewPassword;
                                      return Observer(
                                        builder: (BuildContext context) {
                                          return TextFormField(
                                            onChanged: (v) {
                                              profileStore.confirmNewPassword =
                                                  v;
                                            },
                                            obscureText: true,
                                            autocorrect: false,
                                            initialValue: initialValue,
                                            decoration: InputDecoration(
                                              border: inputBorder,
                                              prefixIcon: Container(
                                                width: 50,
                                                height: 50,
                                                child: Image.asset(
                                                  'images/password.png',
                                                ),
                                              ),
                                              hintText: 'Confirm New password',
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
                                          profileStore.changePassword
                                              .executeIf(fromIsFirstTimeUser);
                                        },
                                        child: Text(
                                          'Change Password',
                                          style: TextStyle(
                                            color: context.isLight
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).accentColor,
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
      ),
    );
  }
}
