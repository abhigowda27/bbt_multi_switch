import 'dart:async';

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/mandatory_text.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../controllers/apis.dart';
import '../../../../widgets/text_field.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

class AddNewRouterPage extends StatefulWidget {
  final SwitchDetails? switchDetails;
  final bool isFromSwitch;
  final String selectedWifiName;
  const AddNewRouterPage(
      {super.key,
      required this.isFromSwitch,
      this.switchDetails,
      required this.selectedWifiName});

  @override
  State<AddNewRouterPage> createState() => _AddNewRouterPageState();
}

class _AddNewRouterPageState extends State<AddNewRouterPage> {
  final StorageController _storage = StorageController();
  late String switchID;
  late String switchName;
  String? selectedFan;
  String? switchType;
  String? passKey;
  int? wattage;
  late List<Map<String, dynamic>> switchList;
  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ssid.text = widget.selectedWifiName;
    if (widget.isFromSwitch) {
      setState(() {
        switchID = widget.switchDetails!.switchId;
        switchName = widget.switchDetails!.switchSSID;
        passKey = widget.switchDetails!.switchPassKey!;
        switchList = widget.switchDetails!.switchTypes;
        selectedFan = widget.switchDetails!.selectedFan;
        switchType = widget.switchDetails!.switchType;
        wattage = widget.switchDetails!.wattage;
      });
    } else {
      getSwitchDetails();
    }
  }

  final networkService = NetworkService();

  Future<void> getSwitchDetails() async {
    final currentWifi = networkService.wifiName;

    List<SwitchDetails> switches = await _storage.readSwitches();
    for (var element in switches) {
      if (currentWifi.contains(element.switchSSID) ||
          element.switchSSID.contains(currentWifi)) {
        setState(() {
          passKey = element.switchPassKey!;
          switchID = element.switchId;
          switchName = element.switchSSID;
          switchList = element.switchTypes;
          selectedFan = element.selectedFan;
          switchType = element.switchType;
          wattage = element.wattage;
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final currentWifi = networkService.wifiName;

    return Scaffold(
        appBar: AppBar(title: const Text("Add Router")),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                richTxt(text: "Router Name"),
                CustomTextField(
                  controller: _ssid,
                  validator: (value) {
                    if (value!.isEmpty) return "SSID cannot be empty";
                    return null;
                  },
                  hintText: "New Router Name",
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                richTxt(text: "Router Password"),
                CustomTextField(
                  disableCopyPaste: true,
                  controller: _password,
                  validator: (value) {
                    if (value!.length <= 7) {
                      return "Router Password cannot be less than 8 letters";
                    }
                    return null;
                  },
                  hintText: "New Router Password",
                ),
                // ElevatedButton(
                //     onPressed: connectToWiFi, child: Text(";lkjhgf")),
                const Spacer(),
                loading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 0, 16, 16),
                          child: InkWell(
                            splashColor:
                                Theme.of(context).appColors.textSecondary,
                            // onTap: onPressed,
                            child: Container(
                              width: 200,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).appColors.textSecondary,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 1,
                                    color: Theme.of(context)
                                        .appColors
                                        .textSecondary,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      Theme.of(context).appColors.textSecondary,
                                  width: 1,
                                ),
                              ),
                              alignment: const AlignmentDirectional(0, 0),
                              child: CircularProgressIndicator(
                                color: Theme.of(context).appColors.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: CustomButton(
                          width: 200,
                          text: "Submit",
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                setState(() {
                                  loading = true;
                                });
                                if (!widget.isFromSwitch) {
                                  await getSwitchDetails();
                                }
                                debugPrint("inside submit $passKey");
                                if (passKey == null) {
                                  showToast(navigatorKey.currentContext!,
                                      "No switch found with switch $currentWifi");
                                  setState(() {
                                    loading = false;
                                  });
                                  return;
                                }
                                String? existedRouter = await _storage
                                    .getRouterNameIfSwitchIDExists(switchID);
                                if (existedRouter == _ssid.text) {
                                  showToast(navigatorKey.currentContext!,
                                      "SwitchId is already Exist with this router");
                                  setState(() {
                                    loading = false;
                                  });
                                  return;
                                }
                                if (existedRouter != null) {
                                  showDialog(
                                    context: navigatorKey.currentContext!,
                                    builder: (cont) {
                                      return AlertDialog(
                                        title: const Text('Update Router'),
                                        content: const Text(
                                            'SwitchId is already Exist, Do you want to update the existing router'),
                                        actions: [
                                          OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                loading = false;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'CANCEL',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .appColors
                                                      .primary),
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              try {
                                                await ApiConnect.hitApiGet(
                                                    "${Constants.routerIP}/");
                                                var res =
                                                    await ApiConnect.hitApiPost(
                                                        "${Constants.routerIP}/getWifiParem",
                                                        {
                                                      "router_ssid": _ssid.text,
                                                      "router_password":
                                                          _password.text,
                                                      "switch_passkey": passKey,
                                                    });
                                                String ipAddress =
                                                    res['IPAddress'];
                                                if (ipAddress
                                                    .contains("0.0.0.0")) {
                                                  showToast(
                                                      navigatorKey
                                                          .currentContext!,
                                                      "Unable to connect to IP. Try again.");
                                                  return;
                                                }
                                                RouterDetails routerDetails =
                                                    RouterDetails(
                                                        switchType: switchType,
                                                        switchID: switchID,
                                                        switchName: switchName,
                                                        routerName: _ssid.text,
                                                        routerPassword:
                                                            _password.text,
                                                        deviceMacId: res['MAC'],
                                                        switchPasskey: passKey!,
                                                        iPAddress:
                                                            res['IPAddress'],
                                                        switchTypes: switchList,
                                                        selectedFan:
                                                            selectedFan,
                                                        wattage: wattage ?? 0);
                                                await _storage.updateRouter(
                                                    routerDetails);
                                                Navigator.pushAndRemoveUntil<
                                                    dynamic>(
                                                  navigatorKey.currentContext!,
                                                  MaterialPageRoute<dynamic>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        const TabsPage(),
                                                  ),
                                                  (route) => false,
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                    "Error inside updating");
                                                debugPrint("$e");
                                                showToast(
                                                    navigatorKey
                                                        .currentContext!,
                                                    "Error");
                                              }
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .appColors
                                                      .primary),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                } else {
                                  showToast(navigatorKey.currentContext!,
                                      "You are connected to $currentWifi");
                                  await ApiConnect.hitApiGet(
                                    "${Constants.routerIP}/",
                                  );
                                  var res = await ApiConnect.hitApiPost(
                                      "${Constants.routerIP}/getWifiParem", {
                                    "router_ssid": _ssid.text,
                                    "router_password": _password.text,
                                    "switch_passkey": passKey,
                                  });
                                  String iPAddress = res['IPAddress'];
                                  if (iPAddress.contains("0.0.0.0")) {
                                    showToast(navigatorKey.currentContext!,
                                        "Unable to connect IP. Try Again., ${iPAddress.contains("0.0.0.0")}");
                                    setState(() {
                                      loading = false;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                  if (res["MAC"] == null) {
                                    showToast(navigatorKey.currentContext!,
                                        "MAC id is Null please, check with operator");
                                  }
                                  RouterDetails routerDetails = RouterDetails(
                                      switchType: switchType,
                                      switchID: switchID,
                                      switchName: switchName,
                                      routerName: _ssid.text,
                                      routerPassword: _password.text,
                                      switchPasskey: passKey!,
                                      iPAddress: res['IPAddress'],
                                      deviceMacId: res['MAC'],
                                      switchTypes: switchList,
                                      selectedFan: selectedFan,
                                      wattage: wattage ?? 0);
                                  setState(() {
                                    loading = true;
                                  });
                                  _storage.addRouters(routerDetails);
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.pushAndRemoveUntil<dynamic>(
                                    navigatorKey.currentContext!,
                                    MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          const TabsPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e, s) {
                                debugPrint(
                                    "Please connect to correct wifi $e $s");
                                showToast(navigatorKey.currentContext!,
                                    "Please connect to correct wifi");
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                      )
              ],
            ),
          ),
        ));
  }
}
