import 'dart:async';

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/wifi.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/toast.dart';
import '../../widgets/switches/switch_matrix_card.dart';

class SwitchOnOff extends StatefulWidget {
  final SwitchDetails switchDetails;

  const SwitchOnOff({
    required this.switchDetails,
    super.key,
  });

  @override
  State<SwitchOnOff> createState() => _SwitchOnOffState();
}

class _SwitchOnOffState extends State<SwitchOnOff> {
  late Timer _timer;
  final Duration _timerDuration = const Duration(minutes: 2);
  late List<Map<String, dynamic>> switchTypes;
  bool switchOn = false;
  Map<String, dynamic> statusRes = {};
  late String selectedControl = "OFF";
  final List<String> controls = [
    "OFF",
    "LOW",
    "MEDIUM",
    "HIGH",
  ];

  Future<List<Map<String, dynamic>>> fetchSwitches() async {
    return widget.switchDetails.switchTypes;
  }

  @override
  void initState() {
    super.initState();
    updateSwitch();
    switchTypes = widget.switchDetails.switchTypes;
    _startTimer();
  }

  Future<void> updateSwitch() async {
    Map<String, dynamic> apiRes = await ApiConnect.hitApiGet(
        "${widget.switchDetails.iPAddress}/Switchstatus");
    final Map<String, dynamic> res = Map<String, dynamic>.from(apiRes["data"]);
    int totalSwitches = widget.switchDetails.switchTypes.length;
    setState(() {
      bool anyClosed = false;
      for (int i = 1; i <= totalSwitches; i++) {
        final key = "ON$i";
        if (res.containsKey(key)) {
          if (res[key].toString() == "0") {
            anyClosed = true;
            break;
          }
        }
      }
      statusRes = res;
      switchOn = !anyClosed;
    });
    if (res["cert_log"] != null) {
      showCertLogPopup(res["cert_log"]);
    }
    setState(() {
      if (res["FAN"] == "LOW") {
        debugPrint("low");
        selectedControl = "LOW";
      } else if (res["FAN"] == "MED") {
        debugPrint("medium");
        selectedControl = "MEDIUM";
      } else if (res["FAN"] == "HIGH") {
        debugPrint("high");
        selectedControl = "HIGH";
      } else {
        selectedControl = "OFF";
      }
    });
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

  final NetworkService _networkService = NetworkService();

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

  bool isSameWifi(String a, String b) {
    return a.replaceAll('"', '').trim().toLowerCase() ==
        b.replaceAll('"', '').trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final isLargeScreen = width > 600;
    return GestureDetector(
      onTap: () => _resetTimer,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            updateSwitch();
          },
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(title: Text(widget.switchDetails.switchSSID)),
        body: ValueListenableBuilder<String?>(
            valueListenable: _networkService.wifiNameNotifier,
            builder: (context, wifiName, _) {
              final currentWifi = wifiName ?? "Unknown";
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.switchDetails.switchTypes.isNotEmpty) ...[
                      Container(
                        margin: EdgeInsets.all(width * 0.04),
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
                              widget.switchDetails.switchSSID,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Transform.scale(
                              scale: 1,
                              child: Switch(
                                onChanged: (value) async {
                                  if (!isSameWifi(currentWifi,
                                      widget.switchDetails.switchSSID)) {
                                    showToast(context,
                                        "Connect to ${widget.switchDetails.switchSSID}");
                                    return;
                                  }
                                  int totalSwitches =
                                      widget.switchDetails.switchTypes.length;
                                  try {
                                    // for (int i = 1; i <= totalSwitches; i++) {
                                    //   await ApiConnect.hitApiPost(
                                    //       "${widget.switchDetails.iPAddress}/getSwitchcmd",
                                    //       {
                                    //         "Lock_id": widget.switchDetails.switchId,
                                    //         "lock_passkey":
                                    //             widget.switchDetails.switchPassKey,
                                    //         "lock_cmd": value ? "ON$i" : "OFF$i",
                                    //       }).timeout(const Duration(seconds: 2));
                                    //   debugPrint(value ? "ON$i" : "OFF$i");
                                    // }

                                    // await ApiConnect.hitApiPost(
                                    //     "${widget.switchDetails.iPAddress}/getSwitchcmd",
                                    //     {
                                    //       "Lock_id": widget.switchDetails.switchId,
                                    //       "lock_passkey":
                                    //           widget.switchDetails.switchPassKey,
                                    //       "lock_cmd": value ? "ON" : "OFF",
                                    //     }).timeout(const Duration(seconds: 50));
                                    // debugPrint(value ? "ON" : "OFF");

                                    List<Future<void>> apiCalls = [];

                                    for (int i = 1;
                                        i <=
                                            totalSwitches +
                                                (widget.switchDetails
                                                        .selectedFan!.isNotEmpty
                                                    ? 1
                                                    : 0);
                                        i++) {
                                      final isFanCondition = widget
                                              .switchDetails
                                              .selectedFan!
                                              .isNotEmpty &&
                                          i == totalSwitches + 1;

                                      final uri =
                                          "${widget.switchDetails.iPAddress}/getSwitchcmd";

                                      final String command;

                                      if (isFanCondition) {
                                        // Fan command
                                        command = value ? "HIGH" : "OFF";
                                      } else {
                                        // Actual switch command
                                        final order = widget.switchDetails
                                            .switchTypes[i - 1]["order"];
                                        command =
                                            value ? "ON$order" : "OFF$order";
                                      }

                                      final payload = {
                                        "Lock_id":
                                            widget.switchDetails.switchId,
                                        "lock_passkey":
                                            widget.switchDetails.switchPassKey,
                                        "lock_cmd": command,
                                      };

                                      debugPrint("Sending command: $command");

                                      apiCalls.add(
                                        ApiConnect.hitApiPost(uri, payload)
                                            .timeout(const Duration(seconds: 1))
                                            .then((_) {
                                          debugPrint(
                                              "Successfully sent: $command");
                                        }).catchError((e) {
                                          debugPrint(
                                              "Error sending $command: $e");
                                        }),
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
                                    debugPrint(
                                        'API call to ${widget.switchDetails.iPAddress} timed out.');
                                  }
                                  await updateSwitch();
                                },
                                value: switchOn,
                                activeColor:
                                    Theme.of(context).appColors.greenButton,
                                activeTrackColor:
                                    Theme.of(context).appColors.green,
                                inactiveThumbColor:
                                    Theme.of(context).appColors.redButton,
                                inactiveTrackColor:
                                    Theme.of(context).appColors.red,
                              ),
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
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isLargeScreen ? 3 : 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final switchMap = snapshot.data!;

                              final switchName =
                                  switchMap[index]["name"].toString();
                              final physicalIndex = switchMap[index]["order"];
                              return SwitchMatrixCard(
                                switchName: switchName,
                                switchDetails: widget.switchDetails,
                                index: physicalIndex - 1,
                                switchStatus:
                                    statusRes["ON$physicalIndex"]?.toString() ==
                                        "1",
                                wifiName: currentWifi,
                              );
                            },
                          );
                        }),
                    if (widget.switchDetails.selectedFan != null &&
                        widget.switchDetails.selectedFan!.isNotEmpty) ...[
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.switchDetails.selectedFan ?? "No Name",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  FontAwesomeIcons.fan,
                                  size: 35,
                                  color: Colors.deepPurpleAccent,
                                )
                              ],
                            ),
                            Divider(
                              color: Theme.of(context).appColors.background,
                            ),
                            // CupertinoSlidingSegmentedControl<String>(
                            //   groupValue: selectedControl,
                            //   backgroundColor: Colors.transparent,
                            //   thumbColor: const Color(0xff2cd2ec),
                            //   children: {
                            //     for (var control in controls)
                            //       control: Text(
                            //         control,
                            //         style: const TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //   },
                            //   onValueChanged: (value) async {
                            //     if (!_connectionStatus
                            //             .contains(widget.switchDetails.switchSSID) &&
                            //         !widget.switchDetails.switchSSID
                            //             .contains(_connectionStatus)) {
                            //       showToast(
                            //         context,
                            //         "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed",
                            //       );
                            //       setState(() {});
                            //       return;
                            //     }
                            //     setState(() {
                            //       selectedControl = value!;
                            //     });
                            //     debugPrint(value);
                            //     await sendFanCommand(value!);
                            //   },
                            // ),
                            SleekCircularSlider(
                              min: 0,
                              max: controls.length.toDouble() - 1,
                              initialValue:
                                  controls.indexOf(selectedControl).toDouble(),
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
                                  dotColor:
                                      Theme.of(context).appColors.background,
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
                                    return controls[index]; // show control name
                                  },
                                ),
                              ),
                              onChangeEnd: (value) async {
                                final control = controls[value.round()];

                                if (!isSameWifi(currentWifi,
                                    widget.switchDetails.switchSSID)) {
                                  showToast(context,
                                      "Connect to ${widget.switchDetails.switchSSID}");
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
                    ],
                  ],
                ),
              );
            }),
      ),
    );
  }

  Future<void> sendFanCommand(String command) async {
    try {
      final response = await ApiConnect.hitApiPost(
        "${widget.switchDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": widget.switchDetails.switchId,
          "lock_passkey": widget.switchDetails.switchPassKey,
          "lock_cmd": command,
        },
      );
      debugPrint(command);
      debugPrint(response);
      debugPrint("${widget.switchDetails.iPAddress}/getSwitchcmd" "$command ");
      if (response.toLowerCase() == "ok") {
        showToast(navigatorKey.currentContext!,
            "Fan '$command' executed successfully");
      } else {
        showToast(
            navigatorKey.currentContext!, "Failed to execute. Try again.");
      }
    } on DioException catch (e) {
      debugPrint("$e");
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
