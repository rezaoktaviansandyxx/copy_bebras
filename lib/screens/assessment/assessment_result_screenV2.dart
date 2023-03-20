import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';

class SplashScreeenAssessment extends HookWidget {
  final AssessmentModel? assessment;
  const SplashScreeenAssessment({Key? key, required this.assessment})
      : super(key: key);

  splashscreenStart() async {
    var duration = const Duration(milliseconds: 3000);
    return Timer(duration, () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    splashscreenStart();
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
                          fontSize: 30,
                          fontFamily: 'Quicksand'
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
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${(assessment!.totalScore / 6 * 100).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 30,
                          color: Color(0XFF00ADEE),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        '${assessment!.totalScore.toStringAsFixed(0)} Correct Out of ${assessment!.questions!.length} Questions',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0XFFB5B5B5), fontSize: 16),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Congratulation!',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Congratulations, you have successfully completed the Quiz!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0XFFB5B5B5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
