import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/common/search_utils.dart';
import 'package:bbtml_new/screens/switches/widgets/multi_switch_list.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

import 'fan_controller_widget.dart';

class SwitchesCard extends StatefulWidget {
  final Map<String, dynamic> switchesDetails;
  final Function onChanged;
  final TextEditingController searchController;
  const SwitchesCard({
    required this.switchesDetails,
    super.key,
    required this.onChanged,
    required this.searchController,
  });

  @override
  State<SwitchesCard> createState() => _SwitchesCardState();
}

class _SwitchesCardState extends State<SwitchesCard> {
  Map<String, bool> switchStates = {};
  Map<String, dynamic> statusList = {};
  Map<String, dynamic> fanStatusList = {};
  Map<String, dynamic> multiStatusList = {};
  Map<String, dynamic> deviceDetails = {};
  List<dynamic> deviceList = [];
  List<dynamic> filteredDeviceList = [];
  final SwitchBloc _switchBloc = SwitchBloc();
  String? _pendingToggleId;
  bool? _previousToggleValue;
  String? _pendingDeleteId;

  @override
  void didUpdateWidget(covariant SwitchesCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the device list changed
    if (widget.switchesDetails != oldWidget.switchesDetails) {
      setValues(); // update deviceList
      filterDevices(widget.searchController.text); // apply search filter
    }
  }

