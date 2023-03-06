import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ErrorDataWidget extends StatelessWidget {
  final String? text;
  final Function? onReload;
  final Function? onLogout;

  const ErrorDataWidget({
    required this.text,
    this.onReload,
    Key? key,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            text ?? '',
            textAlign: TextAlign.center,
          ),
          if (onReload != null)
            const SizedBox(
              height: 2,
            ),
          if (onReload != null)
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const DecoratedBox(
                decoration: const BoxDecoration(),
              ),
              onPressed: () {
                onReload!();
              },
            ),
          if (onLogout != null)
            TextButton.icon(
              icon: const Icon(
                FontAwesomeIcons.signOutAlt,
              ),
              label: const DecoratedBox(
                decoration: const BoxDecoration(),
              ),
              onPressed: () {
                onLogout!();
              },
            ),
        ],
      ),
    );
  }
}
