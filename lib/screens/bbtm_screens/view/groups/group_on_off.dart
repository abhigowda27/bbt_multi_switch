import 'dart:async';

import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' show Toast;

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/group/group_matrix_card.dart';

class GroupSwitchOnOff extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;
  final int maximumWattage;
  const GroupSwitchOnOff({
    required this.groupName,
    required this.selectedRouter,
    required this.selectedSwitches,
    super.key,
    required this.maximumWattage,
  });

  @override
  State<GroupSwitchOnOff> createState() => _GroupSwitchOnOffState();
}

class _GroupSwitchOnOffState extends State<GroupSwitchOnOff> {
  final StorageController _storageController = StorageController();
  late bool isSwitchOn = false;
  late Timer _timer;
  final Duration _timerDuration = const Duration(seconds: 3000000);
  Map<String, Map<String, dynamic>> switchStatuses = {};
  late Future<List<RouterDetails>> _routersFuture;

  Future<List<RouterDetails>> fetchRouters() async {
    return widget.selectedSwitches;
  }

  int calculateCurrentLoad() {
    int total = 0;

    for (var router in widget.selectedSwitches) {
      final status = switchStatuses[router.switchID];

      if (status == null) continue;

      // Check if ANY switch is ON
      final hasAnyOn = status.entries.any(
        (e) => e.key.startsWith("ON") && e.value.toString() == "1",
      );

      // Check if FAN is ON
      final fanStatus = status["FAN"]?.toString().toUpperCase() ?? "OFF";
      final isFanOn = fanStatus != "OFF" && fanStatus != "0";

      // ✅ Add FULL router wattage if either switch or fan is ON
      if (hasAnyOn || isFanOn) {
        total += router.wattage ?? 0;
      }
    }

    return total;
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

  Future<void> loadInitialStatus(RouterDetails switchDetails) async {
    try {
      Map<String, dynamic> apiRes =
          await ApiConnect.hitApiGet("${switchDetails.iPAddress}/Switchstatus");

      final res = Map<String, dynamic>.from(apiRes["data"]);

      switchStatuses[switchDetails.switchID] = res;
      if (res["cert_log"] != null) {
        showCertLogPopup(res["cert_log"]);
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error loading status");
    }
  }

  Future<bool> _sendFanCommand(
    String command,
    RouterDetails switchDetails,
  ) async {
    try {
      final currentStatus = switchStatuses[switchDetails.switchID]?["FAN"]
              ?.toString()
              .toUpperCase() ??
          "OFF";
      // Only validate when turning ON
      final isCurrentlyOff = currentStatus == "OFF" || currentStatus == "0";

      final isTurningOn = command != "OFF";

      if (isCurrentlyOff && isTurningOn) {
        int currentWattage = calculateCurrentLoad();

        // Check if this router's wattage is already included in currentLoad (because a switch is ON)
        final status = switchStatuses[switchDetails.switchID];
        final hasAnySwitchOn = status?.entries.any(
              (e) => e.key.startsWith("ON") && e.value.toString() == "1",
            ) ??
            false;

        // If a switch is already ON, currentWattage already includes this router's wattage.
        // If no switch is ON (and fan was OFF), we need to add it to check projection.
        final projectedWattage = hasAnySwitchOn
            ? currentWattage
            : currentWattage + (switchDetails.wattage ?? 0);

        if (projectedWattage > widget.maximumWattage) {
          showFlutterToast(
              "Maximum wattage exceeded (${widget.maximumWattage}W)",
              type: ToastType.warning,
              len: Toast.LENGTH_SHORT);

          return false;
        }
      }

      final response = await ApiConnect.hitApiPost(
        "${switchDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": switchDetails.switchID,
          "lock_passkey": switchDetails.switchPasskey,
          "lock_cmd": command,
        },
      );

      final res = response.toString().toLowerCase();

      if (res.contains("ok")) {
        showFlutterToast("Fan '$command' executed successfully",
            type: ToastType.success, len: Toast.LENGTH_SHORT);
        await loadInitialStatus(switchDetails);
        return true;
      } else {
        showToast(
          context,
          "Failed to execute. Try again.",
        );
      }
      return false;
    } on DioException catch (e) {
      debugPrint("Unexpected Error: $e");
      showFlutterToast("Something went wrong: ${e.type.name}\n${e.response}",
          type: ToastType.error, len: Toast.LENGTH_SHORT);
      return false;
    }
  }

  Future<void> toggleSwitch(RouterDetails switchDetails, bool value) async {
    final totalSwitches = switchDetails.switchTypes.length;

    int currentLoad = calculateCurrentLoad();
    final data = switchStatuses[switchDetails.switchID];

    // Check if router is already ON (any switch or fan)
    final fanStatus = data?["FAN"]?.toString().toUpperCase() ?? "OFF";
    final isFanOn = fanStatus != "OFF" && fanStatus != "0";

    final switchValues = data?.entries
        .where((e) => e.key.startsWith("ON"))
        .map((e) => e.value.toString())
        .toList();

    final hasAnySwitchOn = switchValues?.any((v) => v == "1") ?? false;
    final isAlreadyPartiallyOn = hasAnySwitchOn || isFanOn;

    final additionalLoad = isAlreadyPartiallyOn ? 0 : switchDetails.wattage;

    if (value && !isAlreadyPartiallyOn) {
      if (currentLoad + additionalLoad! > widget.maximumWattage) {
        showFlutterToast(
          "Max wattage will be exceeded! Cannot turn ON ${switchDetails.switchName}",
          type: ToastType.warning,
          len: Toast.LENGTH_SHORT,
        );
        return;
      }
    }

    bool hasError = false;

    // Execute all switch commands
    for (int i = 1; i <= totalSwitches; i++) {
      final order = switchDetails.switchTypes[i - 1]["order"];
      try {
        await ApiConnect.hitApiPost(
          "${switchDetails.iPAddress}/getSwitchcmd",
          {
            "Lock_id": switchDetails.switchID,
            "lock_passkey": switchDetails.switchPasskey,
            "lock_cmd": value ? "ON$order" : "OFF$order",
          },
        ).timeout(const Duration(seconds: 5));
      } on DioException catch (e) {
        hasError = true;
        debugPrint("Switch $i failed: ${e.message}");
      } catch (e) {
        hasError = true;
        debugPrint("Switch $i failed: $e");
      }
    }

    // Execute fan command
    if (switchDetails.selectedFan != null &&
        switchDetails.selectedFan!.isNotEmpty) {
      try {
        await ApiConnect.hitApiPost(
          "${switchDetails.iPAddress}/getSwitchcmd",
          {
            "Lock_id": switchDetails.switchID,
            "lock_passkey": switchDetails.switchPasskey,
            "lock_cmd": value ? "HIGH" : "OFF",
          },
        ).timeout(const Duration(seconds: 5));
      } on DioException catch (e) {
        hasError = true;
        debugPrint("Fan command failed: ${e.message}");
      } catch (e) {
        hasError = true;
        debugPrint("Fan command failed: $e");
      }
    }

    // Refresh latest status
    await loadInitialStatus(switchDetails);

    // Show result
    if (!hasError) {
      commonSnackBar(
        navigatorKey.currentContext!,
        "${switchDetails.switchName} turned ${value ? "ON" : "OFF"} Successfully",
      );
    } else {
      showFlutterToast(
        "${switchDetails.switchName}: Some switches failed to respond.",
        type: ToastType.warning,
        len: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> toggleSingleSwitch(
      RouterDetails switchDetails, int switchIndex, bool value) async {
    int currentLoad = calculateCurrentLoad();
    final data = switchStatuses[switchDetails.switchID];

    // Check if router already has any switch/fan ON
    final fanStatus = data?["FAN"]?.toString().toUpperCase() ?? "OFF";
    final isFanOn = fanStatus != "OFF" && fanStatus != "0";

    final hasAnySwitchOn = data?.entries.any(
          (e) => e.key.startsWith("ON") && e.value.toString() == "1",
        ) ??
        false;

    final isAlreadyPartiallyOn = hasAnySwitchOn || isFanOn;

    // Add wattage only if this router is completely OFF
    final additionalLoad =
        isAlreadyPartiallyOn ? 0 : (switchDetails.wattage ?? 0);

    if (value && !isAlreadyPartiallyOn) {
      if (currentLoad + additionalLoad > widget.maximumWattage) {
        showFlutterToast(
          "Max wattage will be exceeded! Cannot turn ON ${switchDetails.switchName}",
          type: ToastType.warning,
          len: Toast.LENGTH_SHORT,
        );
        return;
      }
    }

    try {
      await ApiConnect.hitApiPost(
        "${switchDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": switchDetails.switchID,
          "lock_passkey": switchDetails.switchPasskey,
          "lock_cmd": value ? "ON$switchIndex" : "OFF$switchIndex",
        },
      );

      await loadInitialStatus(switchDetails);

      commonSnackBar(
        navigatorKey.currentContext!,
        "${switchDetails.switchName} Switch $switchIndex "
        "${value ? "turned ON" : "turned OFF"} Successfully",
      );
    } on DioException catch (e) {
      debugPrint(e.toString());
      showFlutterToast("Something went wrong: ${e.type.name}\n${e.response}",
          type: ToastType.error, len: Toast.LENGTH_SHORT);
    }
  }

  @override
  void initState() {
    super.initState();
    _routersFuture = fetchRouters();
    _startTimer();
    for (var sw in widget.selectedSwitches) {
      loadInitialStatus(sw);
    }
    _loadSwitchState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  void _resetTimer() {
    _timer.cancel();
    debugPrint("starts reloading");
    _startTimer();
  }

  Future<void> _loadSwitchState() async {
    bool state = await _storageController.loadGroupSwitchState();
    setState(() {
      isSwitchOn = state;
    });
  }

  Future<void> _saveGroupSwitchState(bool value) async {
    setState(() {
      isSwitchOn = value;
    });
    await _storageController.saveGroupSwitchState(value);
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const TabsPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return GestureDetector(
      onTap: _resetTimer,
      child: Scaffold(
        appBar: AppBar(title: const Text("GROUP SWITCH")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 7,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  color: Theme.of(context)
                      .appColors
                      .primary
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.groupName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<List<RouterDetails>>(
                      future: fetchRouters(),
                      builder: (context, routerSnapshot) {
                        if (routerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                              color:
                                  Theme.of(context).appColors.buttonBackground);
                        }
                        if (routerSnapshot.hasError) {
                          return const Text("ERROR");
                        }
                        final List<RouterDetails> routers =
                            routerSnapshot.data ?? [];
                        return Switch(
                          onChanged: (value) async {
                            if (value) {
                              int currentLoad = calculateCurrentLoad();
                              int additionalLoad = 0;

                              for (var switchDetails in routers) {
                                final status =
                                    switchStatuses[switchDetails.switchID];

                                final hasAnyOn = status?.entries.any((e) =>
                                        (e.key.startsWith("ON") &&
                                            e.value.toString() == "1") ||
                                        (e.key == "FAN" &&
                                            e.value.toString().toUpperCase() !=
                                                "OFF" &&
                                            e.value.toString() != "0")) ??
                                    false;

                                if (!hasAnyOn) {
                                  additionalLoad += switchDetails.wattage ?? 0;
                                }
                              }

                              if (currentLoad + additionalLoad >
                                  widget.maximumWattage) {
                                showFlutterToast(
                                  "Max wattage exceeded! Cannot turn ON group",
                                  type: ToastType.warning,
                                  len: Toast.LENGTH_SHORT,
                                );
                                return;
                              }
                            }

                            // ✅ Only executes if safe
                            await _saveGroupSwitchState(value);
//  Execute all ON/OFF commands first
                            for (var switchDetails in routers) {
                              var totalSwitches =
                                  switchDetails.switchTypes.length;

                              try {
                                for (int i = 1; i <= totalSwitches; i++) {
                                  final order =
                                      switchDetails.switchTypes[i - 1]["order"];
                                  await ApiConnect.hitApiPost(
                                    "${switchDetails.iPAddress}/getSwitchcmd",
                                    {
                                      "Lock_id": switchDetails.switchID,
                                      "lock_passkey":
                                          switchDetails.switchPasskey,
                                      "lock_cmd":
                                          value ? "ON$order" : "OFF$order",
                                    },
                                  ).timeout(const Duration(seconds: 5));
                                }

                                if (switchDetails.selectedFan != null &&
                                    switchDetails.selectedFan!.isNotEmpty) {
                                  await ApiConnect.hitApiPost(
                                    "${switchDetails.iPAddress}/getSwitchcmd",
                                    {
                                      "Lock_id": switchDetails.switchID,
                                      "lock_passkey":
                                          switchDetails.switchPasskey,
                                      "lock_cmd": value ? "HIGH" : "OFF",
                                    },
                                  ).timeout(const Duration(seconds: 5));
                                }
                              } catch (e) {
                                debugPrint(
                                    'API call failed for ${switchDetails.switchName}');
                              }
                            }

                            for (var switchDetails in routers) {
                              await loadInitialStatus(switchDetails);
                            }

                            setState(() {
                              isSwitchOn = value;
                            });

                            commonSnackBar(
                              navigatorKey.currentContext!,
                              value
                                  ? "Group turned ON successfully"
                                  : "Group turned OFF successfully",
                            );
                          },
                          value: isSwitchOn,
                          activeThumbColor:
                              Theme.of(context).appColors.greenButton,
                          activeTrackColor: Theme.of(context).appColors.green,
                          inactiveThumbColor:
                              Theme.of(context).appColors.redButton,
                          inactiveTrackColor: Theme.of(context).appColors.red,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Text(
                "Maximum Wattage ${CommonServices().formatWatt(widget.maximumWattage)}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              FutureBuilder<List<RouterDetails>>(
                future: _routersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                        color: Theme.of(context).appColors.buttonBackground);
                  }
                  if (snapshot.hasError) {
                    return const Text("ERROR");
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final switchItem = snapshot.data![index];
                      if (switchItem.switchTypes.isNotEmpty ||
                          (switchItem.selectedFan != null &&
                              switchItem.selectedFan!.isNotEmpty)) {
                        return GroupMatrixCard(
                          key: ValueKey("matrix_${switchItem.switchID}"),
                          switchDetails: switchItem,
                          toggleSingleSwitch: toggleSingleSwitch,
                          status: switchStatuses[switchItem.switchID],
                          onToggle: (value) => toggleSwitch(switchItem, value),
                          onFanToggle: (command, details) =>
                              _sendFanCommand(command, details),
                          onRefresh: () => loadInitialStatus(switchItem),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 15);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
