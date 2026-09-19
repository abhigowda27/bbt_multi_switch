import 'dart:async';

import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/group/group_fan_switch_card.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/router/router_list_card.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/router_model.dart';

class GroupMatrixCard extends StatelessWidget {
  final RouterDetails switchDetails;
  final Map<String, dynamic>? status;
  final Function(bool) onToggle;
  final Future<bool> Function(String, RouterDetails) onFanToggle;
  final Future<void> Function(RouterDetails, int, bool) toggleSingleSwitch;
  final VoidCallback onRefresh;
  const GroupMatrixCard({
    required this.switchDetails,
    required this.status,
    required this.onToggle,
    required this.onFanToggle,
    required this.onRefresh,
    super.key,
    required this.toggleSingleSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final fanStatus = status?["FAN"]?.toString().toUpperCase() ?? "OFF";
    final isFanOn = fanStatus != "OFF" && fanStatus != "0";
    final hasAnySwitchOn = status?.entries
            .any((e) => e.key.startsWith("ON") && e.value.toString() == "1") ??
        false;

    bool isOn = hasAnySwitchOn || isFanOn;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 5,
            // offset: const Offset(5, 5),
          ),
        ],
        color: Theme.of(context).appColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${switchDetails.switchName} - (${CommonServices().formatWatt(switchDetails.wattage ?? 0)})",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: FaIcon(
                    FontAwesomeIcons.arrowsRotate,
                    color: Theme.of(context).appColors.buttonBackground,
                  ),
                ),
                Switch(
                  onChanged: onToggle,
                  value: isOn,
                  activeThumbColor: Theme.of(context).appColors.greenButton,
                  activeTrackColor: Theme.of(context).appColors.green,
                  inactiveThumbColor: Theme.of(context).appColors.redButton,
                  inactiveTrackColor: Theme.of(context).appColors.red,
                ),
              ],
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchSwitches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                      color: Theme.of(context).appColors.buttonBackground);
                }
                if (snapshot.hasError) {
                  return const Text("ERROR");
                }
                final switches = snapshot.data ?? [];
                return Column(
                  spacing: 10,
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: switches.length,
                      itemBuilder: (context, index) {
                        final switchInfo = switches[index];
                        final physicalIndex = switchInfo['order'] as int;
                        bool isSwitchOn =
                            status?["ON$physicalIndex"]?.toString() == "1";
                        debugPrint("$status");
                        return RouterListCard(
                          routerDetails: switchDetails,
                          index: index,
                          onToggle: (value) => toggleSingleSwitch(
                              switchDetails, physicalIndex, value),
                          switchStatus: isSwitchOn,
                          wifiName: "",
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                    ),
                    if (switchDetails.selectedFan != null &&
                        switchDetails.selectedFan!.isNotEmpty)
                      GroupFanSwitchCard(
                        switchDetails: switchDetails,
                        status: status,
                        onToggle: onFanToggle,
                      )
                  ],
                );
              }),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchSwitches() async {
    return switchDetails.switchTypes;
  }
}
