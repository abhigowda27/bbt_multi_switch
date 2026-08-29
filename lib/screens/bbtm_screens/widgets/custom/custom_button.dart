import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.width,
    this.bgmColor,
    required this.text,
    this.icon,
    required this.onPressed,
  });

  final String text;
  final double? width;
  final Color? bgmColor;
  final GestureTapCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Theme.of(context).appColors.background,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).appColors.background,
                ),
          ),
        ],
      ),
    );
  }
}
