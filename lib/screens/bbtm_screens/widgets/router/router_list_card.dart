import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../models/router_model.dart';
import '../custom/toast.dart';

class RouterListCard extends StatefulWidget {
  const RouterListCard({
    required this.routerDetails,
    required this.index,
    required this.switchStatus,
    required this.wifiName,
    this.onToggle,
    super.key,
  });
  final RouterDetails routerDetails;
  final int index;
  final bool switchStatus;
  final String wifiName;
  final Future<void> Function(bool)? onToggle;
  @override
  State<RouterListCard> createState() => _RouterListCardState();
}

class _RouterListCardState extends State<RouterListCard> {
  late int slNo;
  bool switchOff = false;

  @override
  void initState() {
    super.initState();
    slNo = widget.routerDetails.switchTypes[widget.index]['order'];
    switchOff = widget.switchStatus;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("${widget.switchStatus}");
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 7,
            offset: const Offset(5, 5),
          ),
        ],
        color:
            Theme.of(context).appColors.buttonBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FaIcon(
            FontAwesomeIcons.solidLightbulb,
            color: switchOff ? Colors.yellow : Colors.grey,
            size: 40,
          ),
          Flexible(
            child: Text(
              widget.routerDetails.switchTypes[widget.index]['name'],
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            onChanged: (value) async {
              if (!widget.wifiName.toLowerCase().contains(
                      widget.routerDetails.routerName.toLowerCase()) &&
                  !widget.routerDetails.routerName
                      .toLowerCase()
                      .contains(widget.wifiName.toLowerCase())) {
                showToast(context,
                    "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
                return;
              }

              if (widget.onToggle != null) {
                await widget.onToggle!(value);
                return;
              }

              try {
                if (value) {
                  await ApiConnect.hitApiPost(
                      "${widget.routerDetails.iPAddress}/getSwitchcmd", {
                    "Lock_id": widget.routerDetails.switchID,
                    "lock_passkey": widget.routerDetails.switchPasskey,
                    "lock_cmd": "ON$slNo"
                  });
                  if (context.mounted) {
                    commonSnackBar(
                        context, "Device $slNo turned ON Successfully");
                  }

                  setState(() {
                    switchOff = true;
                  });
                } else {
                  await ApiConnect.hitApiPost(
                      "${widget.routerDetails.iPAddress}/getSwitchcmd", {
                    "Lock_id": widget.routerDetails.switchID,
                    "lock_passkey": widget.routerDetails.switchPasskey,
                    "lock_cmd": "OFF$slNo"
                  });
                  if (context.mounted) {
                    commonSnackBar(
                        context, "Device $slNo turned OFF Successfully");
                  }
                  setState(() {
                    switchOff = false;
                  });
                }
              } on DioException catch (e, s) {
                debugPrint("$e $s");
                if (context.mounted) {
                  final scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                          "Unable to perform. Try Again. Error: ${e.response}"),
                    ),
                  );
                }
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            value: switchOff,
            activeThumbColor: Theme.of(context).appColors.greenButton,
            activeTrackColor: Theme.of(context).appColors.green,
            inactiveThumbColor: Theme.of(context).appColors.redButton,
            inactiveTrackColor: Theme.of(context).appColors.red,
          ),
        ],
      ),
    );
  }
}
