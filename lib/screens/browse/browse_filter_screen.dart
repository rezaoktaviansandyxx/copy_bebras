import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:fluxmobileapp/baselib/app_services.dart';
import 'package:fluxmobileapp/screens/browse/browse_filter_store.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../appsettings.dart';

class BrowseFilterScreen extends StatefulWidget {
  final BrowseFilterStore? browseFilterStore;
  BrowseFilterScreen({
    required this.browseFilterStore,
    Key? key,
  }) : super(key: key);

  @override
  _BrowseFilterScreenState createState() => _BrowseFilterScreenState();
}

class _BrowseFilterScreenState extends State<BrowseFilterScreen> {
  final appServices = sl.get<AppServices>();

  BrowseFilterStore? get store => widget.browseFilterStore;

  @override
  void initState() {
    super.initState();

    store!.filterDataSubject.add(BrowseFilterData.fromMap(
      store!.filterData?.toMap() ?? Map<String, dynamic>(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Text(
            'Filter',
            style: TextStyle(
              color: context.isLight ? const Color(0xff5A6E8F) : null,
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                store!.getDefaultFilter.executeIf();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      'CLEAR ALL',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                        fontSize: FontSizesWidget.of(context)!.veryThin,
                        color: context.isLight ? const Color(0xff5A6E8F) : null,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      FontAwesomeIcons.trash,
                      size: FontSizesWidget.of(context)!.thin,
                      color: context.isLight ? const Color(0xff5A6E8F) : null,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            createDivider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Topic
                  FilterExpandableWidget(
                    header: 'Topic',
                    initialExpanded: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        StreamBuilder(
                          stream: store!.filterDataSubject,
                          initialData: null,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot snapshot,
                          ) {
                            final topics =
                                store!.filterDataSubject.value.topics;
                            if (topics == null) {
                              return const SizedBox();
                            }

                            return Wrap(
                              alignment: WrapAlignment.start,
                              children: topics.map((f) {
                                return ChipWidget(
                                  text: f.name,
                                  isSelected: f.isSelected,
                                  onTap: () {
                                    if (f.isSelected == null) {
                                      f.isSelected = false;
                                    }
                                    f.isSelected = !f.isSelected!;
                                    store!.filterDataSubject.add(
                                      store!.filterDataSubject.value,
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),

                  // Type
                  createDivider(),
                  FilterExpandableWidget(
                    header: 'Type',
                    initialExpanded: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        StreamBuilder(
                          stream: store!.filterDataSubject,
                          initialData: null,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot snapshot,
                          ) {
                            final types =
                                store!.filterDataSubject.value.types;
                            if (types == null) {
                              return const SizedBox();
                            }

                            return Wrap(
                              alignment: WrapAlignment.start,
                              children: types.map((f) {
                                return ChipWidget(
                                  text: f.name,
                                  isSelected: f.isSelected,
                                  onTap: () {
                                    if (f.isSelected == null) {
                                      f.isSelected = false;
                                    }
                                    f.isSelected = !f.isSelected!;
                                    store!.filterDataSubject.add(
                                      store!.filterDataSubject.value,
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),

                  // // Rating
                  // createDivider(),
                  // FilterExpandableWidget(
                  //   header: 'Rating',
                  //   initialExpanded: false,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: <Widget>[
                  //       StreamBuilder(
                  //         stream: store.filterDataSubject,
                  //         initialData: null,
                  //         builder: (
                  //           BuildContext context,
                  //           AsyncSnapshot snapshot,
                  //         ) {
                  //           final rating =
                  //               store.filterDataSubject.value?.rating ?? 0;
                  //           return DropdownButtonHideUnderline(
                  //             child: DropdownButton<int>(
                  //               isExpanded: true,
                  //               isDense: true,
                  //               value: rating,
                  //               items: List.generate(6, (i) {
                  //                 return DropdownMenuItem(
                  //                   value: i,
                  //                   child: Text(
                  //                     i == 0 ? 'Show All' : '$i rating',
                  //                     style: TextStyle(
                  //                       fontFamily: 'Rubik',
                  //                       color: Theme.of(context)
                  //                           .textTheme
                  //                           .bodyText2
                  //                           .color,
                  //                     ),
                  //                   ),
                  //                 );
                  //               }),
                  //               onChanged: (v) {
                  //                 final filterDataMap =
                  //                     store.filterDataSubject.value.toMap();

                  //                 // If user select 'Show All'
                  //                 if (v == 0) {
                  //                   filterDataMap['rating'] = null;
                  //                 } else {
                  //                   filterDataMap['rating'] = v;
                  //                 }
                  //                 final newFilterValue =
                  //                     BrowseFilterData.fromMap(
                  //                   filterDataMap,
                  //                 );
                  //                 store.filterDataSubject.add(
                  //                   newFilterValue,
                  //                 );
                  //               },
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //       const SizedBox(
                  //         height: 15,
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // Authors
                  // createDivider(),
                  // FilterExpandableWidget(
                  //   header: 'Authors',
                  //   initialExpanded: false,
                  //   child: StreamBuilder(
                  //     stream: store!.filterDataSubject,
                  //     initialData: null,
                  //     builder: (
                  //       BuildContext context,
                  //       AsyncSnapshot snapshot,
                  //     ) {
                  //       final authors =
                  //           store!.filterDataSubject.value.authors;
                  //       if (authors == null) {
                  //         return const SizedBox();
                  //       }

                  //       return Wrap(
                  //         alignment: WrapAlignment.start,
                  //         children: authors.map((f) {
                  //           return ChipWidget(
                  //             text: f.name,
                  //             isSelected: f.isSelected,
                  //             onTap: () {
                  //               if (f.isSelected == null) {
                  //                 f.isSelected = false;
                  //               }
                  //               f.isSelected = !f.isSelected!;
                  //               store!.filterDataSubject.add(
                  //                 store!.filterDataSubject.value,
                  //               );
                  //             },
                  //           );
                  //         }).toList(),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        appServices!.navigatorState!.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizesWidget.of(context)!.regular,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        store!.apply.executeIf();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        backgroundColor: context.isLight
                        ? const Color(0xff0E9DE9)
                        : const Color(0xff5AD57F),
                      ),
                      child: Text(
                        'Terapkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizesWidget.of(context)!.regular,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createDivider() {
    return Container(
      height: 1,
      color: context.isDark ? const Color(0xff122237) : const Color(0xff8597AE),
    );
  }
}

class ChipWidget extends StatelessWidget {
  final String? text;
  final bool? isSelected;
  final void Function()? onTap;

  const ChipWidget({
    Key? key,
    required this.text,
    this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = isSelected == true
        ? Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 3.5,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: context.isLight ? const Color(0xffE4FFF7) : null,
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                    border: Border.all(
                      color: context.isLight
                          ? const Color(0xff14C48D)
                          : Theme.of(context).accentColor,
                    ),
                  ),
                  child: Text(
                    text!,
                    style: TextStyle(
                      color: context.isLight
                          ? const Color(0xff14C48D)
                          : Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.isLight
                        ? const Color(0xff14C48D)
                        : Theme.of(context).accentColor,
                  ),
                  padding: const EdgeInsets.all(3.5),
                  child: Icon(
                    FontAwesomeIcons.check,
                    size: 12,
                    color: context.isLight
                        ? Colors.white
                        : Theme.of(context).canvasColor,
                  ),
                ),
              ),
            ],
          )
        : Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 3.5,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      border: Border.all(
                        color: Theme.of(context).iconTheme.color!,
                      )),
                  child: Text(
                    text!,
                  ),
                ),
              ),
            ],
          );
    return GestureDetector(
      onTap: onTap,
      child: widget,
    );
  }
}

class FilterExpandableWidget extends StatelessWidget {
  final bool? initialExpanded;
  final String? header;
  final EdgeInsets? padding;
  final Widget child;

  const FilterExpandableWidget({
    Key? key,
    this.initialExpanded,
    this.header,
    this.padding,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      initialExpanded: initialExpanded,
      child: ExpandablePanel(
        collapsed: const SizedBox(),
        theme: ExpandableThemeData(
          hasIcon: false,
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  header!,
                  style: TextStyle(
                    color: context.isLight
                        ? const Color(0xff5A6E8F)
                        : AppTheme.of(context).filterHeaderColor,
                  ),
                ),
              ),
              ExpandableIcon(
                theme: ExpandableThemeData(
                  expandIcon: FontAwesomeIcons.chevronDown,
                  iconSize: FontSizesWidget.of(context)!.regular,
                  collapseIcon: FontAwesomeIcons.chevronUp,
                  iconColor: AppTheme.of(context).filterHeaderColor,
                ),
              ),
            ],
          ),
        ),
        expanded: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 15,
              ),
          child: child,
        ),
      ),
    );
  }
}
