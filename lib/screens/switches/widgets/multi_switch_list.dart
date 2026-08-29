import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:bbtml_new/widgets/shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'fan_controller_widget.dart';

class MultiDevicesWidget extends StatefulWidget {
  final Map<String, dynamic> switches;
  final Map<String, dynamic> fanStatusList;
  final Map<String, dynamic> statusList;
  final Function(BuildContext context, Map<String, dynamic> device)
      deleteDevice;

  const MultiDevicesWidget({
    super.key,
    required this.switches,
    required this.fanStatusList,
    required this.statusList,
    required this.deleteDevice,
  });

  @override
  State<MultiDevicesWidget> createState() => _MultiDevicesWidgetState();
}

class _MultiDevicesWidgetState extends State<MultiDevicesWidget> {
  Map<String, bool> switchStates = {};
  final SwitchBloc _switchBloc = SwitchBloc();
  final SwitchBloc _getSwitchStatusBloc = SwitchBloc();
  String? _pendingToggleId;
  bool? _previousToggleValue;
  List<dynamic> multiSwitches = [];
  bool? mainSwitchStatus = false;
  String? fanStatus;
  @override
  void initState() {
    _callSwitchStatusApi();
    super.initState();
  }

  void _callSwitchStatusApi() {
    _getSwitchStatusBloc
        .add(GetSwitchStatus(payload: {"deviceId": widget.switches["uid"]}));
  }

