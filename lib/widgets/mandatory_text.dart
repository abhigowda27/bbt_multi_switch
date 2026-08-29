import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

Widget richTxt({required String text, bool isMandatory = true}) {
  final context = navigatorKey.currentContext;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: RichText(
        text: TextSpan(
            text: text,
            style: Theme.of(context!).textTheme.titleMedium,
            children: [
          if (isMandatory) ...[
            TextSpan(
              text: " *",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).appColors.redButton),
            )
          ]
        ])),
  );
}
