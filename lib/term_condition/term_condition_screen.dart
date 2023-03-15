import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/models/models.dart';
import 'package:fluxmobileapp/term_condition/term_condition_store.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';

class TermConditionScreen extends HookWidget {
  final TermConditionType? termConditionType;

  const TermConditionScreen({
    Key? key,
    required this.termConditionType,
  }) : super(key: key);

  String getHtml(BuildContext context, TermConditionModel model) {
    final style = context.isDark
        ? '''body {
  color: white;
}'''
        : '';
    final html = """
    <!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <title>Page Title</title>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <style>
    $style
    </style>
</head>
<body>
${model.content}
</body>
</html>
    """;
    return html;
  }

  @override
  Widget build(BuildContext context) {
    final localization = useMemoized(
      () => sl.get<ILocalizationService>(),
    );
    final store = useMemoized(() => TermConditionStore());

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        store.getTermCondition.executeIf(termConditionType);
      });
      return () {};
    }, const []);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppBar(
          title: Observer(
            builder: (BuildContext context) {
              return Text(
                store.termCondition?.title ?? '',
              );
            },
          ),
        ),
        Expanded(
          child: Observer(
            builder: (context) {
              return WidgetSelector(
                maintainState: true,
                selectedState: store.getDataState,
                states: {
                  [DataState.success]: Observer(
                    builder: (BuildContext context) {
                      if (store.termCondition == null) {
                        return const SizedBox();
                      }

                      return InAppWebView(
                        initialData: InAppWebViewInitialData(
                          data: getHtml(
                            context,
                            store.termCondition!,
                          ),
                        ),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            transparentBackground: true,
                          ),
                        ),
                      );
                    },
                  ),
                  [DataState.loading]: const Center(
                    child: const CircularProgressIndicator(),
                  ),
                  [DataState.error]: Center(
                    child: ErrorDataWidget(
                      text: store.getDataState?.message ?? '',
                    ),
                  ),
                  [DataState.empty]: Center(
                    child: ErrorDataWidget(
                      text: localization!.getByKey(
                        'common.empty',
                      ),
                    ),
                  ),
                  [DataState.none]: const SizedBox(),
                },
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      body: content,
    );
  }
}
