import 'dart:async';

import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../custom/toast.dart';

class GroupFanSwitchCard extends StatefulWidget {
  final RouterDetails switchDetails;

  final Map<String, dynamic>? status;
  final Future<bool> Function(String command, RouterDetails switchDetails)
      onToggle;

  const GroupFanSwitchCard({
    required this.switchDetails,
    required this.status,
    required this.onToggle,
    super.key,
  });

  @override
  State<GroupFanSwitchCard> createState() => _GroupFanSwitchCardState();
}

class _GroupFanSwitchCardState extends State<GroupFanSwitchCard> {
  late String selectedControl = "OFF";

  final List<String> controls = [
    "OFF",
    "LOW",
    "MEDIUM",
    "HIGH",
  ];

  late NetworkService _networkService;
  double sliderValue = 0;
  double lastValidValue = 0;
  DateTime? _lastLocalChange;
  int _forceUpdateKey = 0;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _updateSwitch();
  }

  /// ✅ WiFi validation (NEW STANDARD)
  bool _isConnectedToRouter(String currentWifi) {
    return currentWifi.toLowerCase().contains(
              widget.switchDetails.routerName.toLowerCase(),
            ) ||
        widget.switchDetails.routerName.toLowerCase().contains(
              currentWifi.toLowerCase(),
            );
  }

  //
  @override
  void didUpdateWidget(covariant GroupFanSwitchCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status) {
      _updateSwitch();
    }
  }

  /// ✅ Fetch current FAN state
  void _updateSwitch() {
    try {
      // Ignore external updates for 3 seconds after local interaction to avoid API lag jumps
      if (_lastLocalChange != null &&
          DateTime.now().difference(_lastLocalChange!).inSeconds < 3) {
        debugPrint(
            "GroupFanSwitchCard: Ignoring external update for ${widget.switchDetails.switchID} due to recent local change");
        return;
      }

      final res = widget.status;
      if (res == null) return;

      final fanState = (res["FAN"] ?? "").toString().toUpperCase();

      if (!mounted) return;
      debugPrint(
          "GroupFanSwitchCard: _updateSwitch for ${widget.switchDetails.switchID} state: $fanState");

      setState(() {
        _forceUpdateKey++; // Increment key to force SleekCircularSlider to update its initialValue
        switch (fanState) {
          case "LOW":
          case "1":
            selectedControl = "LOW";
            sliderValue = 1;
            lastValidValue = 1;
            break;

          case "MED":
          case "MEDIUM":
          case "2":
            selectedControl = "MEDIUM";
            sliderValue = 2;
            lastValidValue = 2;
            break;

          case "HIGH":
          case "3":
            selectedControl = "HIGH";
            sliderValue = 3;
            lastValidValue = 3;
            break;

          case "OFF":
          case "0":
            selectedControl = "OFF";
            sliderValue = 0;
            lastValidValue = 0;
            break;

          default:
            // If we don't recognize the state, don't reset unless it's genuinely empty
            if (fanState.isEmpty) {
              selectedControl = "OFF";
              sliderValue = 0;
              lastValidValue = 0;
            }
        }
      });
    } catch (e) {
      debugPrint("Error updating switch status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _networkService.wifiNameNotifier,
      builder: (context, wifiName, _) {
        final currentWifi = wifiName ?? "Unknown";

        return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.withValues(alpha: 0.8),
                Colors.pinkAccent.withValues(alpha: 0.5),
                Colors.deepPurpleAccent.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              /// HEADER

              /// SLIDER
              SleekCircularSlider(
                key: ValueKey(
                    "${widget.switchDetails.switchID}_$_forceUpdateKey"),
                min: 0,
                max: controls.length.toDouble() - 1,
                initialValue: sliderValue,
                onChange: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
                appearance: CircularSliderAppearance(
                  size: 150,
                  startAngle: 150,
                  angleRange: 240,
                  customWidths: CustomSliderWidths(
                    trackWidth: 8,
                    progressBarWidth: 12,
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
                    dotColor: Colors.white,
                  ),
                  infoProperties: InfoProperties(
                    mainLabelStyle:
                        Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Theme.of(context).appColors.background,
                            ),
                    modifier: (value) {
                      return controls[value.round()];
                    },
                  ),
                ),
                onChangeEnd: (value) async {
                  final control = controls[value.round()];
                  _lastLocalChange = DateTime.now();

                  /// ✅ WiFi check
                  if (!_isConnectedToRouter(currentWifi)) {
                    showToast(
                      context,
                      "Please connect to ${widget.switchDetails.routerName}",
                    );
                    return;
                  }

                  final success =
                      await widget.onToggle(control, widget.switchDetails);
                  if (success) {
                    lastValidValue = value;
                  } else {
                    setState(() {
                      _forceUpdateKey++;
                      sliderValue = lastValidValue;
                    });
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "${widget.switchDetails.selectedFan}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).appColors.background,
                          ),
                    ),
                  ),

                  // /// Refresh
                  // IconButton(
                  //   onPressed: widget.onRefresh,
                  //   icon: Icon(
                  //     FontAwesomeIcons.arrowsRotate,
                  //     color: Theme.of(context).appColors.background,
                  //   ),
                  // ),
                  //
                  // const Icon(
                  //   FontAwesomeIcons.fan,
                  //   size: 35,
                  //   color: Colors.deepPurpleAccent,
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(context)
                  //         .appColors
                  //         .primary
                  //         .withValues(alpha: 0.12),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: Image.asset(
                  //     Constants().applianceIconAsset(
                  //       widget.switchDetails.switchType ?? "",
                  //     ),
                  //     width: 45,
                  //     height: 45,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
