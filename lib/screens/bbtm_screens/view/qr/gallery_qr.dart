import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';
import '../switches/add_switch.dart';

class GalleryQRPage extends StatefulWidget {
  const GalleryQRPage({super.key});

  @override
  State<GalleryQRPage> createState() => _GalleryQRPageState();
}

class _GalleryQRPageState extends State<GalleryQRPage> {
  SwitchDetails details = SwitchDetails(
      switchId: "Unknown",
      switchSSID: "Unknown",
      switchPassword: "Unknown",
      selectedFan: "",
      switchTypes: [],
      privatePin: "1234",
      iPAddress: "Unknown",
      wattage: 0);

  @override
  void initState() {
    super.initState();
    scanQR();
  }

  // Future<void> scanQR() async {
  //   final picker = ImagePicker();
  //   final XFile? pickedFile =
  //       await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     try {
  //       String? barcodeScanRes = await Scan.parse(pickedFile.path);
  //       if (barcodeScanRes != null) {
  //         setState(() {
  //           // var jsonR = json.decode(barcodeScanRes);
  //           // debugPrint(jsonR);
  //           // details = SwitchDetails(
  //           //     switchId: jsonR['LockId'],
  //           //     privatePin: "1234",
  //           //     switchSSID: jsonR['LockSSID'],
  //           //     switchPassword: jsonR['LockPassword'].toString(),
  //           //     iPAddress: jsonR['IPAddress'],
  //           //     switchTypes: [],
  //           //     selectedFan: "");
  //           var jsonR = json.decode(barcodeScanRes);
  //           debugPrint(jsonR.toString());
  //           debugPrint(jsonEncode(jsonEncode(jsonR)));
  //
  //           details = SwitchDetails(
  //               switchId: jsonR['SwitchId'],
  //               privatePin: jsonR['privatePin'],
  //               switchSSID: jsonR['SwitchSSID'],
  //               switchPassword: jsonR['SwitchPassword'],
  //               iPAddress: jsonR['IPAddress'],
  //               switchTypes: (jsonR['SwitchTypes'] as List<dynamic>)
  //                   .map((e) => e.toString())
  //                   .toList(),
  //               switchPassKey: jsonR['SwitchPasskey'],
  //               selectedFan: jsonR['SelectedFan']);
  //         });
  //       } else {
  //         // Handle null result from QR parsing
  //         // You can show an error message or take appropriate action
  //         debugPrint("QR code not found in the selected image.");
  //       }
  //     } catch (e) {
  //       debugPrint("$e");
  //     }
  //   }
  // }
  Future<void> scanQR() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final controller = MobileScannerController();

    try {
      final BarcodeCapture? capture =
          await controller.analyzeImage(pickedFile.path);

      if (capture == null || capture.barcodes.isEmpty) {
        debugPrint("QR code not found in the selected image.");
        showFlutterToast("❌ No QR code found in the selected image");
        return;
      }

      final String? barcodeScanRes = capture.barcodes.first.rawValue;

      if (barcodeScanRes == null || barcodeScanRes.isEmpty) {
        debugPrint("QR value is empty.");
        showFlutterToast("❌ Invalid QR code");

        return;
      }

      debugPrint(barcodeScanRes);

      final jsonR = json.decode(barcodeScanRes);
      debugPrint(jsonR.toString());
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
      if (!mounted) return;

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
            wattage: jsonR['wattage'] ?? 0);
      });
    } catch (e) {
      debugPrint("Failed to scan QR: $e");
      showFlutterToast("❌ Invalid QR format. Please select a valid QR image");
    } finally {
      controller.dispose();
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
