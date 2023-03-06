import 'package:flutter/material.dart';
import 'package:fluxmobileapp/appsettings.dart';
import 'package:fluxmobileapp/baselib/localization_service.dart';

Future createAlertDialog(String? i, BuildContext context) async {
  final localization = sl.get<ILocalizationService>();
  final result = await showDialog(
    context: context,
    builder: (c) {
      return AlertDialog(
        content: Text(i!),
        actions: <Widget>[
          TextButton(
            child: Text(
              localization!.getByKey(
                'common.ok',
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  return result;
}
