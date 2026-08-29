import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/qr/scan_qr_page.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';
import '../switches/add_switch.dart';

class QRView extends StatefulWidget {
  const QRView({super.key});

  @override
  State<QRView> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scanQR();
    });
  }

  SwitchDetails details = SwitchDetails(
    switchId: "Unknown",
    switchSSID: "Unknown",
    switchPassword: "Unknown",
    privatePin: "1234",
    iPAddress: "Unknown",
    switchTypes: [],
    selectedFan: "",
    wattage: 0,
  );

  // Future<void> scanQR() async {
  //   String barcodeScanRes;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }
  //
  //   if (!mounted) return;
  //   debugPrint(barcodeScanRes.toString());
  //   setState(() {
  //     // var jsonR = json.decode(barcodeScanRes);
  //     // details = SwitchDetails(
  //     //     switchId: jsonR['LockId'],
  //     //     privatePin: "1234",
  //     //     switchSSID: jsonR['LockSSID'],
  //     //     switchPassword: jsonR['LockPassword'].toString(),
  //     //     iPAddress: jsonR['IPAddress'],
  //     //     switchTypes: [],
  //     //     selectedFan: "");
  //
  //     var jsonR = json.decode(barcodeScanRes);
  //     debugPrint(jsonR.toString());
  //
  //     details = SwitchDetails(
  //         switchId: jsonR['SwitchId'],
  //         privatePin: jsonR['privatePin'],
  //         switchSSID: jsonR['SwitchSSID'],
  //         switchPassword: jsonR['SwitchPassword'],
  //         iPAddress: jsonR['IPAddress'],
  //         switchTypes: (jsonR['SwitchTypes'] as List<dynamic>)
  //             .map((e) => e.toString())
  //             .toList(),
  //         switchPassKey: jsonR['SwitchPasskey'],
  //         selectedFan: jsonR['SelectedFan']);
  //   });
  // }

  Future<void> scanQR() async {
    final String? barcodeScanRes = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );

    if (!mounted || barcodeScanRes == null || barcodeScanRes.isEmpty) return;

    debugPrint(barcodeScanRes);

    try {
      final jsonR = json.decode(barcodeScanRes);
      final List<String> switchTypeNames =
          List<String>.from(jsonR['SwitchTypes'] ?? []);

      final List<Map<String, dynamic>> switchTypes = switchTypeNames
          .asMap()
          .entries
          .map((entry) => {
                'name': entry.value,
                'order': entry.key + 1,
              })
          .toList();
      setState(() {
        details = SwitchDetails(
            switchId: jsonR['SwitchId'],
            privatePin: jsonR['privatePin'],
            switchSSID: jsonR['SwitchSSID'],
            switchPassword: jsonR['SwitchPassword'],
            iPAddress: jsonR['IPAddress'],
            switchTypes: switchTypes,
            switchPassKey: jsonR['SwitchPasskey'],
            selectedFan: jsonR['SelectedFan'],
            wattage: 0);
      });
    } catch (e) {
      debugPrint("Invalid QR JSON: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid QR Code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("QR Details")),
        body: details.switchId == "Unknown"
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).appColors.buttonBackground))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).appColors.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .appColors
                              .textSecondary
                              .withValues(alpha: 0.4),
                          spreadRadius: 2,
                          blurRadius: 1,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          context,
                          title: "Switch ID",
                          value: details.switchId,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          title: "Switch Name",
                          value: details.switchSSID,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          title: "Switch Password",
                          value: details.switchPassword,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .appColors
                                .primary
                                .withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context)
                                  .appColors
                                  .primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                              "⚠️ Action required: Connect to WiFi '${details.switchSSID}' with the given password before proceeding.",
                              style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ],
                    ),
                  ),

                  /// WIFI STATUS DISPLAY
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'You are currently connected to:',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<String?>(
                          valueListenable: NetworkService().wifiNameNotifier,
                          builder: (context, wifiName, _) {
                            return Text(
                              '"${wifiName ?? "Unknown"}"',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: Theme.of(context).appColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomButton(
                        icon: FontAwesomeIcons.circleArrowRight,
                        text: "Proceed",
                        onPressed: () {
                          final wifiName = NetworkService().wifiName;

                          if (!wifiName.contains(details.switchSSID) &&
                              !details.switchSSID.contains(wifiName)) {
                            showFlutterToast(
                                "⚠️ Action required: Connect to WiFi '${details.switchSSID}' with the given password and proceed again.");
                            AppSettings.openAppSettings(
                                type: AppSettingsType.wifi);
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNewSwitchesPage(
                                switchDetails: details,
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ));
  }

  /// Helper widget for clean rows
  Widget _buildInfoRow(BuildContext context,
      {required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
