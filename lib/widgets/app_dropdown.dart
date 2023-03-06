import 'package:flutter/material.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';

class AppDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T value;
  final void Function(T?)? onChanged;
  final DateTime? date;
  final void Function(DateTime)? onDateChanged;
  final Color? backgroundColor;

  const AppDropdown({
    required this.items,
    required this.value,
    this.onChanged,
    this.date,
    this.onDateChanged,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.isLight
                ? const Color(0xffE6F0FF)
                : (backgroundColor ??
                    Theme.of(context).inputDecorationTheme.fillColor),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.map((f) {
                return DropdownMenuItem<T>(
                  value: f,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      f.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: context.isLight ? Colors.black : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                onChanged!(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