  Future<void> toggleSwitch(
    String switchId,
    String newStatus,
    String uid,
    int deviceType,
  ) async {
    try {
      _pendingToggleId = uid;
      _previousToggleValue = switchStates[uid];

      // For deviceType 1 (boolean switch), update internal toggle state
      if (deviceType == 1) {
        final isOn = newStatus ==
            widget.statusList.entries.firstWhere((e) => e.value == 1).key;
        setState(() {
          switchStates[uid] = isOn;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));

      _switchBloc.add(TriggerSwitchEvent(
        deviceId: switchId,
        status: newStatus,
        uuid: widget.switches["uid"],
        deviceType: 3,
        childuid: uid,
      ));

      debugPrint("Switch $uid toggled to $newStatus");
    } catch (e) {
      debugPrint("Toggle failed: $e");

      // Restore toggle state if applicable
      if (deviceType == 1) {
        setState(() {
          switchStates[uid] = _previousToggleValue ?? false;
        });
      }
    }
  }

  void showCertLogPopup(String certLog) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("🔒 Security Certificate Details"),
        content: SingleChildScrollView(
          child: Text(certLog),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Fanstatus var $fanStatus");
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.switches["device_name"] ?? "Multi Switch")),
      body: BlocListener<SwitchBloc, CommonState>(
        bloc: _switchBloc,
        listener: (context, state) {
          final apiResponse = state.apiStatus;
          if (apiResponse is ApiResponse) {
            final responseData = apiResponse.response;
            if (responseData != null && responseData["status"] == "success") {
              // widget.onChanged.call();
              commonSnackBar(context, responseData["message"]);
              if (responseData["message"] ==
                  "Device turned ONALL successfully!") {
                setState(() {
                  fanStatus = "HIGH";
                  mainSwitchStatus = true;
                  switchStates.updateAll((key, value) => true);
                });
              } else if (responseData["message"] ==
                  "Device turned OFFALL successfully!") {
                setState(() {
                  mainSwitchStatus = false;
                  fanStatus = "OFF";
                  switchStates.updateAll((key, value) => false);
                });
              }
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
          }
        },
        child: BlocConsumer<SwitchBloc, CommonState>(
            bloc: _getSwitchStatusBloc,
            listener: (context, state) {
              final apiResponse = state.apiStatus;

              if (apiResponse is ApiResponse) {
                final responseData = apiResponse.response;
                if (responseData != null &&
                    responseData["status"] == "success") {
                  debugPrint("------------$responseData");
                }
                if (responseData?["data"]?["cert_log"] != null &&
                    responseData?["data"]!["cert_log"].isNotEmpty) {
                  showCertLogPopup(responseData?["data"]!["cert_log"]);
                }
              }
            },
            builder: (context, state) {
              final apiResponse = state.apiStatus;
              if (apiResponse is ApiLoadingState ||
                  apiResponse is ApiInitialState) {
                return const Center(child: SwitchLoader());
              } else if (apiResponse is ApiResponse) {
                final responseData = apiResponse.response;
                if (responseData != null &&
                    responseData["status"] == "success") {
                  debugPrint("------------$responseData");
                }

                return switchDetails(responseData["data"] ?? {});
              } else if (apiResponse is ApiFailureState) {
                final exception = apiResponse.exception;
                return switchDetails(widget.switches,
                    isException: true, exceptionMessage: exception);
              }
              return CommonServices.failureWidget(() => _callSwitchStatusApi());
            }),
      ),
    );
  }

  bool _isSwitchStateInitialized = false;
  bool _isMainSwitchInitialized = false;

  Widget switchDetails(Map<String, dynamic> multiSwitch,
      {bool? isException = false,
      String? exceptionMessage = "Something Went Wrong"}) {
    final imageUrl = multiSwitch["details"]["icon"] ?? "";
    final screenWidth = MediaQuery.of(context).size.width;
    multiSwitches = multiSwitch["switches"] ?? [];

    debugPrint("?????????????");
    if (!_isSwitchStateInitialized) {
      for (var device in multiSwitches) {
        final id = device["uid"];
        switchStates[id] = device["details"]["statusTxt"] == "ON";
      }
      _isSwitchStateInitialized = true;
    }
    if (!_isMainSwitchInitialized) {
      mainSwitchStatus = multiSwitch["details"]["statusTxt"] == "ONALL";
      _isMainSwitchInitialized = true;
    }

    return SingleChildScrollView(
      child: Column(
        spacing: 20,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 7,
                  offset: const Offset(5, 5),
                ),
              ],
              color: Theme.of(context).appColors.primary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: CachedNetworkImage(
                  imageUrl: imageUrl ?? "",
                  height: screenWidth * 0.1,
                  width: screenWidth * 0.1,
                  color: Theme.of(context).appColors.textSecondary,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: screenWidth * 0.1,
                      width: screenWidth * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_outlined,
                    color: Theme.of(context)
                        .appColors
                        .textPrimary
                        .withValues(alpha: 0.3),
                    size: screenWidth * 0.1,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 6,
                child: Text(
                  multiSwitch["device_name"] ?? "",
                  style: TextStyle(
                    color: Theme.of(context).appColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              if (!isException!)
                Expanded(
                    flex: 3,
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(50),
                      fillColor: Theme.of(context).appColors.green,
                      selectedColor: Theme.of(context).appColors.greenButton,
                      color: Theme.of(context).appColors.redButton,
                      isSelected: [mainSwitchStatus ?? false],
                      onPressed: (index) async {
                        final newValue = !(mainSwitchStatus ?? false);

                        final confirm = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: (newValue
                                            ? Theme.of(context)
                                                .appColors
                                                .greenButton
                                            : Theme.of(context)
                                                .appColors
                                                .redButton)
                                        .withValues(alpha: 0.1),
                                    radius: 24,
                                    child: Icon(
                                      Icons.power_settings_new_outlined,
                                      color: newValue
                                          ? Theme.of(context)
                                              .appColors
                                              .greenButton
                                          : Theme.of(context)
                                              .appColors
                                              .redButton,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Confirm Action",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .appColors
                                                  .textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                newValue
                                    ? "Are you sure you want to turn ON all switches?"
                                    : "Are you sure you want to turn OFF all switches?",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .appColors
                                          .textPrimary
                                          .withValues(alpha: 0.8),
                                    ),
                              ),
                              actions: [
                                OutlinedButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).appColors.redButton,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("CANCEL"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: newValue
                                        ? Theme.of(context)
                                            .appColors
                                            .greenButton
                                        : Theme.of(context).appColors.redButton,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "YES",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          toggleSwitch(
                            multiSwitch["device_id"] ?? "",
                            newValue ? "ONALL" : "OFFALL",
                            "",
                            multiSwitch["device_type"] ?? 0,
                          );
                          setState(() {
                            mainSwitchStatus = newValue;
                          });
                        }
                      },
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: (mainSwitchStatus ?? false)
                                ? Theme.of(context).appColors.green
                                : Theme.of(context).appColors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (mainSwitchStatus ?? false)
                                    ? Colors.green.withValues(alpha: 0.5)
                                    : Colors.red.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                            child: Icon(
                              Icons.power_settings_new_outlined,
                              key: ValueKey<bool>(mainSwitchStatus ?? false),
                              size: 30,
                              color: (mainSwitchStatus ?? false)
                                  ? Theme.of(context).appColors.greenButton
                                  : Theme.of(context).appColors.redButton,
                            ),
                          ),
                        )
                      ],
                    )),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.deleteDevice(context, multiSwitch),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).appColors.red,
                    ),
                  ),
                ),
              ),
            ]),
          ),
          if (!isException)
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: multiSwitches.map((device) {
                final deviceType = device["device_type"] ?? 0;
                final imageUrl = device["details"]["icon"] ?? "";
                final deviceName = device["device_name"] ?? "";
                final switchIndex = multiSwitches
                        .where((d) => d["device_type"] == 1)
                        .toList()
                        .indexOf(device) +
                    1;

                final isFan = deviceType != 1;
                final width = isFan
                    ? MediaQuery.of(context).size.width - 40
                    : screenWidth > 600
                        ? (MediaQuery.of(context).size.width - 60) / 3
                        : (MediaQuery.of(context).size.width - 60) / 2;

                return Container(
                  width: width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 7,
                        offset: const Offset(5, 5),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).appColors.buttonBackground,
                        Theme.of(context)
                            .appColors
                            .primary
                            .withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // color: Theme.of(context)
                    //     .appColors
                    //     .buttonBackground
                    //     .withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 12),
                  child: (deviceType == 1)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: screenWidth * 0.1,
                              width: screenWidth * 0.1,
                              color: Theme.of(context).appColors.background,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: screenWidth * 0.1,
                                  width: screenWidth * 0.1,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_outlined,
                                color: Theme.of(context)
                                    .appColors
                                    .textPrimary
                                    .withValues(alpha: 0.3),
                                size: screenWidth * 0.1,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              deviceName,
                              style: TextStyle(
                                color: Theme.of(context).appColors.background,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Switch.adaptive(
                              value: switchStates[device["uid"]] ?? false,
                              activeColor:
                                  Theme.of(context).appColors.greenButton,
                              activeTrackColor:
                                  Theme.of(context).appColors.green,
                              inactiveThumbColor: Theme.of(context)
                                  .appColors
                                  .redButton
                                  .withValues(alpha: 0.5),
                              inactiveTrackColor: Theme.of(context)
                                  .appColors
                                  .red
                                  .withValues(alpha: 0.2),
                              onChanged: (newValue) {
                                toggleSwitch(
                                  multiSwitch["device_id"],
                                  newValue
                                      ? "ON$switchIndex"
                                      : "OFF$switchIndex",
                                  device["uid"] ?? "",
                                  deviceType,
                                );

                                setState(() {
                                  switchStates[device["uid"]] = newValue;
                                });
                              },
                            )
                          ],
                        )
                      : FanSpeedControl(
                          deviceId: multiSwitch["device_id"],
                          fanStatusList: widget.fanStatusList,
                          device: device,
                          fanStatus: fanStatus,
                          toggleSwitch: toggleSwitch,
                          deviceType: device["device_type"],
                        ),
                );
              }).toList(),
            )
          else
            Center(
              child: CommonServices.apiFailureWidget(
                  text: exceptionMessage ?? "",
                  onRetry: (() => _callSwitchStatusApi())),
            )
        ],
      ),
    );
  }
}
