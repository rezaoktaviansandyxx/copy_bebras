import 'package:flutter/material.dart';
import 'package:fluxmobileapp/baselib/base_widgetparameter_mixin.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:get/get.dart';

class UserRegisteredSuccessScreen extends StatefulWidget
    with BaseWidgetParameterMixin {
  UserRegisteredSuccessScreen({Key? key}) : super(key: key);

  _UserRegisteredSuccessScreenState createState() =>
      _UserRegisteredSuccessScreenState();
}

class _UserRegisteredSuccessScreenState
    extends State<UserRegisteredSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Image.asset(
                      'images/bg_bullet.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).canvasColorLevel3,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            padding: const EdgeInsets.all(25),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Image.asset(
                                  'images/ic_thumb_up.png',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const SizedBox(height: 15),
                                Text(
                                  'Congratulations',
                                  style: TextStyle(
                                    fontSize:
                                        FontSizesWidget.of(context)!.large,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Your account has registered as member Anugra',
                                  style: TextStyle(
                                    fontSize:
                                        FontSizesWidget.of(context)!.regular,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  textAlign: TextAlign.center,
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
            ),
            Padding(
              padding: const EdgeInsets.all(
                15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/');
                      // Navigator.of(context).pushNamed('/');
                    },
                    child: Text(
                      'Go To Homepage',
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).accentColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
