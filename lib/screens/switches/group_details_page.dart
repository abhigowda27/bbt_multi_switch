import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/screens/switches/widgets/fan_controller_widget.dart';
import 'package:bbtml_new/screens/switches/widgets/group_card_multi.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage(
      {super.key, required this.switchBloc, required this.groupDetails});
  final SwitchBloc switchBloc;
  final Map<String, dynamic> groupDetails;
  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  Map<String, bool> switchStates = {};
  Map<String, dynamic> statusList = {};
  Map<String, dynamic> fanStatusList = {};
  Map<String, dynamic> multiStatusList = {};
  Map<String, dynamic> deviceDetails = {};
  List<dynamic> deviceList = [];
  List<Map<String, dynamic>> filteredSwitches = [];
  final SwitchBloc _switchBloc = SwitchBloc();
  String? _pendingToggleId;
  bool? _previousToggleValue;
  bool _initialized = false;
  void setValues(Map<String, dynamic> switchesDetails) {
    final statusConfigs = switchesDetails["deviceStatus"] ?? [];

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

    deviceList = switchesDetails["list"] ?? [];

    for (var device in deviceList) {
      if (device["device_type"] == 3 && device["switches"] is List) {
        for (final sw in device["switches"]) {
          switchStates[sw["uid"]] = sw["details"]["statusTxt"] == "ON";
        }
      } else {
        switchStates[device["uid"]] = device["details"]["statusTxt"] == "ON";
      }
    }
    debugPrint("?????$statusList");
    debugPrint("?????$fanStatusList");
    debugPrint("?????$multiStatusList");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ToggleButtons(
            borderRadius: BorderRadius.circular(50),
            isSelected: [
              filteredSwitches.isNotEmpty &&
                  (switchStates[filteredSwitches.first["uid"]] ?? false),
            ],
            fillColor: Theme.of(context).appColors.green,
            selectedColor: Theme.of(context).appColors.greenButton,
            color: Theme.of(context).appColors.redButton,
            onPressed: (index) async {
              await toggleAllDevices();
            },
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: filteredSwitches.isNotEmpty &&
                          (switchStates[filteredSwitches.first["uid"]] ?? false)
                      ? Theme.of(context).appColors.green
                      : Theme.of(context).appColors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: filteredSwitches.isNotEmpty &&
                              (switchStates[filteredSwitches.first["uid"]] ??
                                  false)
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.red.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.power_settings_new_outlined,
                    key: ValueKey(
                      filteredSwitches.isNotEmpty &&
                          (switchStates[filteredSwitches.first["uid"]] ??
                              false),
                    ),
                    size: 40,
                    color: filteredSwitches.isNotEmpty &&
                            (switchStates[filteredSwitches.first["uid"]] ??
                                false)
                        ? Theme.of(context).appColors.greenButton
                        : Theme.of(context).appColors.redButton,
                  ),
                ),
              ),
            ],
          )
        ],
        title: Text("${widget.groupDetails["groupName"] ?? "Group Details"}"
            .toUpperCase()),
      ),
      body: BlocBuilder<SwitchBloc, CommonState>(
        bloc: widget.switchBloc,
        builder: (context, state) {
          ApiStatus apiResponse = state.apiStatus;
          if (apiResponse is ApiResponse) {
            final responseData = apiResponse.response;
            debugPrint("Response data====>$responseData");
            List<Map<String, dynamic>> deviceList0 = [];
            if (responseData != null &&
                responseData['data'] != null &&
                responseData['data'] is List &&
                responseData['data'].isNotEmpty) {
              final listData = responseData?['data']?[0]?['list'] ?? [];
              if (listData is List) {
                deviceList0 = listData
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList();
              }
            } else {
              debugPrint("Unexpected response format: $responseData");
            }
            if (!_initialized) {
              setValues(responseData['data'][0]);
              _initialized = true;
            }
            final groupSwitchIds =
                List<String>.from(widget.groupDetails["switches"] ?? []);

            filteredSwitches = getGroupSwitches(deviceList0, groupSwitchIds);

            return filteredSwitches.isNotEmpty
                ? deviceListWidget(filteredSwitches)
                : const Center(child: Text("No switches found in this group"));
          } else if (apiResponse is ApiLoadingState ||
              apiResponse is ApiInitialState) {
            return const CircularProgressIndicator();
          } else if (apiResponse is ApiFailureState) {
            return const Center(child: Text("No Switches Found in Cloud"));
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget deviceListWidget(List<Map<String, dynamic>> deviceList) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<SwitchBloc, CommonState>(
      bloc: _switchBloc,
      listener: (context, state) {
        final apiResponse = state.apiStatus;

        if (apiResponse is ApiResponse) {
          final responseData = apiResponse.response;

          if (responseData != null && responseData["status"] == "success") {
            showFlutterToast(responseData["message"], type: ToastType.success);
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

          if (_pendingToggleId != null) {
            setState(() {
              switchStates[_pendingToggleId!] = _previousToggleValue ?? false;

              _pendingToggleId = null;
              _previousToggleValue = null;
            });
          }
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(15),
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          final mainSwitch = deviceList[index];

          final List<dynamic> children = mainSwitch["selected_switches"] ?? [];
          debugPrint("Children: $children");
          if (mainSwitch["device_type"] == 3) {
            return GroupCardMulti(
              switches: mainSwitch,
              fanStatusList: fanStatusList,
              statusList: statusList,
            );
          } else {
            final device = deviceList[index];
            final String uid = device["uid"]?.toString() ?? "";
            final bool isExpanded = _expandedDeviceUid == uid;
            return _buildDeviceCard(
              device: device,
              screenWidth: screenWidth,
              isExpanded: isExpanded,
            );
          }
        },
        separatorBuilder: (context, index) => const SizedBox(height: 15),
      ),
    );
  }

  List<Map<String, dynamic>> getGroupSwitches(
    List<Map<String, dynamic>> deviceList,
    List<String> groupSwitchIds,
  ) {
    final List<Map<String, dynamic>> result = [];

    for (final device in deviceList) {
      final deviceType = device["device_type"];

      // Normal switch/device
      if (deviceType != 3) {
        if (groupSwitchIds.contains(device["uid"])) {
          result.add(device);
        }
        continue;
      }

      // Multi-switch device
      if (deviceType == 3 && device["switches"] is List) {
        final List<Map<String, dynamic>> selectedChildren = [];

        for (final sw in device["switches"]) {
          final switchMap = Map<String, dynamic>.from(sw);
          final String? childUid = switchMap["uid"]?.toString();

          // ONLY add children whose UUID is in the group switch list
          if (childUid != null && groupSwitchIds.contains(childUid)) {
            switchMap["device_id"] = device["device_id"];
            switchMap["main_uid"] = device["uid"];
            switchMap["main_device_name"] = device["device_name"];
            switchMap["device_type"] = device["device_type"];

            selectedChildren.add(switchMap);
          }
        }

        // Parent should be displayed only if matching children exist
        if (selectedChildren.isNotEmpty) {
          final parent = Map<String, dynamic>.from(device);

          parent["selected_switches"] = selectedChildren;

          result.add(parent);
        }
      }
    }

    debugPrint("Group UUIDs: $groupSwitchIds");
    debugPrint("Filtered grouped result: ${result[0]["selected_switches"]}");

    return result;
  }

  Future<void> toggleSwitch(
    String switchId,
    String newStatus,
    String uid,
    int deviceType,
    String? mainUid,
  ) async {
    try {
      _pendingToggleId = uid;
      _previousToggleValue = switchStates[uid];

      // For deviceType 1 (boolean switch), update internal toggle state
      if (deviceType == 1) {
        final isOn =
            newStatus == statusList.entries.firstWhere((e) => e.value == 1).key;
        setState(() {
          switchStates[uid] = isOn;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));

      final isChild = mainUid != null && mainUid.isNotEmpty;

      _switchBloc.add(
        TriggerSwitchEvent(
          deviceId: switchId,
          status: newStatus,
          uuid: isChild ? mainUid : uid,
          deviceType: deviceType, // 1 or 2
          childuid: isChild ? uid : '',
        ),
      );

      debugPrint("Switch $switchId toggled to $newStatus");
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

  String? _expandedDeviceUid;
  Widget _buildDeviceCard({
    required Map<String, dynamic> device,
    required double screenWidth,
    required bool isExpanded,
  }) {
    final String uid = device["uid"]?.toString() ?? "";

    return Column(
      children: [
        // -------------------------
        // DEVICE CARD
        // -------------------------
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).appColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).appColors.primary,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  if (_expandedDeviceUid == uid) {
                    _expandedDeviceUid = null;
                  } else {
                    _expandedDeviceUid = uid;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/group_icon.png",
                      height: screenWidth * 0.1,
                      width: screenWidth * 0.1,
                      color: Theme.of(context).appColors.textSecondary,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        device["device_name"] ?? "NA",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // -------------------------
        // EXPANDED CONTROL
        // -------------------------
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInCirc,
          child: isExpanded
              ? _buildDeviceControl(device)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDeviceControl(Map<String, dynamic> device) {
    final bool isFan = device["device_type"] == 2;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).appColors.background.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).appColors.primary,
          ),
          right: BorderSide(
            color: Theme.of(context).appColors.primary,
          ),
          bottom: BorderSide(
            color: Theme.of(context).appColors.primary,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        spacing: 15,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(
                isFan
                    ? FontAwesomeIcons.fan
                    : Icons.power_settings_new_outlined,
                size: 20,
                color: Theme.of(context).appColors.textSecondary,
              ),
              Text(
                isFan ? "Fan Control" : "Power Control",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          if (isFan)
            FanSpeedControl(
              deviceId: device["device_id"],
              fanStatusList: fanStatusList,
              fanStatus: device["details"]["statusTxt"] ?? "",
              device: device,
              toggleSwitch: toggleSwitch,
              deviceType: device["device_type"],
              isFromGroup: true,
            )
          else
            _buildPowerControl(device),
        ],
      ),
    );
  }

  Widget _buildPowerControl(Map<String, dynamic> device) {
    final bool isOn = switchStates[device["uid"]] ?? false;

    return GestureDetector(
      onTap: () {
        final bool newValue = !isOn;

        toggleSwitch(
          device["device_id"] ?? "",
          newValue ? "ON" : "OFF",
          device["uid"] ?? "",
          device["device_type"] ?? 0,
          device["main_uid"],
        );

        setState(() {
          switchStates[device["uid"]] = newValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn
              ? Theme.of(context).appColors.green
              : Theme.of(context).appColors.red,
          boxShadow: [
            BoxShadow(
              color: isOn
                  ? Colors.green.withValues(alpha: 0.35)
                  : Colors.red.withValues(alpha: 0.35),
              blurRadius: isOn ? 15 : 10,
              spreadRadius: isOn ? 3 : 1,
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Icon(
            Icons.power_settings_new_outlined,
            key: ValueKey(isOn),
            size: 40,
            color: Theme.of(context).appColors.background,
          ),
        ),
      ),
    );
  }

  Future<void> toggleAllDevices() async {
    if (filteredSwitches.isEmpty) {
      showSnackBar(context, "No devices available");
      return;
    }

    final bool currentState =
        switchStates[filteredSwitches.first["uid"]] ?? false;

    final bool newValue = !currentState;

    debugPrint(
      "========== TOGGLE ALL ==========\n"
      "Current: $currentState\n"
      "New: $newValue\n"
      "Devices: ${filteredSwitches.length}",
    );

    for (final device in filteredSwitches) {
      final int deviceType = device["device_type"] ?? 0;

      // ============================================================
      // MULTI SWITCH DEVICE - DEVICE TYPE 3
      // ============================================================
      if (deviceType == 3) {
        final List<dynamic> children = device["selected_switches"] ?? [];

        final String parentUid = device["uid"]?.toString() ?? "";

        final String deviceId = device["device_id"]?.toString() ?? "";

        if (parentUid.isEmpty || deviceId.isEmpty) {
          continue;
        }

        for (final child in children) {
          final String childUid = child["uid"]?.toString() ?? "";

          if (childUid.isEmpty) {
            continue;
          }

          await toggleSwitch(
            deviceId,
            newValue ? "ON" : "OFF",
            childUid,
            3,
            parentUid,
          );
        }

        continue;
      }
      // ============================================================
      // NORMAL SWITCH
      // ============================================================
      if (deviceType == 1) {
        final String uid = device["uid"]?.toString() ?? "";

        if (uid.isEmpty) continue;

        await toggleSwitch(
          device["device_id"]?.toString() ?? "",
          newValue ? "ON" : "OFF",
          uid,
          1,
          device["main_uid"],
        );

        debugPrint(
          "Normal Switch -> "
          "${device["device_name"]} -> "
          "${newValue ? "ON" : "OFF"}",
        );

        continue;
      }

      // ============================================================
      // FAN
      // ============================================================
      if (deviceType == 2) {
        final String uid = device["uid"]?.toString() ?? "";

        if (uid.isEmpty) continue;

        await toggleSwitch(
          device["device_id"]?.toString() ?? "",
          newValue ? "HIGH" : "OFF",
          uid,
          2,
          device["main_uid"],
        );

        debugPrint(
          "Fan -> "
          "${device["device_name"]} -> "
          "${newValue ? "HIGH" : "OFF"}",
        );
      }
    }

    if (!mounted) return;

    // Update all UI states after all API calls are completed.
    setState(() {
      for (final device in filteredSwitches) {
        final int deviceType = device["device_type"] ?? 0;

        if (deviceType == 3) {
          final List<dynamic> children = device["selected_switches"] ?? [];

          for (final child in children) {
            final String? uid = child["uid"]?.toString();

            if (uid != null && uid.isNotEmpty) {
              switchStates[uid] = newValue;
            }
          }
        } else {
          final String? uid = device["uid"]?.toString();

          if (uid != null && uid.isNotEmpty) {
            switchStates[uid] = newValue;
          }
        }
      }
    });

    debugPrint(
      "========== TOGGLE ALL COMPLETED ==========",
    );
  }
}
