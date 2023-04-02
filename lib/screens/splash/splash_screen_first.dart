import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluxmobileapp/components/splash_screen.dart';
import 'package:get/get.dart';

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({Key? key}) : super(key: key);

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashScreen(
        seconds: 3,
        navigateAfterSeconds: '/splash_screen',
        image: 'images/maskot_bebras.svg',
        backgroundColor: Color(0XFF00ADEE).withOpacity(0.25),
        loadingText: Text('Sedang Memuat'),
        loaderColor: Colors.blue.shade800,
        styleTextUnderTheLoader: TextStyle(
            fontFamily: 'Quicksand',
            color: Colors.black,
            fontWeight: FontWeight.w600),
        useLoader: true,
      ),
    );
  }
}
