import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_button.dart';
import 'group_on_off.dart';

class ConnectToGroupWidget extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;
  final int maximumWattage;
  const ConnectToGroupWidget(
      {required this.groupName,
      required this.selectedRouter,
      required this.selectedSwitches,
      super.key,
      required this.maximumWattage});

  @override
  State<ConnectToGroupWidget> createState() => _ConnectToSwitchWidgetState();
}

class _ConnectToSwitchWidgetState extends State<ConnectToGroupWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 15,
          children: [
            if (widget.selectedSwitches
                .any((element) => element.switchTypes.isNotEmpty)) ...[
              CustomButton(
                  icon: Icons.lightbulb,
                  text: "Connect to Group Switch",
                  onPressed: () {
                    final wifiName = NetworkService().wifiName;

                    if (!wifiName.contains(widget.selectedRouter) &&
                        !widget.selectedRouter.contains(wifiName)) {
                      showFlutterToast(
                          "Please Connect WIFI to '${widget.selectedRouter}' to proceed");
                      AppSettings.openAppSettings(type: AppSettingsType.wifi);
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupSwitchOnOff(
                          maximumWattage: widget.maximumWattage,
                          groupName: widget.groupName,
                          selectedRouter: widget.selectedRouter,
                          selectedSwitches: widget.selectedSwitches,
                        ),
                      ),
                    );
                  }),
            ],
            // if (widget.selectedSwitches
            //     .any((element) => element.selectedFan!.isNotEmpty)) ...[
            //   CustomButton(
            //       text: "Connect to Group Fans",
            //       icon: Icons.wind_power_outlined,
            //       onPressed: () {
            //         final wifiName = NetworkService().wifiName;
            //
            //         if (!wifiName.contains(widget.selectedRouter) &&
            //             !widget.selectedRouter.contains(wifiName)) {
            //           showFlutterToast(
            //               "Please Connect WIFI to '${widget.selectedRouter}' to proceed");
            //           AppSettings.openAppSettings(type: AppSettingsType.wifi);
            //           return;
            //         }
            //
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => GroupFanSwitchControl(
            //               groupName: widget.groupName,
            //               selectedRouter: widget.selectedRouter,
            //               selectedSwitches: widget.selectedSwitches,
            //               maximumWattage: widget.maximumWattage,
            //             ),
            //           ),
            //         );
            //       }),
            // ],
            ValueListenableBuilder<String?>(
              valueListenable: NetworkService().wifiNameNotifier,
              builder: (context, wifiName, _) {
                final connectionStatus = wifiName ?? "Unknown";

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'WIFI is connected to Wifi Name',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '"$connectionStatus"',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                                color: Theme.of(context).appColors.primary),
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
