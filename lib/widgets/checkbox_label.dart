import 'package:flutter/material.dart';
import 'package:fluxmobileapp/styles/styles.dart';
import 'package:fluxmobileapp/utils/theme_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckboxLabel extends StatelessWidget {
  final bool? isChecked;
  final void Function()? onTap;

  const CheckboxLabel({
    this.isChecked,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      radius: 10,
      borderRadius: BorderRadius.circular(100),
      child:
          isChecked == true ? checkedWidget(context) : uncheckedWidget(context),
    );
  }

  Widget checkedWidget(BuildContext context) {
    return Container(
      height: 68,
      width: 68,
      decoration: BoxDecoration(
        color: context.isLight
            ? const Color(0xff14C48D)
            : Theme.of(context).accentColor,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Icon(
            FontAwesomeIcons.check,
            size: 32,
            color: AppTheme.of(context).canvasColorLevel2,
          ),
        ),
      ),
    );
  }

  Widget uncheckedWidget(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: 68,
      width: 68,
      decoration: BoxDecoration(
        color: const Color(
          0xff354C6B66,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.isLight
              ? const Color(0xff14C48D)
              : AppTheme.of(context).canvasColorLevel3!,
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: Text(
            'Mark as done',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: FontSizesWidget.of(context)!.veryThin,
            ),
            textAlign: TextAlign.center,
            textScaleFactor: mediaQuery.textScaleFactor > 1.275
                ? 1.275
                : mediaQuery.textScaleFactor,
          ),
        ),
      ),
    );
  }
}
