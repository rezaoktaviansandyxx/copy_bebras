import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/stores/user_profile_store.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'splash_store.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _store = SplashStore();
  SplashStore get store => _store;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.initialize.executeIf();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Observer(
          builder: (BuildContext context) {
            return WidgetSelector(
              selectedState: store.dataState,
              states: {
                [DataState.loading]: Container(
                  color: Color(0XFF00ADEE).withOpacity(0.5),
                  child: Center(
                    child: Image.asset(
                      'images/maskot_bebras.png',
                      fit: BoxFit.fitWidth,
                      height: MediaQuery.of(context).size.height * 45 / 100,
                    ),
                  ),
                ),
                // Container(
                //   child: const Center(
                //     child: const CircularProgressIndicator(),
                //   ),
                // ),
                [DataState.error]: Container(
                  child: Center(
                    child: ErrorDataWidget(
                      text: store.dataState.message ?? '',
                      onReload: () {
                        store.initialize.executeIf();
                      },
                      onLogout: () {
                        final userProfileStore = sl.get<UserProfileStore>()!;
                        userProfileStore.logout.executeIf();
                      },
                    ),
                  ),
                ),
              },
            );
          },
        ),
      ),
    );
  }
}
