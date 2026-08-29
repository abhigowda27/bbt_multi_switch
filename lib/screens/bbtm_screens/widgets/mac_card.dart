import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants.dart';
import '../../../controllers/apis.dart';
import '../../tabs_page.dart';
import '../controllers/storage.dart';
import '../controllers/wifi.dart';
import '../models/mac_model.dart';
import 'custom/toast.dart';

class MacCard extends StatefulWidget {
  final MacsDetails macsDetails;

  const MacCard({
    required this.macsDetails,
    super.key,
  });

  @override
  State<MacCard> createState() => _MacCardState();
}

class _MacCardState extends State<MacCard> {
  final StorageController _storageController = StorageController();
  final NetworkService _networkService = NetworkService();

  bool isSwitched = false;

  String? get wifiName => _networkService.wifiName;

  bool _isConnected() {
    if (wifiName == null) return false;

    return wifiName!.toLowerCase().contains(
            widget.macsDetails.switchDetails.switchSSID.toLowerCase()) ||
        widget.macsDetails.switchDetails.switchSSID
            .toLowerCase()
            .contains(wifiName!.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    _loadMacState();
  }

  Future<void> _loadMacState() async {
    isSwitched = await _storageController.getMacState(widget.macsDetails);
    setState(() {});
  }

  Future<void> _saveMacState(bool value) async {
    final updatedMac = MacsDetails(
      id: widget.macsDetails.id,
      switchDetails: widget.macsDetails.switchDetails,
      name: widget.macsDetails.name,
      isPresentInESP: value,
    );
    await _storageController.saveMacState(updatedMac);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _networkService.wifiNameNotifier,
      builder: (context, _, __) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .appColors
                    .textSecondary
                    .withValues(alpha: 0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(2, 2),
              ),
            ],
            color: Theme.of(context).appColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- DETAILS (UNCHANGED) ----------
                Row(
                  children: [
                    Text("Switch ID : ",
                        style: Theme.of(context).textTheme.titleMedium),
                    Flexible(
                      child: Text(
                        widget.macsDetails.switchDetails.switchId,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text("Switch Name : ",
                        style: Theme.of(context).textTheme.titleMedium),
                    Flexible(
                      child: Text(
                        widget.macsDetails.switchDetails.switchSSID,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text("Mac ID : ",
                        style: Theme.of(context).textTheme.titleMedium),
                    Flexible(
                      child: Text(widget.macsDetails.id,
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text("Mac Name : ",
                        style: Theme.of(context).textTheme.titleMedium),
                    Flexible(
                      child: Text(widget.macsDetails.name,
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  ],
                ),

                /// ---------- ACTIONS ----------
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).appColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /// COPY
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.macsDetails.id));
                          showToast(context, "Mac Id copied");
                        },
                        icon: Icon(Icons.copy,
                            color: Theme.of(context).appColors.textPrimary),
                      ),

                      /// DELETE
                      IconButton(
                        onPressed: () async {
                          if (!_isConnected()) {
                            showFlutterToast(
                                "You should be connected to ${widget.macsDetails.switchDetails.switchSSID} to delete the MAC");

                            AppSettings.openAppSettings(
                                type: AppSettingsType.wifi);
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (cont) {
                              return AlertDialog(
                                title: const Text('BBT Switch'),
                                content:
                                    const Text('This will delete the Switch'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('CANCEL'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      _storageController
                                          .deleteOneMacs(widget.macsDetails);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const TabsPage()),
                                        (route) => false,
                                      );
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).appColors.textPrimary),
                      ),

                      /// SWITCH
                      Switch(
                        onChanged: (value) async {
                          await _storageController
                              .deleteMacState(widget.macsDetails);

                          if (!_isConnected()) {
                            showFlutterToast(
                                "You should be connected to ${widget.macsDetails.switchDetails.switchSSID} to refresh the MAC settings");
                            return;
                          }

                          setState(() {
                            isSwitched = value;
                          });

                          if (value) {
                            await ApiConnect.hitApiPost(
                                "${Constants.routerIP}/macid",
                                {"MacID": widget.macsDetails.id});
                            await ApiConnect.hitApiPost(
                                "${Constants.routerIP}/MacOnOff",
                                {"MacCheck": "ON"});
                          } else {
                            await ApiConnect.hitApiPost(
                                "${Constants.routerIP}/MacOnOff",
                                {"MacCheck": "OFF"});
                            await ApiConnect.hitApiPost(
                                "${Constants.routerIP}/deletemac",
                                {"MacID": widget.macsDetails.id.toLowerCase()});
                          }

                          await _saveMacState(isSwitched);
                        },
                        value: isSwitched,
                        activeColor: Theme.of(context).appColors.primary,
                        activeTrackColor:
                            Theme.of(context).appColors.textSecondary,
                        inactiveThumbColor: Theme.of(context).appColors.primary,
                        inactiveTrackColor:
                            Theme.of(context).appColors.background,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
