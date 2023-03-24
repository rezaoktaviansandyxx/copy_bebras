import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:fluxmobileapp/utils/utils.dart';

class SessionItem {
  String? title;
  String? author;
  String? imageThumbnail;
  int? rating;
  int? totalUserRate;
  String? category;
  String? tag;
}

class SessionItemWidget extends StatelessWidget {
  final SessionItem item;
  final bool useExpandedCategory;
  final bool showRating;
  final bool showCategory;

  const SessionItemWidget({
    Key? key,
    required this.item,
    this.useExpandedCategory = true,
    this.showRating = true,
    this.showCategory = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final categoryWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: context.isDark
            ? Theme.of(context).accentColor
            : const Color(0xff14C48D),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      child: Text(
        item.category ?? '',
        style: TextStyle(
          fontSize: FontSizesWidget.of(context)!.veryThin,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    item.imageThumbnail ?? '',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, url, v) {
                      return CachedNetworkImage(
                        imageUrl: item.imageThumbnail ?? '',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        placeholder: (c, url) {
                          return Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorWidget: (context, url, v) {
                          return Container(
                            color: Theme.of(context)
                                .inputDecorationTheme
                                .fillColor,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  //     CachedNetworkImage(
                  //   imageUrl: item.imageThumbnail ?? '',
                  //   fit: BoxFit.cover,
                  //   alignment: Alignment.center,
                  //   placeholder: (c, url) {
                  //     return Align(
                  //       alignment: Alignment.center,
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   },
                  //   errorWidget: (context, url, v) {
                  //     return Container(
                  //       color: Theme.of(context).inputDecorationTheme.fillColor,
                  //       child: Center(
                  //         child: Icon(
                  //           Icons.broken_image,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  left: 8,
                  child: Row(
                    children: <Widget>[
                      if (item.category != null)
                        useExpandedCategory
                            ? Expanded(
                                child: categoryWidget,
                              )
                            : categoryWidget,
                      if (item.category != null)
                        const SizedBox(
                          width: 8,
                        ),
                      if (item.category == null || !useExpandedCategory)
                        Expanded(
                          child: const SizedBox(),
                        ),
                      if (showRating)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: context.isDark
                                ? Theme.of(context).canvasColor
                                : const Color(0xff1B304D),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  removeDecimalZeroFormat(
                                    getContentRating(
                                      item.rating,
                                      item.totalUserRate,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize:
                                        FontSizesWidget.of(context)!.veryThin,
                                    color: const Color(
                                      0xffECCF71,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              Center(
                                child: Icon(
                                  Icons.star,
                                  color: const Color(
                                    0xffECCF71,
                                  ),
                                  size: FontSizesWidget.of(
                                        context,
                                      )!
                                          .veryThin *
                                      mediaQuery.textScaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        if (item.tag != null)
          Text(
            item.tag!,
            style: TextStyle(
              fontSize: FontSizesWidget.of(context)!.veryThin,
              color: const Color(0xff69B1DF),
            ),
            maxLines: 1,
          ),
        const SizedBox(
          height: 2,
        ),
        SizedBox(
          height: 38 * mediaQuery.textScaleFactor,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              item.title!,
              maxLines: 2,
              style: AppTheme.of(context).sectionSubtitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Container(
          height: 20,
          child: Row(
            children: <Widget>[
              // ClipOval(
              //   child: Container(
              //     height: 18,
              //     width: 18,
              //     child: CachedNetworkImage(
              //       imageUrl: '',
              //       errorWidget: (context, url, v) {
              //         return const Icon(
              //           Icons.account_circle,
              //           size: 18,
              //         );
              //       },
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   width: 5,
              // ),
              Expanded(
                child: RichText(
                  maxLines: 2,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: FontSizesWidget.of(context)!.veryThin,
                      color: context.isDark
                          ? AppTheme.of(context).sectionTitle.color
                          : const Color(0xff9FADBF),
                      fontFamily: 'Rubik',
                    ),
                    children: [
                      TextSpan(
                        text: 'By: ',
                      ),
                      TextSpan(
                        text: item.author ?? '',
                        style: TextStyle(
                          color: context.isDark
                              ? AppTheme.of(context).sectionSubtitle.color
                              : const Color(0xff5A6E8F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SessionItemShimmerWidget extends StatelessWidget {
  const SessionItemShimmerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 42,
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          height: 25,
          child: Row(
            children: <Widget>[
              ClipOval(
                child: Container(
                  height: 18,
                  width: 18,
                  child: CachedNetworkImage(
                    imageUrl: '',
                    errorWidget: (context, url, v) {
                      return const Icon(
                        Icons.account_circle,
                        size: 18,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
