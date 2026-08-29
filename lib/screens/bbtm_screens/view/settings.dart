import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/fingerprints_for_lock/finger_page.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/switches/factory_reset.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../controllers/storage.dart';
import '../controllers/wifi.dart';
import '../models/switch_model.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/toast.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final StorageController _storageController = StorageController();
  final NetworkService _networkService = NetworkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: ValueListenableBuilder<String?>(
          valueListenable: _networkService.wifiNameNotifier,
          builder: (context, wifiName, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'WIFI is connected to Wifi Name',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '"$wifiName"',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: Theme.of(context).appColors.primary),
                  ),
                  CustomButton(
                    text: "Finger Prints (Locks)",
                    icon: Icons.fingerprint_outlined,
                    onPressed: () {
                      Navigator.push(
                          navigatorKey.currentContext!,
                          MaterialPageRoute(
                              builder: (context) => FingersPage()));
                    },
                  ),
                  CustomButton(
                    text: "Factory Reset",
                    icon: Icons.lock_reset_rounded,
                    bgmColor: Theme.of(context).appColors.redButton,
                    onPressed: () async {
                      List<SwitchDetails> switches =
                          await _storageController.readSwitches();
                      String localConnectStatus = wifiName ?? "Unknown";
                      for (var element in switches) {
                        if (localConnectStatus == (element.switchSSID)) {
                          Navigator.push(
                              navigatorKey.currentContext!,
                              MaterialPageRoute(
                                  builder: (context) => FactoryReset(
                                        currentSwitch: wifiName ?? "Unknown",
                                        switchDetails: element,
                                      )));
                          return;
                        }
                      }
                      showFlutterToast(
                          "⚠️ You may not be connected to AP Mode.");
                      AppSettings.openAppSettings(type: AppSettingsType.wifi);
                      return;
                    },
                  ),
                ],
              ),
            );
          }),
    );
  }
}
