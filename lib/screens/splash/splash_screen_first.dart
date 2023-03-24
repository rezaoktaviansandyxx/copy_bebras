import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({Key? key}) : super(key: key);

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2> {
  @override
  void initState() {
    super.initState();
    splashscreenStart();
  }

  splashscreenStart() async {
    var duration = const Duration(milliseconds: 3000);
    return Timer(duration, () {
      Get.toNamed('/splash_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0XFF00ADEE).withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'images/maskot_bebras.svg',
                fit: BoxFit.fitWidth,
                height: MediaQuery.of(context).size.height * 45 / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
