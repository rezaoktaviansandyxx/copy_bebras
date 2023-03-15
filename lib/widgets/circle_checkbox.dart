import 'package:flutter/material.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CircleCheckbox extends StatelessWidget {
  final Color? borderColor;
  final bool? isChecked;
  final void Function()? onTap;
  final Color? selectedColor;
  final EdgeInsets? padding;

  const CircleCheckbox({
    this.borderColor,
    this.selectedColor,
    this.isChecked,
    this.onTap,
    this.padding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(10),
        child: isChecked! ? checkedWidget(context) : uncheckedWidget(context),
      ),
    );
  }

  Widget uncheckedWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Theme.of(context).textTheme.bodyText2!.color!,
        ),
        shape: BoxShape.circle,
      ),
      height: 24,
      width: 24,
    );
  }

  Widget checkedWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.isLight
            ? const Color(0xff14C48D)
            : (selectedColor ?? Theme.of(context).accentColor),
      ),
      height: 24,
      width: 24,
      child: Center(
        child: Icon(
          FontAwesomeIcons.check,
          size: 14,
          color: AppTheme.of(context).canvasColorLevel2,
        ),
      ),
    );
  }
}
