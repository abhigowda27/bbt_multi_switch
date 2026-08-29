import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/constants.dart';
import 'package:bbtml_new/controllers/apis.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/add_router.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/nearby_wifi_page.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/switches/connect_to_switch.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/switches/switch_on_off.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/switches/update_switch.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_widgets.dart';
import 'package:bbtml_new/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../view/schedule_on_off_page.dart';
import '../custom/toast.dart';

class SwitchCard extends StatefulWidget {
  final SwitchDetails switchDetails;

  const SwitchCard({required this.switchDetails, super.key});

  @override
  State<SwitchCard> createState() => SwitchCardState();
}

class SwitchCardState extends State<SwitchCard> {
  final StorageController _storageController = StorageController();
  final NetworkService _networkService = NetworkService();

  String? get wifiName => _networkService.wifiName;
  bool _isConnected() {
    if (wifiName == null) return false;

    return wifiName!
            .toLowerCase()
            .contains(widget.switchDetails.switchSSID.toLowerCase()) ||
        widget.switchDetails.switchSSID
            .toLowerCase()
            .contains(wifiName!.toLowerCase());
  }

  void performTap() {
    (!_isConnected())
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConnectToSwitchPage(
                switchDetails: widget.switchDetails,
              ),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SwitchOnOff(
                switchDetails: widget.switchDetails,
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return ValueListenableBuilder<String?>(
        valueListenable: _networkService.wifiNameNotifier,
        builder: (context, _, __) {
          return InkWell(
            onTap: performTap,
            child: Container(
              padding: EdgeInsets.all(width * 0.03),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .appColors
                          .textSecondary
                          .withValues(alpha: 0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(2, 2),
                    ),
                  ],
                  color: Theme.of(context)
                      .appColors
                      .primary
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .appColors
                                .primary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .appColors
                                    .textSecondary
                                    .withValues(alpha: 0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(5, 5),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            Constants().applianceIconAsset(
                                widget.switchDetails.switchType ?? ""),
                            width: width * 0.2,
                            height: width * 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(widget.switchDetails.switchSSID,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontSize: 18)),
                                ),
                                IconButton(
                                    tooltip: "more info",
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.info_outlined,
                                      color:
                                          Theme.of(context).appColors.primary,
                                    ),
                                    onPressed: () => showInfo()),
                              ],
                            ),
                            Row(
                              children: [
                                if (widget
                                    .switchDetails.switchTypes.isNotEmpty) ...[
                                  Expanded(
                                    child: Text(
                                      "(${widget.switchDetails.switchTypes.length}) Devices",
                                      maxLines: 2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                  )
                                ],
                                if (widget
                                    .switchDetails.selectedFan!.isNotEmpty) ...[
                                  Expanded(
                                    child: Text(
                                      widget.switchDetails.selectedFan!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  )
                                ],
                              ],
                            ),
                            if (widget.switchDetails.wattage != 0) ...[
                              Text(CommonServices().formatWatt(
                                  widget.switchDetails.wattage ?? 0))
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).appColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            tooltip: "Add Router",
                            onPressed: () async {
                              if (!_isConnected()) {
                                showFlutterToast(
                                    "You should be connected to \"${widget.switchDetails.switchSSID}\" to add the Router");
                                AppSettings.openAppSettings(
                                    type: AppSettingsType.wifi);
                                return;
                              }
                              if (Platform.isIOS) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddNewRouterPage(
                                      isFromSwitch: true,
                                      switchDetails: widget.switchDetails,
                                      selectedWifiName: "",
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NearbyWifiPage(
                                              switchDetails:
                                                  widget.switchDetails,
                                              isFromSwitch: true,
                                            )));
                              }
                            },
                            icon: Transform.rotate(
                              angle: -90 * 3.1415926535897932 / 180,
                              child: SvgPicture.asset(
                                "assets/images/wifi.svg",
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context).appColors.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            )),
                        IconButton(
                            tooltip: "timer",
                            onPressed: () {
                              if (!_isConnected()) {
                                showFlutterToast(
                                    "You should be connected to \"${widget.switchDetails.switchSSID}\" to Proceed");
                                AppSettings.openAppSettings(
                                    type: AppSettingsType.wifi);
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ScheduleOnOffPage(
                                            switchName:
                                                widget.switchDetails.switchSSID,
                                            ipAddress:
                                                widget.switchDetails.iPAddress,
                                          )));
                            },
                            icon: Icon(
                              Icons.access_alarms_sharp,
                              color: Theme.of(context).appColors.textPrimary,
                            )),
                        IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: "Edit Switch",
                            onPressed: () {
                              debugPrint(widget.switchDetails.switchSSID);
                              if (!_isConnected()) {
                                showFlutterToast(
                                    "You should be connected to ${widget.switchDetails.switchSSID} to refresh the switch");
                                AppSettings.openAppSettings(
                                    type: AppSettingsType.wifi);
                                return;
                              }
                              showDialog(
                                  context: context,
                                  builder: (cont) {
                                    final formKey = GlobalKey<FormState>();
                                    TextEditingController pinController0 =
                                        TextEditingController();
                                    return Form(
                                      key: formKey,
                                      child: AlertDialog(
                                        title: Text(
                                          widget.switchDetails.switchSSID,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        content: Text(
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            'Enter the switch pin to proceed'),
                                        actions: [
                                          Column(
                                            children: [
                                              CustomTextField(
                                                maxLength: 4,
                                                controller: pinController0,
                                                validator: (value) {
                                                  if (value!.length <= 3) {
                                                    return "Switch Pin cannot be less than 4 letters";
                                                  }
                                                  if (pinController0.text !=
                                                      widget.switchDetails
                                                          .privatePin) {
                                                    return "Pin does not match";
                                                  }
                                                  return null;
                                                },
                                                hintText: "Enter Switch Pin",
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(navigatorKey
                                                          .currentContext!);
                                                    },
                                                    child: const Text('CANCEL'),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (formKey.currentState!
                                                          .validate()) {
                                                        if (pinController0
                                                                .text ==
                                                            widget.switchDetails
                                                                .privatePin) {
                                                          Navigator.pop(navigatorKey
                                                              .currentContext!);
                                                          Navigator.push(
                                                              navigatorKey
                                                                  .currentContext!,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      UpdatePage(
                                                                          switchDetails:
                                                                              widget.switchDetails)));
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                          showToast(context,
                                                              "Pin do not match");
                                                        }
                                                      }
                                                    },
                                                    child:
                                                        const Text('Confirm'),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(
                              FontAwesomeIcons.penToSquare,
                              color: Theme.of(context).appColors.textPrimary,
                            )),
                        IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: "Delete Switch",
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (cont) {
                                    final formKey = GlobalKey<FormState>();
                                    TextEditingController pinController =
                                        TextEditingController();

                                    return Form(
                                      key: formKey,
                                      child: AlertDialog(
                                        title: Text(
                                          widget.switchDetails.switchSSID,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        content: Text(
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            'Enter the switch pin to proceed'),
                                        actions: [
                                          Column(
                                            children: [
                                              CustomTextField(
                                                maxLength: 4,
                                                controller: pinController,
                                                validator: (value) {
                                                  if (value!.length <= 3) {
                                                    return "Switch Pin cannot be less than 4 letters";
                                                  }
                                                  if (pinController.text !=
                                                      widget.switchDetails
                                                          .privatePin) {
                                                    return "Pin does not match";
                                                  }
                                                  return null;
                                                },
                                                hintText: "Enter Old Pin",
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(navigatorKey
                                                          .currentContext!);
                                                    },
                                                    child: const Text('CANCEL'),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (formKey.currentState!
                                                          .validate()) {
                                                        if (pinController
                                                                .text ==
                                                            widget.switchDetails
                                                                .privatePin) {
                                                          _storageController
                                                              .deleteOneSwitch(
                                                                  widget
                                                                      .switchDetails);
                                                          Navigator
                                                              .pushAndRemoveUntil(
                                                            navigatorKey
                                                                .currentContext!,
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const TabsPage()),
                                                            (route) => false,
                                                          );
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                          showToast(context,
                                                              "Pin do not match");
                                                        }
                                                      }
                                                    },
                                                    child:
                                                        const Text('Confirm'),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Theme.of(context).appColors.textPrimary,
                            )),
                        if (widget.switchDetails.switchType == "DOOR_LOCK")
                          Switch(
                            onChanged: (value) async {
                              if (!_isConnected()) {
                                showFlutterToast(
                                    "You should be connected to \"${widget.switchDetails.switchSSID}\" to refresh the lock settings");
                                return;
                              }

                              if (value) {
                                await ApiConnect.hitApiPost(
                                    "${widget.switchDetails.iPAddress}/Autolock",
                                    {"AutoLockTime": "ON"});
                              } else {
                                await ApiConnect.hitApiPost(
                                    "${widget.switchDetails.iPAddress}/Autolock",
                                    {"AutoLockTime": "OFF"});
                              }
                              await _storageController.updateSwitchAutoStatus(
                                  widget.switchDetails.switchSSID, value);
                              Navigator.pushAndRemoveUntil<dynamic>(
                                navigatorKey.currentContext!,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) =>
                                      const TabsPage(),
                                ),
                                (route) => false,
                              );
                            },
                            value: widget.switchDetails.isAutoLock ?? false,
                            activeThumbColor:
                                Theme.of(context).appColors.primary,
                            activeTrackColor:
                                Theme.of(context).appColors.buttonBackground,
                            inactiveThumbColor: Colors.black87,
                            inactiveTrackColor: Colors.white,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void showInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).appColors.background.withValues(alpha: 0.8),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        bool hide = true;
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ---------- HEADER ----------
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .appColors
                                  .primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              Constants().applianceIconAsset(
                                widget.switchDetails.switchType ?? "",
                              ),
                              width: 45,
                              height: 45,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.switchDetails.switchSSID,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: hide ? "Show Passwords" : "Hide Passwords",
                            icon: Icon(
                              hide
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setDialogState(() => hide = !hide);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// ---------- CONTENT ----------
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonWidgets().infoRow(
                                context,
                                label: "Switch ID",
                                value: widget.switchDetails.switchId,
                              ),
                              CommonWidgets().infoRow(
                                context,
                                label: "Switch Name",
                                value: widget.switchDetails.switchSSID,
                              ),
                              Divider(
                                  color: Theme.of(context)
                                      .appColors
                                      .textSecondary),
                              if (widget
                                  .switchDetails.switchTypes.isNotEmpty) ...[
                                Text(
                                  "Selected Switches (${widget.switchDetails.switchTypes.length})",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ...widget.switchDetails.switchTypes
                                    .map((entry) {
                                  final index = entry["order"];
                                  final switchType = entry["name"];

                                  return Card(
                                    color: Theme.of(context)
                                        .appColors
                                        .buttonBackground
                                        .withValues(alpha: 0.5),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .appColors
                                            .primary
                                            .withValues(alpha: 0.5),
                                        child: Text("$index"),
                                      ),
                                      title: Text(switchType),
                                      titleTextStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title:
                                                  const Text("Delete Switch"),
                                              content: Text(
                                                  'Are you sure you want to delete "$switchType"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .appColors
                                                          .redButton,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await _storageController
                                                .deleteOneSwitchType(
                                              switchDetails:
                                                  widget.switchDetails,
                                              typeToRemove: switchType,
                                            );

                                            setState(() {
                                              widget.switchDetails.switchTypes
                                                  .remove(switchType);
                                            });
                                            setDialogState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              if (widget
                                      .switchDetails.selectedFan?.isNotEmpty ==
                                  true)
                                CommonWidgets().infoRow(
                                  context,
                                  label: "Selected Fan",
                                  value: widget.switchDetails.selectedFan!,
                                ),
                              Divider(
                                  color: Theme.of(context)
                                      .appColors
                                      .textSecondary),
                              CommonWidgets().passwordRow(
                                context,
                                label: "PassKey",
                                value: widget.switchDetails.switchPassKey!,
                                hide: hide,
                              ),
                              CommonWidgets().passwordRow(
                                context,
                                label: "Password",
                                value: widget.switchDetails.switchPassword,
                                hide: hide,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
