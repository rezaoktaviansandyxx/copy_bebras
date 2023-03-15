import 'package:flutter/material.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckboxSolidWidget extends StatelessWidget {
  final bool? isChecked;
  final EdgeInsets? padding;
  const CheckboxSolidWidget({
    Key? key,
    this.isChecked,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child:
          isChecked == true ? checkedWidget(context) : uncheckedWidget(context),
    );
  }

  Widget uncheckedWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isLight ? const Color(0xff5A6E8F) : Colors.white,
        shape: BoxShape.circle,
      ),
      height: 16,
      width: 16,
    );
  }

  Widget checkedWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isLight ? const Color(0xff5A6E8F) : Colors.green,
        shape: BoxShape.circle,
      ),
      height: 16,
      width: 16,
      child: Center(
        child: Icon(
          FontAwesomeIcons.check,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
