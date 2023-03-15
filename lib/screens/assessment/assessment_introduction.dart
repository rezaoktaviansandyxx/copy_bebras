import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/baselib/base_state_mixin.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/assessment/assessment_question.dart';
import 'package:fluxmobileapp/services/secure_storage.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:mobx/src/api/observable_collections.dart';
import '../../appsettings.dart';
import './assessment_store.dart';

class AssessmentIntroduction extends HookWidget {
  final AssessmentStore? store;
  final Map parameters;

  const AssessmentIntroduction({
    Key? key,
    this.store,
    this.parameters = const {},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appServices = useMemoized(() => sl.get<AppServices>());
    final secureStorage = useMemoized(() => sl.get<SecureStorage>());
    final store = useMemoized(
      () {
        return this.store ?? AssessmentStore();
      },
      [this.store],
    );

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        store.getAssessment.executeIf(
          parameters['assessmentId'],
        );
      });
      return () {};
    }, const []);

    return Scaffold(
      body: Observer(
        builder: (BuildContext context) {
          return WidgetSelector(
            maintainState: true,
            selectedState: store.state,
            states: {
              [DataState.loading]: Center(
                child: CircularProgressIndicator(),
              ),
              [DataState.error]: ErrorDataWidget(
                text: store.state.message ?? '',
                onReload: () {
                  store.getAssessment.executeIf();
                },
              ),
              [DataState.success]: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      child: AppClipPath(),
                    ),
                  ),
                  Positioned.fill(
                    child: Observer(
                      builder: (context) {
                        final assessmentItems =
                            store.indexingAssessmentStore.items;
                        if (assessmentItems.isEmpty) {
                          return const SizedBox();
                        }

                        Iterable<Widget> _listAssessments(
                          BuildContext contex,
                          ObservableList<AssessmentModel?> assessmentItems,
                        ) sync* {
                          for (var assessmentItem in assessmentItems) {
                            if (assessmentItem == null) {
                              continue;
                            }

                            yield Text(
                              assessmentItem.title ?? '',
                              style: TextStyle(
                                fontSize: FontSizes.large,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                            yield const SizedBox(height: 15);
                            yield Text(
                              assessmentItem.description ?? '',
                              style: TextStyle(
                                fontSize: FontSizes.regular,
                              ),
                            );
                            yield const SizedBox(height: 10);
                            yield ButtonTheme(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 15,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextButton(
                                      onPressed: () async {
                                        final int? assessmentIndex = store
                                            .indexingAssessmentStore.items
                                            .indexWhere(
                                          (e) => e?.id == assessmentItem.id,
                                        );
                                        if (assessmentIndex == null ||
                                            assessmentIndex < 0) {
                                          return;
                                        }
                                        store.goToAssessment(assessmentIndex);
                                        appServices!.navigatorState!.pushNamed(
                                          '/assessment_question',
                                          arguments: {'store': store},
                                        );
                                      },
                                      child: Text(
                                        'Start Self Assessment',
                                        style: TextStyle(
                                          color: context.isLight
                                              ? Colors.white
                                              : null,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            Theme.of(context).accentColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            yield const SizedBox(height: 15);
                          }
                        }

                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  AppBar(
                                    centerTitle: true,
                                    backgroundColor: context.isLight
                                        ? Colors.transparent
                                        : null,
                                    iconTheme: IconThemeData(
                                      color:
                                          context.isLight ? Colors.white : null,
                                    ),
                                    title: Text(
                                      store.userProfile!.fullname??'',
                                      style: TextStyle(
                                        fontSize: FontSizes.large,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            context.isLight ? Colors.white : null,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 30,
                                    ),
                                    child: Image.asset(
                                      'images/maskot_bebras.png',
                                      fit: BoxFit.fitHeight,
                                      height: MediaQuery.of(context).size.height *
                                          30 /
                                          100,
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[]..addAll(
                                            _listAssessments(
                                              context,
                                              assessmentItems,
                                            ),
                                          ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}
