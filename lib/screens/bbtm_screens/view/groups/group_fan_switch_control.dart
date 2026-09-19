import 'dart:async';

import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/group/group_fan_switch_card.dart';

class GroupFanSwitchControl extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;
  final int maximumWattage;

  const GroupFanSwitchControl({
    required this.groupName,
    required this.selectedRouter,
    required this.selectedSwitches,
    required this.maximumWattage,
    super.key,
  });

  @override
  State<GroupFanSwitchControl> createState() => _GroupFanSwitchControlState();
}

class _GroupFanSwitchControlState extends State<GroupFanSwitchControl> {
  final StorageController _storageController = StorageController();
  late Timer _timer;
  late String selectedControl = "OFF";
  final Duration _timerDuration = const Duration(seconds: 60);
  Map<String, Map<String, dynamic>> switchStatuses = {};

  List<String> controls = [
    "OFF",
    "HIGH",
  ];
  late bool isSwitchOn = false;
  Future<List<RouterDetails>> fetchRouters() async {
    return widget.selectedSwitches;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (var sw in widget.selectedSwitches) {
      _loadInitialStatus(sw);
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

  Future<void> _loadInitialStatus(RouterDetails switchDetails) async {
    try {
      Map<String, dynamic> apiRes =
          await ApiConnect.hitApiGet("${switchDetails.iPAddress}/Switchstatus");

      final res = Map<String, dynamic>.from(apiRes["data"]);

      switchStatuses[switchDetails.switchID] = res;

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
        int currentWattage = 0;

        switchStatuses.forEach((switchId, status) {
          final fanStatus = status["FAN"]?.toString().toUpperCase() ?? "OFF";

          if (fanStatus != "OFF" && fanStatus != "0") {
            final router = widget.selectedSwitches.firstWhere(
              (e) => e.switchID == switchId,
            );

            currentWattage += router.wattage ?? 0;
          }
        });

        final projectedWattage = currentWattage + (switchDetails.wattage ?? 0);

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
        _loadInitialStatus(switchDetails);
        return true;
      } else {
        showToast(
          navigatorKey.currentContext!,
          "Failed to execute. Try again.",
        );
      }
      return false;
    } on DioException catch (e) {
      debugPrint("API Error: $e");
      showToast(navigatorKey.currentContext!, "Network error");
      return false;
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      showToast(navigatorKey.currentContext!, "Something went wrong");
      return false;
    }
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

  void _resetTimer() {
    _startTimer();
    _timer.cancel();
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
        appBar: AppBar(title: const Text("Fan Control")),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 15,
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
                  children: [
                    Text(
                      widget.groupName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).appColors.background),
                    ),
                    FaIcon(
                      FontAwesomeIcons.fan,
                      size: width * 0.1,
                      color: Theme.of(context).appColors.background,
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
                            await _saveGroupSwitchState(value);
                            for (var switchDetails in routers) {
                              var totalSwitches =
                                  widget.selectedSwitches.length;
                              try {
                                for (int i = 1; i <= totalSwitches; i++) {
                                  final response = await ApiConnect.hitApiPost(
                                    "${switchDetails.iPAddress}/getSwitchcmd",
                                    {
                                      "Lock_id": switchDetails.switchID,
                                      "lock_passkey":
                                          switchDetails.switchPasskey,
                                      "lock_cmd": value ? "HIGH" : "OFF",
                                    },
                                  );
                                  // debugPrint(command);
                                  debugPrint(response);
                                  debugPrint(
                                      "${switchDetails.iPAddress}/getSwitchcmd");
                                }
                              } catch (e) {
                                debugPrint(
                                    'API call to ${switchDetails.iPAddress} timed out.');
                              }
                            }
                            setState(() {
                              isSwitchOn = value;
                            });
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
              ...widget.selectedSwitches
                  .where((switchDetail) => switchDetail.selectedFan!.isNotEmpty)
                  .map((switchDetail) {
                return GroupFanSwitchCard(
                  switchDetails: switchDetail,
                  status: switchStatuses[switchDetail.switchID],
                  onToggle: _sendFanCommand,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
