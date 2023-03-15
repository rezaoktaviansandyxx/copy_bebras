import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluxmobileapp/baselib/widgets.dart';
import 'package:fluxmobileapp/related_detail_content/related_detail_content_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/widgets/error_widget.dart';
import 'package:fluxmobileapp/widgets/session_item_widget.dart';

class RelatedDetailContentScreen extends HookWidget {
  final String? contentId;
  const RelatedDetailContentScreen({
    Key? key,
    required this.contentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useMemoized(() => RelatedDetailContentStore());

    useEffect(() {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        store.getRelatedContent.executeIf(contentId);
      });
      return () {};
    }, [contentId]);

    final mediaQuery = MediaQuery.of(context);
    final double itemWidth = (mediaQuery.size.width - 85);
    final double listHeight = 225;

    return Observer(
      builder: (context) {
        if (store.listRelatedContent.isEmpty) {
          return const SizedBox();
        }

        return Container(
          color: AppTheme.of(context).canvasColorLevel2,
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Related Content',
                        style: AppTheme.of(context).sectionTitle,
                      ),
                    ),
                  ],
                ),
              ),
              Observer(
                builder: (BuildContext context) {
                  return WidgetSelector(
                    selectedState: store.getDataState,
                    states: {
                      [DataState.success]: SizedBox(
                        height: listHeight,
                        child: ListView.builder(
                          itemCount: store.listRelatedContent.length,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 5,
                          ),
                          addAutomaticKeepAlives: true,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final item = store.listRelatedContent[index];

                            return InkWell(
                              onTap: () {
                                store.goToDetail.executeIf(item);
                              },
                              child: AspectRatio(
                                aspectRatio: listHeight / (listHeight + 100),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    10,
                                  ),
                                  child: SessionItemWidget(
                                    item: SessionItem()
                                      ..author = item.author
                                      ..imageThumbnail = item.imageThumbnail
                                      ..rating = item.rating
                                      ..totalUserRate = item.totalUserRate
                                      ..title = item.title
                                      ..category = item.type
                                      ..tag = item.tags,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      [DataState.loading]: SizedBox(
                        height: listHeight,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      [DataState.error]: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ErrorDataWidget(
                          text: store.getDataState.message ?? '',
                        ),
                      ),
                      [DataState.empty]: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ErrorDataWidget(
                          text: 'No recent session',
                        ),
                      ),
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
