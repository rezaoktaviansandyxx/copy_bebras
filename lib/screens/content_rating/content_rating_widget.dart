import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/api_services/api_services_models.dart';
import 'package:fluxmobileapp/screens/content_rating/content_rating_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/widget_utils.dart';

class ContentRatingWidget extends HookWidget {
  final String title;
  final RateContentRequest request;
  final Function? onRated;

  const ContentRatingWidget({
    Key? key,
    required this.title,
    required this.request,
    this.onRated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useMemoized(() => ContentRatingStore());

    useEffect(() {
      final d = store.alertInteraction.registerHandler((value) {
        return createAlertDialog(value, context)
            .then((value) => value as bool?);
      });
      return () {
        d.dispose();
      };
    }, const []);

    return Container(
      padding: const EdgeInsets.all(15),
      color: context.isLight
          ? const Color(0xffE7EFF9)
          : AppTheme.of(context).canvasColor4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title ?? '',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              color: context.isLight ? const Color(0xff1B304D) : null,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Send your ratings here',
            style: TextStyle(
              fontSize: 12,
              color:
                  context.isLight ? const Color(0xff1B304D) : Color(0xff9FADBF),
            ),
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            child: Observer(
              builder: (context) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 5; i++)
                      GestureDetector(
                        onTap: () {
                          final _request = RateContentRequest()
                            ..contentType = request.contentType
                            ..id = request.id
                            ..rating = i + 1;
                          store.rateContent
                              .executeIf(
                            _request,
                          )
                              .then((value) {
                            if (onRated != null) {
                              onRated!();
                            }
                          });
                        },
                        child: store.rating.value! > i
                            ? Icon(
                                Icons.star,
                                color: Color(0xffECCF71),
                                size: 28,
                              )
                            : Icon(
                                Icons.star_border,
                                size: 28,
                              ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
