import 'package:bbtml_new/screens/bbtm_screens/widgets/router/router_card.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/group_model.dart';
import '../../models/router_model.dart';

class GroupCard extends StatefulWidget {
  final GroupDetails groupDetails;
  final bool showOptions;

  const GroupCard(
      {required this.groupDetails, this.showOptions = true, super.key});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  bool hide = true;
  final StorageController _storageController = StorageController();
  bool isExpanded = false;
  late List<bool> expandedStates;

  @override
  void initState() {
    isExpanded = !widget.showOptions;
    // Initialize expanded states for all switches
    expandedStates = List.generate(
        widget.groupDetails.selectedSwitches.length, (_) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: widget.showOptions
          ? BoxDecoration(
              boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).appColors.textSecondary
                      .withValues(alpha: 0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(5, 5),
                  ),
                ],
              color: Theme.of(context).appColors.primary
                .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12))
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Group Name: ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  widget.groupDetails.groupName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          //SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Selected Router: ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  widget.groupDetails.selectedRouter,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Router Password: ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  hide
                      ? List.generate(widget.groupDetails.routerPassword.length,
                          (index) => "*").join()
                      : widget.groupDetails.routerPassword,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Selected Switches: ${widget.groupDetails.selectedSwitches.length}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_outlined
                      : Icons.keyboard_arrow_down_outlined,
                  size: width * 0.06,
                  color: Theme.of(context).appColors.textPrimary,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.groupDetails.selectedSwitches
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                RouterDetails switchDetail = entry.value;
                bool isExpanded = expandedStates[index];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1} : ',
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color:
                                        Theme.of(context).appColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    switchDetail.switchName,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Theme.of(context)
                                          .appColors
                                          .textPrimary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                expandedStates[index] = !expandedStates[index];
                              });
                            },
                            child: Text(
                              isExpanded ? "Show less" : "Show more",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Theme.of(context).appColors.primary,
                                  decorationColor:
                                      Theme.of(context).appColors.primary,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded) ...[
                      RouterCard(
                        routerDetails: switchDetail,
                        showOptions: false,
                      )
                    ]
                  ],
                );
              }).toList(),
            )
          ],
          if (widget.showOptions)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).appColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: "Delete Group",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (cont) {
                          return AlertDialog(
                            title: const Text('Delete Group'),
                            content: const Text('This will delete the Group'),
                            actions: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).appColors.primary),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  _storageController
                                      .deleteOneGroup(widget.groupDetails);
                                  Navigator.pushAndRemoveUntil<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          const TabsPage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).appColors.primary),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.delete_outline_outlined,
                        color: Theme.of(context).appColors.textPrimary),
                  ),
                  IconButton(
                      tooltip: "password",
                      onPressed: () {
                        setState(() {
                          hide = !hide;
                        });
                      },
                      icon: hide
                          ? Icon(
                              Icons.visibility_outlined,
                              color: Theme.of(context).appColors.textPrimary,
                            )
                          : Icon(
                              Icons.visibility_off_outlined,
                              color: Theme.of(context).appColors.textPrimary,
                            )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
