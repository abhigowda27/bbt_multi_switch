import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../controllers/storage.dart';
import '../../controllers/wifi.dart';
import '../../models/mac_model.dart';
import '../../models/switch_model.dart';
import '../../widgets/mac_card.dart';
import 'add_mac.dart';

class MacsPage extends StatefulWidget {
  const MacsPage({super.key});

  @override
  State<MacsPage> createState() => _MacsPageState();
}

class _MacsPageState extends State<MacsPage> {
  final StorageController _storageController = StorageController();

  Future<List<MacsDetails>> fetchContacts() async {
    return _storageController.readMacs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(
            FontAwesomeIcons.plus,
            color: Theme.of(context).appColors.background,
          ),
          onPressed: () async {
            List<SwitchDetails> switches =
                await _storageController.readSwitches();

            final wifiName = NetworkService().wifiName;

            for (var element in switches) {
              debugPrint(element.switchSSID);
              debugPrint(wifiName);

              if (wifiName == element.switchSSID) {
                Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => NewMacInstallationPage(
                      switchDetails: element,
                    ),
                  ),
                );
                return;
              }
            }

            showFlutterToast("⚠️ You may not be connected to AP Mode.");
            AppSettings.openAppSettings(type: AppSettingsType.wifi);
          }),
      appBar: AppBar(title: const Text("MAC")),
      body: FutureBuilder(
          future: fetchContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                  color: Theme.of(context).appColors.buttonBackground);
            }
            if (snapshot.hasError) {
              debugPrint("${snapshot.error}");
              return const Text("ERROR");
            }
            if (snapshot.data != null && snapshot.data!.isEmpty) {
              return CommonServices.noDataWidget();
            }
            return ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 16,
                  );
                },
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return MacCard(macsDetails: snapshot.data![index]);
                });
          }),
    );
  }
}
