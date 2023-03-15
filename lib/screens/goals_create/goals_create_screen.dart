import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/goals_create/goals_create_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:get/get.dart';

import '../../appsettings.dart';

class GoalsCreateScreen extends StatefulWidget {
  GoalsCreateScreen({
    Key? key,
  }) : super(key: key);

  _GoalsCreateScreen createState() => _GoalsCreateScreen();
}

class _GoalsCreateScreen extends State<GoalsCreateScreen>
    with BaseStateMixin<GoalsCreateStore, GoalsCreateScreen> {
  final appServices = sl.get<AppServices>();
  final localization = sl.get<ILocalizationService>();

  final _store = GoalsCreateStore();
  @override
  GoalsCreateStore get store => _store;

  @override
  void initState() {
    super.initState();

    {
      final d = store.alertInteraction.registerHandler((value) async {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(value!),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.back();
                      // appServices!.navigatorState!.pop();
                    },
                    child: Text('Ok'),
                  ),
                ],
              );
            });
        return null;
      });
      store.registerDispose(() {
        d.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              centerTitle: true,
              backgroundColor: context.isLight ? Colors.transparent : null,
              title: Text(
                'Create Goals',
                style: context.isLight
                    ? TextStyle(
                        color: Colors.white,
                      )
                    : null,
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: context.isLight ? Colors.white : null,
                ),
                onPressed: () {
                  Get.back();
                  // appServices!.navigatorState!.pop();
                },
              ),
            ),
            body: Observer(
              builder: (BuildContext context) {
                return WidgetSelector(
                  selectedState: store.state,
                  states: {
                    [DataState.none]: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 50,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                // Name
                                Text(
                                  'SET GOAL NAME',
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Set specific goal name to let you achieve it',
                                  style: TextStyle(
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Builder(
                                  builder: (BuildContext context) {
                                    final initial = store.goalName ?? '';
                                    return TextFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        fillColor: context.isLight
                                            ? const Color(0xffE6F0FF)
                                            : null,
                                      ),
                                      style: context.isLight
                                          ? TextStyle(
                                              color: Colors.black,
                                            )
                                          : null,
                                      textInputAction: TextInputAction.next,
                                      initialValue: initial,
                                      onFieldSubmitted: (v) {
                                        FocusScope.of(context).nextFocus();
                                      },
                                      onChanged: (v) {
                                        store.goalName = v?.trim();
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 30),

                                // Description
                                Text(
                                  'GOAL DESCRIPTION',
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Give the reason "Why you pursuing this goal"',
                                  style: TextStyle(
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Builder(
                                  builder: (BuildContext context) {
                                    final initial = store.goalDescription ?? '';
                                    return TextFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        fillColor: context.isLight
                                            ? const Color(0xffE6F0FF)
                                            : null,
                                      ),
                                      style: context.isLight
                                          ? TextStyle(
                                              color: Colors.black,
                                            )
                                          : null,
                                      initialValue: initial,
                                      textInputAction: TextInputAction.newline,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      onFieldSubmitted: (v) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      onChanged: (v) {
                                        store.goalDescription = v?.trim();
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                TextButton(
                                  onPressed: () {
                                    store.createNewGoal.executeIf();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                    ),
                                    backgroundColor:
                                        AppTheme.of(context).okButtonColor,
                                  ),
                                  child: Text(
                                    'Create Goals Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          FontSizesWidget.of(context)!.regular,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    [DataState.loading]: Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
