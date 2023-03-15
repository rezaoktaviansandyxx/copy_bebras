import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/screens/faq/faq_detail_screen.dart';
import 'package:fluxmobileapp/screens/faq/faq_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/widgets/curve_widget.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';

class FaqScreen extends HookWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = useMemoized(
      (() => sl.get<ILocalizationService>()!) as ILocalizationService
          Function(),
    );
    final store = useMemoized(() => FaqStore());

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        store.faqFilter.searchKeyword = '';
        store.faqFilter = store.faqFilter;
      });
      return () {};
    }, const []);

    final backgroundColor = Theme.of(context).canvasColor;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppBar(
          backgroundColor: context.isLight ? Colors.transparent : null,
          centerTitle: true,
          iconTheme: context.isLight
              ? IconThemeData(
                  color: Colors.white,
                )
              : null,
          title: Text(
            localization.getByKey('faq.title'),
            style: context.isLight
                ? TextStyle(
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        Container(
          color: context.isDark ? backgroundColor : null,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // const SizedBox(
                //   height: 20,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: TextField(
                    onChanged: (v) {
                      store.faqFilter.searchKeyword = v?.trim();
                      store.faqFilter = store.faqFilter;
                    },
                    autofocus: false,
                    style: TextStyle().copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                        borderSide: context.isDark
                            ? BorderSide.none
                            : BorderSide(
                                color: const Color(0xffC7D3E3),
                                width: 1,
                              ),
                      ),
                      fillColor:
                          context.isLight ? const Color(0xffEDF3FC) : null,
                      hintText: localization.getByKey(
                        'faq.searchfaq',
                      ),
                      suffixIcon: Icon(
                        Icons.search,
                        size: 24,
                        color: Theme.of(context).textTheme.headline4!.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Observer(
            builder: (context) {
              return WidgetSelector(
                maintainState: true,
                selectedState: store.faqsState,
                states: {
                  [DataState.success]: ListView.separated(
                    itemCount: store.faqs.length,
                    addAutomaticKeepAlives: true,
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (BuildContext context, int index) {
                      final item = store.faqs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return FaqDetailScreen(
                              selectedFaqModelIndex: index,
                              store: store,
                            );
                          }));
                        },
                        title: Text(
                          item.question!,
                          style: context.isLight
                              ? TextStyle(
                                  color: Colors.black,
                                )
                              : null,
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 1,
                        color: AppTheme.of(context).canvasColorLevel3,
                      );
                    },
                  ),
                  [DataState.loading]: const Center(
                    child: const CircularProgressIndicator(),
                  ),
                  [DataState.error]: Center(
                    child: ErrorDataWidget(
                      text: store.faqsState?.message ?? '',
                    ),
                  ),
                  [DataState.empty]: Center(
                    child: ErrorDataWidget(
                      text: localization.getByKey(
                        'common.empty',
                      ),
                    ),
                  ),
                  [DataState.none]: const SizedBox()
                },
              );
            },
          ),
        ),
      ],
    );

    return Container(
      color: context.isLight ? const Color(0xffF3F8FF) : null,
      child: Stack(
        children: [
          AppClipPath(
            height: 150,
          ),
          Scaffold(
            backgroundColor: context.isLight ? Colors.transparent : null,
            body: content,
          ),
        ],
      ),
    );
  }
}
