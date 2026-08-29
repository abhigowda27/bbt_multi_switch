import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/router_on_off.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_button.dart';

class ConnectToRouterPage extends StatefulWidget {
  final RouterDetails routerDetails;
  const ConnectToRouterPage({super.key, required this.routerDetails});

  @override
  State<ConnectToRouterPage> createState() => _ConnectToRouterPageState();
}

class _ConnectToRouterPageState extends State<ConnectToRouterPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.routerDetails.routerName)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 15,
            children: [
              if (widget.routerDetails.switchTypes.isNotEmpty ||
                  widget.routerDetails.selectedFan!.isNotEmpty) ...[
                CustomButton(
                    text: "Connect to ${widget.routerDetails.routerName}",
                    onPressed: () {
                      final wifiName = NetworkService().wifiName;

                      if (!wifiName.contains(widget.routerDetails.routerName) &&
                          !widget.routerDetails.routerName.contains(wifiName)) {
                        showFlutterToast(
                            "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
                        AppSettings.openAppSettings(type: AppSettingsType.wifi);
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RouterOnOff(
                            routerDetails: widget.routerDetails,
                          ),
                        ),
                      );
                    })
              ],
              // const SizedBox(
              //   height: 15,
              // ),
              // if (widget.routerDetails.selectedFan!.isNotEmpty) ...[
              //   CustomButton(
              //       text:
              //           "Connect to ${widget.routerDetails.selectedFan}",
              //       onPressed: () {
              //         if (!_connectionStatus
              //             .contains(widget.routerDetails.routerName)) {
              //           showToast(context,
              //               "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
              //           return;
              //         }
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => FanFanControl(
              //                       routerDetails: widget.routerDetails,
              //                     )));
              //       })
              // ],

              ValueListenableBuilder<String?>(
                valueListenable: NetworkService().wifiNameNotifier,
                builder: (context, wifiName, _) {
                  final connectionStatus = wifiName ?? "Unknown";

                  return Column(
                    children: [
                      Text(
                        'WIFI is connected to Wifi Name',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
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
      ),
    );
  }
}
