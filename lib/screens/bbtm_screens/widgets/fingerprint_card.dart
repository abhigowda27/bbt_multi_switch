import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/constants.dart';
import 'package:bbtml_new/controllers/apis.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/switch_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/fingerprints_for_lock/add_finger.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:flutter/material.dart';

class FingerprintCard extends StatefulWidget {
  const FingerprintCard(
      {super.key, required this.switchDetails, required this.wifiName});

  final SwitchDetails switchDetails;
  final String wifiName;
  @override
  State<FingerprintCard> createState() => _FingerprintCardState();
}

class _FingerprintCardState extends State<FingerprintCard> {
  final StorageController _storageController = StorageController();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.switchDetails.switchSSID,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (widget.wifiName == widget.switchDetails.switchSSID) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewFingerInstallationPage(
                                      switchDetails: widget.switchDetails,
                                    )));
                        return;
                      } else {
                        showFlutterToast(
                            "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed");
                        AppSettings.openAppSettings(type: AppSettingsType.wifi);
                      }
                    },
                    icon: Icon(Icons.add_circle_outline_sharp))
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: _storageController
                  .readFingerPrintsBySwitch(widget.switchDetails.switchSSID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                final fingerprints = snapshot.data ?? [];

                if (fingerprints.isEmpty) {
                  return const Text("No fingerprints added yet");
                }
                final names = fingerprints.expand((fp) => fp.names).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fingerprint, size: 18),
                      trailing: IconButton(
                          onPressed: () async {
                            if (widget.wifiName ==
                                widget.switchDetails.switchSSID) {
                              confirmDeleteFingerPrint(
                                context,
                                names[index],
                                widget.switchDetails.switchSSID,
                              );
                            } else {
                              showFlutterToast(
                                  "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed");
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.wifi);
                            }
                          },
                          icon: Icon(Icons.delete_outline_rounded)),
                      title: Text(names[index]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmDeleteFingerPrint(
    BuildContext context,
    String name,
    String switchName,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Fingerprint"),
          content: Text("Are you sure you want to delete \"$name\"?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ApiConnect.hitApiPost(
          "${Constants.routerIP}/Fingerdelete", {"FingerID": name});
      _storageController.deleteOneFingerPrint(name, switchName);
      Navigator.push(navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => const TabsPage()));
    }
  }
}