  /// 🔍 Filter logic
  void filterDevices(String query) {
    setState(() {
      filteredDeviceList = smartFilter<dynamic>(
        deviceList,
        query,
        [
          (item) => item["device_name"]?.toString() ?? "",
          (item) => item["device_id"]?.toString() ?? "",
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();

    widget.searchController.addListener(() {
      filterDevices(widget.searchController.text);
    });
    setValues();
  }

  void setValues() {
    final statusConfigs = widget.switchesDetails["deviceStatus"] ?? [];

    for (var config in statusConfigs) {
      final deviceType = config["deviceType"];
      final statuses = config["status"];

      if (deviceType == 1) {
        statusList = {
          for (var s in statuses) s["title"]: s["id"],
        };
      } else if (deviceType == 2) {
        fanStatusList = {
          for (var s in statuses) s["title"]: s["id"],
        };
      } else if (deviceType == 3) {
        multiStatusList = {
          for (var s in statuses) s["title"]: s["id"],
        };
      }
    }

    deviceList = widget.switchesDetails["list"] ?? [];
    filteredDeviceList = List.from(deviceList);

    for (var device in deviceList) {
      final id = device["device_id"];
      switchStates[id] = device["details"]["statusTxt"] == "ON" ? true : false;
      debugPrint("${switchStates[id]}");
    }
    debugPrint("?????$statusList");
    debugPrint("?????$fanStatusList");
    debugPrint("?????$multiStatusList");
  }

  Future<void> toggleSwitch(
    String switchId,
    String newStatus,
    String uid,
    int deviceType,
  ) async {
    try {
      _pendingToggleId = switchId;
      _previousToggleValue = switchStates[switchId];

      // For deviceType 1 (boolean switch), update internal toggle state
      if (deviceType == 1) {
        final isOn =
            newStatus == statusList.entries.firstWhere((e) => e.value == 1).key;
        setState(() {
          switchStates[switchId] = isOn;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));

      _switchBloc.add(TriggerSwitchEvent(
        deviceId: switchId,
        status: newStatus,
        uuid: uid,
        deviceType: deviceType,
        childuid: '',
      ));

      debugPrint("Switch $switchId toggled to $newStatus");
    } catch (e) {
      debugPrint("Toggle failed: $e");

      // Restore toggle state if applicable
      if (deviceType == 1) {
        setState(() {
          switchStates[switchId] = _previousToggleValue ?? false;
        });
      }
    }
  }

  void deleteDevice(BuildContext context, Map<String, dynamic> device1) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).appColors.redButton,
            ),
            const SizedBox(width: 10),
            Text(
              "Delete Device",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).appColors.textSecondary,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this device?\nThis action cannot be undone.",
          style: TextStyle(
            color: Theme.of(context).appColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).appColors.textSecondary,
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).appColors.redButton,
              foregroundColor: Theme.of(context).appColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _pendingDeleteId = device1["device_id"];
              });
              _switchBloc.add(DeleteSwitchEvent(
                deviceId: device1["device_id"],
                uuid: device1["uid"],
              ));
            },
          ),
        ],
      ),
    );
  }

  int _gridColumns = 2;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    deviceDetails = widget.switchesDetails;
    deviceList = deviceDetails["list"] ?? [];
    return BlocConsumer<SwitchBloc, CommonState>(
        bloc: _switchBloc,
        listener: (context, state) {
          final apiResponse = state.apiStatus;

          if (apiResponse is ApiResponse) {
            final responseData = apiResponse.response;
            if (responseData != null && responseData["status"] == "success") {
              widget.onChanged.call();
              if (_pendingDeleteId != null) {
                setState(() {
                  deviceList.removeWhere(
                      (device) => device["device_id"] == _pendingDeleteId);
                  switchStates.remove(_pendingDeleteId);
                  _pendingDeleteId = null;
                });
              }
              Navigator.pop(context);
              commonSnackBar(context, responseData["message"]);
            }
          } else if (apiResponse is ApiFailureState) {
            final exception = apiResponse.exception.toString();
            String errorMessage = 'Something went wrong! Please try again';
            final messageMatch =
                RegExp(r'message:\s*([^}]+)').firstMatch(exception);
            if (messageMatch != null) {
              errorMessage = messageMatch.group(1)?.trim() ?? errorMessage;
            }
            showSnackBar(context, errorMessage);

            // 👉 Restore switch state if it was a toggle failure
            if (_pendingToggleId != null) {
              setState(() {
                switchStates[_pendingToggleId!] = _previousToggleValue ?? false;
                _pendingToggleId = null;
                _previousToggleValue = null;
              });
            }

            _pendingDeleteId = null;
          }
        },
        builder: (context, state) {
          return Card(
            elevation: 1,
            borderOnForeground: true,
            color: Theme.of(context).appColors.background,
            // padding: const EdgeInsets.all(16),
            // decoration: BoxDecoration(
            //   boxShadow: [
            //     BoxShadow(
            //       color: Theme.of(context)
            //           .appColors
            //           .textSecondary
            //           .withValues(alpha:0.1),
            //       spreadRadius: 5,
            //       blurRadius: 7,
            //       offset: const Offset(5, 5),
            //     ),
            //   ],
            //   color: Theme.of(context).appColors.background,
            //   borderRadius: BorderRadius.circular(12),
            //   // border: Border.all(color: Theme.of(context).appColors.primary),
            // ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (deviceDetails["title"] != null &&
                      deviceDetails["title"].isNotEmpty) ...[
                    Text(
                      deviceDetails["title"] ?? "",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    // const SizedBox(height: 10),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "View Mode:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 10),
                      ToggleButtons(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                        selectedColor: Theme.of(context).appColors.primary,
                        fillColor: Theme.of(context)
                            .appColors
                            .primary
                            .withValues(alpha: 0.1),
                        borderColor: Theme.of(context).dividerColor,
                        selectedBorderColor:
                            Theme.of(context).appColors.primary,
                        constraints:
                            const BoxConstraints(minHeight: 30, minWidth: 40),
                        isSelected: [_gridColumns == 2, _gridColumns == 3],
                        onPressed: (index) {
                          setState(() {
                            _gridColumns = (index == 0) ? 2 : 3;
                          });
                        },
                        children: const [
                          Tooltip(
                            message: "2 Columns",
                            child: Icon(FontAwesomeIcons.tableCellsLarge),
                          ),
                          Tooltip(
                            message: "3 Columns",
                            child: Icon(Icons.grid_on_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                  filteredDeviceList.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridColumns,
                            childAspectRatio: _gridColumns == 2 ? 1 : 0.7,
                            crossAxisSpacing: _gridColumns == 2 ? 15 : 10,
                            mainAxisSpacing: _gridColumns == 2 ? 15 : 10,
                          ),
                          shrinkWrap: true,
                          itemCount: filteredDeviceList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final device0 = filteredDeviceList[index];
                            final imageUrl = device0["details"]["icon"] ?? "";
                            int status = device0["details"]["status"] ?? 0;
                            return InkWell(
                              onTap: () async {
                                (device0["device_type"] == 3)
                                    ? await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MultiDevicesWidget(
                                                  deleteDevice: deleteDevice,
                                                  statusList: statusList,
                                                  switches: device0,
                                                  fanStatusList: fanStatusList,
                                                )))
                                    : _showDeviceDialog(context, device0);
                                debugPrint("Calling onchanged");
                                widget.onChanged.call();
                              },
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: _gridColumns == 2 ? 12 : 8,
                                      vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // border: Border.all(
                                    //     color: Theme.of(context)
                                    //         .appColors
                                    //         .buttonBackground),
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).appColors.primary,
                                        Theme.of(context)
                                            .appColors
                                            .buttonBackground
                                            .withValues(alpha: 0.2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .appColors
                                            .textPrimary
                                            .withValues(alpha: 0.1),
                                        blurRadius: 5,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl ?? "",
                                            height: _gridColumns == 2
                                                ? screenWidth * 0.12
                                                : screenWidth * 0.1,
                                            width: _gridColumns == 2
                                                ? screenWidth * 0.12
                                                : screenWidth * 0.1,
                                            color: Theme.of(context)
                                                .appColors
                                                .background,
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300,
                                              highlightColor:
                                                  Colors.grey.shade100,
                                              child: Container(
                                                height: screenWidth * 0.1,
                                                width: screenWidth * 0.1,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.image_outlined,
                                              color: Theme.of(context)
                                                  .appColors
                                                  .textPrimary
                                                  .withValues(alpha: 0.3),
                                              size: screenWidth * 0.1,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          device0["device_name"] ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  fontSize: _gridColumns == 2
                                                      ? 14
                                                      : 12,
                                                  color: Theme.of(context)
                                                      .appColors
                                                      .background),
                                        ),
                                        Row(
                                          children: [
                                            // 🟢 Status dot
                                            Container(
                                              width: _gridColumns == 2 ? 12 : 8,
                                              height:
                                                  _gridColumns == 2 ? 12 : 8,
                                              decoration: BoxDecoration(
                                                color: status == 1
                                                    ? Colors.green
                                                    : Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),

                                            // 📝 Status text
                                            Text(
                                              status == 1 ? "On" : "Off",
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontSize: _gridColumns == 2
                                                        ? 12
                                                        : 10,
                                                    color: Theme.of(context)
                                                        .appColors
                                                        .background,
                                                  ),
                                            ),
                                          ],
                                        )
                                      ])),
                            );
                          },
                        )
                      : const Center(child: Text("No Devices"))
                ],
              ),
            ),
          );
        });
  }

  void _showDeviceDialog(BuildContext context, Map<String, dynamic> device0) {
    showModalBottomSheet(
      isDismissible: true,
      context: context,
      backgroundColor:
          Theme.of(context).appColors.background.withValues(alpha: 0.8),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).appColors.background.withValues(alpha: 0.95),
                Theme.of(context)
                    .appColors
                    .buttonBackground
                    .withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${device0["device_name"] ?? ""} Controls",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        deleteDevice(context, device0);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).appColors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                color: Theme.of(context)
                    .appColors
                    .textPrimary
                    .withValues(alpha: 0.1),
                thickness: 1,
              ),
              const SizedBox(height: 8),
              device0["device_type"] == 2
                  ? FanSpeedControl(
                      deviceId: device0["device_id"],
                      fanStatusList: fanStatusList,
                      fanStatus: device0["details"]["statusTxt"] ?? "",
                      device: device0,
                      toggleSwitch: toggleSwitch,
                      deviceType: device0["device_type"],
                    )
                  : ToggleButtons(
                      constraints: const BoxConstraints(
                        minWidth: 100,
                        minHeight: 100,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      isSelected: [switchStates[device0["device_id"]] ?? false],
                      fillColor: Theme.of(context).appColors.green,
                      selectedColor: Theme.of(context).appColors.greenButton,
                      color: Theme.of(context).appColors.redButton,
                      onPressed: (index) {
                        final newValue =
                            !(switchStates[device0["device_id"]] ?? false);

                        toggleSwitch(
                          device0["device_id"] ?? "",
                          newValue ? "ON" : "OFF",
                          device0["uid"] ?? "",
                          device0["device_type"] ?? 0,
                        );

                        (context as Element).markNeedsBuild(); // refresh

                        setState(() {
                          switchStates[device0["device_id"]] = newValue;
                        });
                      },
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: (switchStates[device0["device_id"]] ?? false)
                                ? Theme.of(context).appColors.green
                                : Theme.of(context).appColors.red,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: (switchStates[device0["device_id"]] ??
                                        false)
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : Colors.red.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(30),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                            child: Icon(
                              Icons.power_settings_new_outlined,
                              key: ValueKey<bool>(
                                  switchStates[device0["device_id"]] ?? false),
                              size: 40,
                            ),
                          ),
                        )
                      ],
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }
}
