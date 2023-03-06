import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/find_url_company/find_url_company_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/widget_utils.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';

class FindUrlCompanyScreen extends HookWidget {
  const FindUrlCompanyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useMemoized(() => FindUrlCompanyStore());
    final localization = useMemoized((() => sl.get<ILocalizationService>()!)
        as ILocalizationService Function());

    useEffect(() {
      final d = store.alertInteraction.registerHandler((value) async {
        final result = await createAlertDialog(value, context);
        return result;
      });
      return () {
        d.dispose();
      };
    }, const []);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        10,
      ),
      borderSide: BorderSide.none,
    );

    final content = SafeArea(
      top: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            children: <Widget>[
              CustomPaint(
                child: Container(
                  height: 150,
                ),
                painter: CurveWidget(
                  color: Theme.of(context).appBarTheme.color,
                ),
              ),
              AppBar(
                centerTitle: true,
                title: Text(
                  'Find Company',
                  style: context.isLight
                      ? TextStyle(
                          color: Theme.of(context)
                              .appBarTheme
                              .textTheme!
                              .headline6!
                              .color,
                        )
                      : null,
                ),
              )
            ],
          ),
          Expanded(
            child: WidgetSelector(
              selectedState: store.state,
              maintainState: true,
              states: {
                [DataState.none]: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Enter your email address, You will receive your url company in your inbox',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            color: context.isDark
                                ? Theme.of(context).iconTheme.color
                                : const Color(0xffF3F8FF),
                            fontSize: FontSizesWidget.of(context)!.regular,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          autocorrect: false,
                          autofocus: false,
                          onChanged: (v) {
                            store.email = v.trim();
                          },
                          decoration: InputDecoration(
                            border: inputBorder,
                            prefixIcon: Container(
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                'images/mail.png',
                              ),
                            ),
                            hintText: localization.getByKey(
                              'login.placeholder.emailaddress',
                            ),
                          ),
                          style: TextStyle(
                            color: context.isLight
                                ? const Color(0xffE3E3E3)
                                : null,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          onPressed: () {
                            store.sendUrlCompany.executeIf();
                          },
                          child: Text(
                            'Send',
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: context.isDark
                                ? Theme.of(context).accentColor
                                : const Color(0xffF3F8FF),
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 50,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                [DataState.loading]: const Center(
                  child: const CircularProgressIndicator(),
                ),
              },
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: content,
        decoration: AppTheme.of(context).gradientBgColor != null
            ? BoxDecoration(
                gradient: LinearGradient(
                  transform: GradientRotation(
                    360,
                  ),
                  colors: [
                    AppTheme.of(context).gradientBgColor!.item1,
                    AppTheme.of(context).gradientBgColor!.item2,
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
