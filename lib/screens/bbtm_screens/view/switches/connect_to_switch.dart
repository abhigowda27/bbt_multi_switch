import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/switches/switch_on_off.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../controllers/wifi.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';

class ConnectToSwitchPage extends StatefulWidget {
  final SwitchDetails switchDetails;
  const ConnectToSwitchPage({required this.switchDetails, super.key});

  @override
  State<ConnectToSwitchPage> createState() => _ConnectToSwitchPageState();
}

class _ConnectToSwitchPageState extends State<ConnectToSwitchPage> {
  final NetworkService _networkService = NetworkService();

  bool isSameWifi(String a, String b) {
    return a.replaceAll('"', '').trim().toLowerCase() ==
        b.replaceAll('"', '').trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.switchDetails.switchSSID),
      ),
      body: ValueListenableBuilder<String?>(
        valueListenable: _networkService.wifiNameNotifier,
        builder: (context, wifiName, _) {
          final currentWifi = wifiName ?? "Unknown";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 15,
              children: [
                /// 🔹 CONNECT BUTTON
                if (widget.switchDetails.switchTypes.isNotEmpty ||
                    widget.switchDetails.selectedFan!.isNotEmpty)
                  CustomButton(
                    icon: Icons.lightbulb_outlined,
                    text: "Connect to ${widget.switchDetails.switchSSID}",
                    onPressed: () {
                      if (!isSameWifi(
                          currentWifi, widget.switchDetails.switchSSID)) {
                        showFlutterToast(
                          "⚠️ Please connect WiFi to '${widget.switchDetails.switchSSID}'",
                        );
                        AppSettings.openAppSettings(
                          type: AppSettingsType.wifi,
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SwitchOnOff(
                            switchDetails: widget.switchDetails,
                          ),
                        ),
                      );
                    },
                  ),

                /// 🔹 WIFI STATUS
                Text(
                  'WIFI is connected to Wifi Name',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '"$currentWifi"',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Theme.of(context).appColors.primary,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
