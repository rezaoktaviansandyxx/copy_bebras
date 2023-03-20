import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';

class SplashScreeenAssessment extends StatefulWidget {
  const SplashScreeenAssessment({Key? key}) : super(key: key);

  @override
  State<SplashScreeenAssessment> createState() =>
      _SplashScreeenAssessmentState();
}

class _SplashScreeenAssessmentState extends State<SplashScreeenAssessment> {
  @override
  void initState() {
    super.initState();
    splashscreenStart();
  }

  splashscreenStart() async {
    var duration = const Duration(milliseconds: 5000);
    return Timer(duration, () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AppClipPath(
                height: 140,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Good Job',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0XFF00ADEE),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 10 / 100,
                      ),
                      Image.asset(
                        'images/bebras/bebras_result.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 35 / 100,
                      ),
                      // Text(
                        
                      //   style: TextStyle(
                      //     fontSize: 30,
                      //     color: Color(0XFF00ADEE),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          )
          // Image.asset(
          //   'images/bebras/assessment_result.png',
          //   fit: BoxFit.fitWidth,
          //   height: MediaQuery.of(context).size.height * 45 / 100,
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Text(
          //   '${assessmentModel.}',
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Color(0XFF00ADEE),
          //   ),
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Text(
          //   '6 Correct Out of 6 Questions',
          //   style: TextStyle(
          //     color: Color(0XFFB5B5B5),
          //   ),
          // ),
          // Column(
          //   children: [
          //     Text(
          //       'Congratulation!',
          //       style: TextStyle(
          //           color: Colors.black,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 20),
          //     ),
          //     Text(
          //       'Congratulations, you have successfully completed the Quiz!',
          //       style: TextStyle(
          //         color: Color(0XFFB5B5B5),
          //         fontSize: 16,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
