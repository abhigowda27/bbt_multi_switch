import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class CommonWidgets {
  Widget infoRow(
    BuildContext context, {
    IconData? icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Theme.of(context).appColors.textSecondary,
            ),
            const SizedBox(width: 8)
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordRow(
    BuildContext context, {
    required String label,
    required String value,
    required bool hide,
  }) {
    return infoRow(
      context,
      icon: Icons.lock_outline,
      label: label,
      value: hide ? "*" * value.length : value,
    );
  }
}
