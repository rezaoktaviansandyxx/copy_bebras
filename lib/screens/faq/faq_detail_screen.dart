import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/faq/faq_store.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';

class FaqDetailScreen extends HookWidget {
  final FaqStore store;
  final int selectedFaqModelIndex;

  const FaqDetailScreen({
    Key? key,
    required this.store,
    required this.selectedFaqModelIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).canvasColor;

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        store.getDetailFaq.execute(selectedFaqModelIndex);
      });
      return () {};
    }, const []);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppBar(), // To show back button
        Expanded(
          child: Observer(
            builder: (context) {
              final detail = store.detailFaq;

              return WidgetSelector<DataState>(
                maintainState: true,
                selectedState: store.faqsState,
                states: {
                  [DataState.success]: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          color: backgroundColor,
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    detail?.question ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          child: Text(
                            detail?.answer ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  [DataState.loading]: const Center(
                    child: const CircularProgressIndicator(),
                  ),
                  [DataState.error]: ErrorDataWidget(
                    text: store.detailFaqState?.message ?? '',
                  ),
                  [DataState.none]: const SizedBox()
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
