import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CalendarHorizontal extends StatefulWidget {
  final void Function(DateTime dateTime)? onChanged;

  CalendarHorizontal({
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _CalendarHorizontalState createState() => _CalendarHorizontalState();
}

class _CalendarHorizontalState extends State<CalendarHorizontal> {
  final date = BehaviorSubject<DateTime>();

  final days = BehaviorSubject<List<DateTime>>();

  final List<StreamSubscription> _s = [];

  final scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();

    _s.add(date.where((t) => t != null).listen((d) {
      final day = DateTime(
        d.year == 12 ? d.year + 1 : d.year,
        d.month + 1,
        0,
      );

      final _days = List.generate(day.day, (f) {
        final c = DateTime(day.year, day.month, f + 1);
        return c;
      });
      days.add(_days);
      if (widget.onChanged != null) {
        widget.onChanged!(d);
      }
      final initalIndex = days.value.indexWhere(
        (d) => getDateOnly(d) == getDateOnly(date.value),
      );
      if (scrollController.isAttached) {
        scrollController.jumpTo(
          index: initalIndex,
        );
      }
    }));

    date.add(getDateOnly(DateTime.now()));
  }

  @override
  void dispose() {
    days.close();
    date.close();
    _s.forEach((f) {
      f.cancel();
    });
    _s.clear();

    super.dispose();
  }

  DateTime getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            TextButton(
              onPressed: () async {
                final dateTime = await showDatePicker(
                  context: context,
                  initialDate: date.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(3000),
                );
                if (dateTime != null) {
                  date.add(dateTime);
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
              ),
              child: Row(
                children: [
                  StreamBuilder<DateTime>(
                    stream: date,
                    builder: (context, data) {
                      final date = data.data;
                      if (date == null) {
                        return const SizedBox();
                      }

                      return Text(
                        DateFormat('MMMM yyyy').format(date),
                        style: TextStyle(
                          fontSize: FontSizesWidget.of(context)!.large,
                          color: Color(0XFF00ADEE),
                          // context.isLight
                          //     ? Colors.white
                          //     : Theme.of(context).accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    FontAwesomeIcons.chevronDown,
                    size: 14,
                    color: Color(0XFF00ADEE),
                    // context.isLight
                    //     ? Colors.white
                    //     : Theme.of(context).accentColor,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Color(0XFF00ADEE),
                // context.isLight ? Colors.white : null,
              ),
              onPressed: () async {
                date.add(getDateOnly(DateTime.now()));
              },
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 60,
          child: StreamBuilder<List<DateTime>>(
            initialData: [],
            stream: days,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<DateTime>> snapshot,
            ) {
              final days = snapshot.data!;
              if (days.isEmpty) {
                return const SizedBox();
              }

              final initalIndex = days.indexWhere(
                (d) => getDateOnly(d) == getDateOnly(date.value),
              );

              return Container(
                child: ScrollablePositionedList.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  initialScrollIndex: initalIndex >= 0 ? initalIndex : 0,
                  addAutomaticKeepAlives: true,
                  itemScrollController: scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    final date = days[index];

                    final isSelected =
                        getDateOnly(date) == getDateOnly(this.date.value);

                    return InkWell(
                      onTap: isSelected
                          ? null
                          : () {
                              this.date.add(date);
                            },
                      child: Container(
                        margin: const EdgeInsets.only(
                          right: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: context.isDark
                              ? (isSelected
                                  ? Theme.of(context).accentColor
                                  : AppTheme.of(context).canvasColorLevel3)
                              : (isSelected
                                  ? const Color(0xffD1F3FF)
                                  : const Color(0xffF3F8FF)),
                          border: Border.all(
                            width: 2,
                            color: isSelected
                                ? const Color(0xff0E9DE9)
                                : const Color(0xff8597AE),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                DateFormat.EEEE().format(date).toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizesWidget.of(context)!.thin,
                                  color: isSelected
                                      ? const Color(0xff0E9DE9)
                                      : const Color(0xff8597AE),
                                ),
                              ),
                              Text(
                                DateFormat.d().format(date),
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizesWidget.of(context)!.large,
                                  color: isSelected
                                      ? const Color(0xff0E9DE9)
                                      : const Color(0xff8597AE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
