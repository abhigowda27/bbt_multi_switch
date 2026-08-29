import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool needBorder;
  final EdgeInsets? padding;
  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.needBorder = false,
    this.padding,
  });
  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    _isExpanded = widget.initiallyExpanded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        backgroundColor: Theme.of(context).appColors.primary,
        collapsedBackgroundColor: Theme.of(context).appColors.textPrimary,
        iconColor: Theme.of(context).appColors.background,
        collapsedIconColor: Theme.of(context).appColors.background,
        trailing: Icon(
          _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
        onExpansionChanged: (bool expanded) {
          if (mounted) {
            setState(() {
              _isExpanded = expanded;
            });
          }
        },
        dense: true,
        visualDensity: VisualDensity.compact,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).appColors.background,
              borderRadius: BorderRadius.circular(5),
              border: widget.needBorder
                  ? Border.all(
                      color: Theme.of(context).appColors.backgroundDark,
                    )
                  : null,
            ),
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
        ],
      ),
    );
  }
}
