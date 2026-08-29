import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Toast, Fluttertoast;

enum ToastType {
  success,
  error,
  warning,
  info,
}

void showToast(BuildContext context, String text) {
  final scaffold = ScaffoldMessenger.of(context);
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();

  scaffold.showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.vertical,
      backgroundColor: Theme.of(context).appColors.textSecondary,
      duration: const Duration(seconds: 1),
      content: Text(text),
    ),
  );
}

void showFlutterToast(
  String msg, {
  ToastType type = ToastType.info,
  Toast len = Toast.LENGTH_LONG,
}) {
  Fluttertoast.cancel();

  Color backgroundColor;

  switch (type) {
    case ToastType.success:
      backgroundColor = Colors.green.withValues(alpha: 0.8);
      break;

    case ToastType.error:
      backgroundColor = Colors.redAccent.withValues(alpha: 0.8);
      break;

    case ToastType.warning:
      backgroundColor = Colors.orange.withValues(alpha: 0.8);
      break;

    case ToastType.info:
      backgroundColor =
          Theme.of(navigatorKey.currentContext!).appColors.textSecondary;
      break;
  }

  Fluttertoast.showToast(
    msg: msg,
    toastLength: len,
    backgroundColor: backgroundColor,
    textColor: Theme.of(navigatorKey.currentContext!).appColors.background,
  );
}
