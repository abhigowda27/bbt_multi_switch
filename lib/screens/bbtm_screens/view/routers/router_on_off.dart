import 'dart:async';

import 'package:bbtml_new/controllers/udp_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/toast.dart';
import '../../widgets/router/router_list_card.dart';

class RouterOnOff extends StatefulWidget {
  final RouterDetails routerDetails;

  const RouterOnOff({
    required this.routerDetails,
    super.key,
  });

  @override
  State<RouterOnOff> createState() => _RouterOnOffState();
}

class _RouterOnOffState extends State<RouterOnOff> {
  late Timer _timer;
  bool _isInitializing = true;
  late String selectedControl = "OFF";
  final List<String> controls = [
    "OFF",
    "LOW",
    "MEDIUM",
    "HIGH",
  ];

  final Duration _timerDuration = const Duration(minutes: 2);
  late List<Map<String, dynamic>> switchTypes;
  bool switchOn = false;
  Map<String, dynamic> statusRes = {};
  Future<List<Map<String, dynamic>>> fetchSwitches() async {
    final types =
        List<Map<String, dynamic>>.from(widget.routerDetails.switchTypes);
    return types;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initializeDevice();
    switchTypes = widget.routerDetails.switchTypes;
  }

  Future<void> _initializeDevice() async {
    try {
      if (mounted) {
        setState(() {
          _isInitializing = true;
        });
      }

      // UDP discovery ONLY during initial page load
      final discovery = Esp32MultiDiscovery();

      final List<SmartDevice> devices = await discovery.discoverAllDevices();

      debugPrint(
        'Discovered ${devices.length} devices',
      );

      // Match switch ID
      final SmartDevice? matchedDevice =
          devices.cast<SmartDevice?>().firstWhere(
                (device) => device?.id == widget.routerDetails.switchID,
                orElse: () => null,
              );

      if (matchedDevice != null) {
        debugPrint(
          'Matched device: ${matchedDevice.id}',
        );

        debugPrint(
          'Stored IP: ${widget.routerDetails.iPAddress}',
        );

        debugPrint(
          'Discovered IP: ${matchedDevice.ip}',
        );

        // Update IP only if changed
        if (widget.routerDetails.iPAddress != matchedDevice.ip) {
          debugPrint(
            'IP changed: '
            '${widget.routerDetails.iPAddress} '
            '→ ${matchedDevice.ip}',
          );

          widget.routerDetails.iPAddress = matchedDevice.ip;

          await StorageController().updateRouterIp(
            widget.routerDetails.switchID,
            matchedDevice.ip,
          );
        }
      } else {
        debugPrint(
          'Device ${widget.routerDetails.switchID} '
          'not found on network',
        );
      }

      // After UDP validation, get the switch status
      await updateSwitch();
    } catch (e) {
      debugPrint(
        'Initial device validation error: $e',
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> updateSwitch() async {
    try {
      final Map<String, dynamic> apiRes = await ApiConnect.hitApiGet(
        "${widget.routerDetails.iPAddress}/Switchstatus",
      );

      final Map<String, dynamic> res = Map<String, dynamic>.from(
        apiRes["data"],
      );

      bool anyClosed = false;

      for (var sType in widget.routerDetails.switchTypes) {
        final int physicalIndex = sType['order'];
        final String key = "ON$physicalIndex";

        if (res.containsKey(key) && res[key].toString() == "0") {
          anyClosed = true;
          break;
        }
      }

      if (!mounted) return;

      setState(() {
        statusRes = res;
        switchOn = !anyClosed;

        if (res["FAN"] == "LOW") {
          selectedControl = "LOW";
        } else if (res["FAN"] == "MED") {
          selectedControl = "MEDIUM";
        } else if (res["FAN"] == "HIGH") {
          selectedControl = "HIGH";
        } else {
          selectedControl = "OFF";
        }

        _isInitializing = false;
      });

      if (res["cert_log"] != null) {
        showCertLogPopup(res["cert_log"]);
      }
    } catch (e) {
      debugPrint(
        'updateSwitch error: $e',
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
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
    final isLargeScreen = width > 600;
    return GestureDetector(
      onTap: () => _resetTimer,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.routerDetails.routerName)),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            updateSwitch();
          },
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
          ),
        ),
        body: _isInitializing
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).appColors.buttonBackground,
                ),
              )
            : ValueListenableBuilder<String?>(
                valueListenable: NetworkService().wifiNameNotifier,
                builder: (context, wifiName, _) {
                  final currentWifi = wifiName ?? "Unknown";

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.routerDetails.switchTypes.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.all(20),
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
                                  widget.routerDetails.switchName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .appColors
                                              .background),
                                ),
                                if (widget.routerDetails.switchTypes.length > 1)
                                  Switch(
                                    onChanged: (value) async {
                                      if (!currentWifi.contains(widget
                                              .routerDetails.routerName) &&
                                          !widget.routerDetails.routerName
                                              .contains(currentWifi)) {
                                        showToast(context,
                                            "Please connect WIFI to ${widget.routerDetails.routerName} to proceed");
                                        return;
                                      }

                                      try {
                                        List<Future<void>> apiCalls = [];

                                        for (var sType in widget
                                            .routerDetails.switchTypes) {
                                          final int physicalIndex =
                                              sType['order'];
                                          final uri =
                                              "${widget.routerDetails.iPAddress}/getSwitchcmd";
                                          final payload = {
                                            "Lock_id":
                                                widget.routerDetails.switchID,
                                            "lock_passkey": widget
                                                .routerDetails.switchPasskey,
                                            "lock_cmd": value
                                                ? "ON$physicalIndex"
                                                : "OFF$physicalIndex",
                                          };

                                          apiCalls.add(
                                            ApiConnect.hitApiPost(uri, payload)
                                                .timeout(
                                                    const Duration(seconds: 1))
                                                .then((_) => debugPrint(
                                                    value ? "ON" : "OFF"))
                                                .catchError((e) => debugPrint(
                                                    "Error on switch $physicalIndex: $e")),
                                          );
                                        }

                                        if (widget.routerDetails.selectedFan!
                                            .isNotEmpty) {
                                          final uri =
                                              "${widget.routerDetails.iPAddress}/getSwitchcmd";
                                          final payload = {
                                            "Lock_id":
                                                widget.routerDetails.switchID,
                                            "lock_passkey": widget
                                                .routerDetails.switchPasskey,
                                            "lock_cmd": value ? "HIGH" : "OFF",
                                          };
                                          apiCalls.add(
                                            ApiConnect.hitApiPost(uri, payload)
                                                .timeout(
                                                    const Duration(seconds: 1))
                                                .catchError((e) => debugPrint(
                                                    "Error on fan: $e")),
                                          );
                                        }

                                        setState(() {
                                          switchOn = value;
                                        });

                                        await Future.wait(apiCalls);
                                        await updateSwitch();
                                        if (value) {
                                          commonSnackBar(
                                              navigatorKey.currentContext!,
                                              "Device turned ONALL Successfully");
                                        } else {
                                          commonSnackBar(
                                              navigatorKey.currentContext!,
                                              "Device turned OFFALL Successfully");
                                        }
                                      } catch (e) {
                                        debugPrint('Local API call timed out.');
                                      }
                                    },
                                    value: switchOn,
                                    activeThumbColor:
                                        Theme.of(context).appColors.greenButton,
                                    activeTrackColor:
                                        Theme.of(context).appColors.green,
                                    inactiveThumbColor:
                                        Theme.of(context).appColors.redButton,
                                    inactiveTrackColor:
                                        Theme.of(context).appColors.red,
                                  ),
                              ],
                            ),
                          ),
                        ],
                        FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchSwitches(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(
                                    color: Theme.of(context)
                                        .appColors
                                        .buttonBackground);
                              }
                              if (snapshot.hasError) {
                                return const Text("ERROR");
                              }
                              final switches = snapshot.data ?? [];
                              return GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: switches.length,
                                itemBuilder: (context, index) {
                                  final switchInfo = switches[index];

                                  final physicalIndex =
                                      switchInfo['order'] as int;
                                  debugPrint("======$physicalIndex");
                                  return RouterListCard(
                                    routerDetails: widget.routerDetails,
                                    index: index,
                                    switchStatus: statusRes["ON$physicalIndex"]
                                            ?.toString() ==
                                        "1",
                                    wifiName: currentWifi,
                                  );
                                },
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isLargeScreen ? 3 : 2,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                              );
                            }),
                        if (widget.routerDetails.selectedFan != null &&
                            widget.routerDetails.selectedFan!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.lightBlueAccent,
                                  Colors.greenAccent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.routerDetails.selectedFan ??
                                          "No Name",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .appColors
                                                  .background),
                                    ),
                                    const SizedBox(width: 10),
                                    const FaIcon(
                                      FontAwesomeIcons.fan,
                                      size: 35,
                                      color: Colors.deepPurpleAccent,
                                    )
                                  ],
                                ),
                                Divider(
                                  color: Theme.of(context).appColors.background,
                                ),
                                SleekCircularSlider(
                                  min: 0,
                                  max: controls.length.toDouble() - 1,
                                  initialValue: controls
                                      .indexOf(selectedControl)
                                      .toDouble(),
                                  appearance: CircularSliderAppearance(
                                    size: 150,
                                    customWidths: CustomSliderWidths(
                                      trackWidth: 8,
                                      progressBarWidth: 15,
                                      handlerSize: 12,
                                    ),
                                    customColors: CustomSliderColors(
                                      trackColors: [
                                        Colors.blueAccent,
                                        Colors.lightBlueAccent,
                                        Colors.greenAccent,
                                      ],
                                      progressBarColors: [
                                        Colors.blueAccent,
                                        Colors.lightBlueAccent,
                                        Colors.greenAccent,
                                      ],
                                      dotColor: Theme.of(context)
                                          .appColors
                                          .background,
                                      shadowColor: Colors.black26,
                                    ),
                                    infoProperties: InfoProperties(
                                      mainLabelStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .appColors
                                                  .background),
                                      modifier: (value) {
                                        final index = value.round();
                                        return controls[
                                            index]; // show control name
                                      },
                                    ),
                                  ),
                                  onChangeEnd: (value) async {
                                    final control = controls[value.round()];
                                    if (!currentWifi.contains(
                                            widget.routerDetails.routerName) &&
                                        !widget.routerDetails.routerName
                                            .contains(currentWifi)) {
                                      showToast(
                                        context,
                                        "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed",
                                      );
                                      setState(() {});
                                      return;
                                    }
                                    setState(() {
                                      selectedControl = control;
                                    });
                                    debugPrint(control);
                                    await sendFanCommand(control);
                                  },
                                ),
                              ],
                            ),
                          )
                        ]
                      ],
                    ),
                  );
                }),
      ),
    );
  }

  Future<void> sendFanCommand(String command) async {
    try {
      debugPrint("${widget.routerDetails.iPAddress}/getSwitchcmd $command ");
      final response = await ApiConnect.hitApiPost(
        "${widget.routerDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": widget.routerDetails.switchID,
          "lock_passkey": widget.routerDetails.switchPasskey,
          "lock_cmd": command,
        },
      );
      debugPrint("${response.runtimeType}");
      debugPrint(response);
      debugPrint(command);
      debugPrint("${widget.routerDetails.iPAddress}/getSwitchcmd" "$command ");
      if (response.toLowerCase() == "ok") {
        showToast(navigatorKey.currentContext!,
            "Fan '$command' executed successfully");
      } else {
        showToast(
            navigatorKey.currentContext!, "Failed to execute. Try again.");
      }
    } on DioException catch (e) {
      debugPrint("Api Error $e");
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
