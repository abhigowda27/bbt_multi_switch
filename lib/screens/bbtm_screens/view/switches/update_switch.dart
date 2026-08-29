import 'dart:convert';

import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/appliance_model.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/mandatory_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants.dart';
import '../../../../controllers/apis.dart';
import '../../../../widgets/text_field.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({required this.switchDetails, super.key});

  final SwitchDetails switchDetails;

  @override
  State<UpdatePage> createState() => _UpdateSwitchPageState();
}

class _UpdateSwitchPageState extends State<UpdatePage> {
  @override
  void initState() {
    super.initState();
    _loadAppliances();
    _password.text = widget.switchDetails.switchPassword;
    _password1.text = widget.switchDetails.switchPassword;
    _ssid.text = widget.switchDetails.switchSSID;
    _passKey.text = widget.switchDetails.switchPassKey!;
    _privatePin.text = widget.switchDetails.privatePin;
    // Initialize controllers for switch types
    final sortedTypes =
        List<Map<String, dynamic>>.from(widget.switchDetails.switchTypes)
          ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

    _switchTypeControllers = sortedTypes
        .map((entry) => {
              'type': TextEditingController(text: entry['name']),
              'order': TextEditingController(text: entry['order'].toString()),
            })
        .toList();

    // Selected fan
    if (widget.switchDetails.selectedFan?.isNotEmpty ?? false) {
      _fanRequired = true;
      _selectedFanController.text = widget.switchDetails.selectedFan!;
    } else {
      _fanRequired = false;
    }
  }

  int getNextAvailableOrder() {
    final maxOrder = _fanRequired ? 4 : 5;

    final usedOrders = _switchTypeControllers
        .map((controller) => int.tryParse(controller['order']!.text))
        .whereType<int>()
        .toSet();

    for (int order = 1; order <= maxOrder; order++) {
      if (!usedOrders.contains(order)) {
        return order;
      }
    }

    return maxOrder;
  }

  List<Appliance> _appliances = [];
  Appliance? _selectedAppliance;
  int? selectedValue;

  Map<String, List<int>> applianceWattMap = {
    "LIGHT": [20, 50, 80],
    "FAN": [20, 50, 100],
    "AC": [500, 1000, 1500, 2000],
    "TV": [50, 100, 150, 200],
    "FRIDGE": [100, 150, 200, 300],
    "WM": [500, 1000, 1500],
    "MW": [800, 1000, 1200, 1500],
    "GEYSER": [1000, 1500, 2000],
    "DOOR_LOCK": [5, 10, 20],
    "DEFAULT": [20, 50, 100, 500, 1000, 1500, 2000],
  };
  List<int> getWattList() {
    final code = _selectedAppliance?.code;
    if (code != null && applianceWattMap.containsKey(code)) {
      return applianceWattMap[code]!;
    }
    return applianceWattMap["DEFAULT"]!;
  }

  Future<void> _loadAppliances() async {
    final jsonString =
        await rootBundle.loadString('assets/json/appliances_data.json');

    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _appliances = (jsonData['appliances'] as List)
        .map((e) => Appliance.fromJson(e))
        .toList();

    // ✅ Prefill appliance
    if (widget.switchDetails.switchType != null) {
      _selectedAppliance = _appliances.firstWhere(
        (a) => a.code == widget.switchDetails.switchType,
        orElse: () => _appliances.first,
      );
    }

    final savedWatt = widget.switchDetails.wattage;
    final validWatts = getWattList();

    if (validWatts.contains(savedWatt)) {
      selectedValue = savedWatt;
    } else {
      selectedValue = null;
    }

    setState(() {});
  }

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // final TextEditingController _switchId = TextEditingController();
  bool _fanRequired = true;
  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _passKey = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password1 = TextEditingController();
  final TextEditingController _privatePin = TextEditingController();
  List<Map<String, TextEditingController>> _switchTypeControllers = [];
  final TextEditingController _selectedFanController = TextEditingController();

  final StorageController _storageController = StorageController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String? validateOrder(String? value, int currentIndex) {
    if (value == null || value.trim().isEmpty) {
      return "Order is required";
    }

    final order = int.tryParse(value);

    if (order == null) {
      return "Enter a valid order";
    }

    final maxOrder = _fanRequired ? 4 : 5;

    if (order < 1 || order > maxOrder) {
      return "Order must be between 1 and $maxOrder";
    }

    // Check duplicate order
    for (int i = 0; i < _switchTypeControllers.length; i++) {
      if (i == currentIndex) continue;

      final otherOrder = int.tryParse(_switchTypeControllers[i]['order']!.text);

      if (otherOrder == order) {
        return "Order $order is already used";
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AP Update")),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                richTxt(text: "Switch Name"),
                CustomTextField(
                  controller: _ssid,
                  validator: (value) {
                    if (value!.isEmpty) return "SSID cannot be empty";
                    return null;
                  },
                  hintText: "New Switch Name",
                ),
                richTxt(text: "Switch Password"),
                CustomTextField(
                  obscureText: !_showPassword,
                  controller: _password,
                  validator: (value) {
                    if (value!.length <= 7) {
                      return "Switch Password cannot be less than 8 letters";
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  hintText: "New Password",
                ),
                richTxt(text: "Confirm Password"),
                CustomTextField(
                  obscureText: !_showConfirmPassword,
                  controller: _password1,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value!.length <= 7) {
                      return "Switch Password cannot be less than 8 letters";
                    }
                    if (_password.text != _password1.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                  hintText: "New Password",
                ),
                richTxt(text: "PIN"),
                CustomTextField(
                  maxLength: 4,
                  controller: _privatePin,
                  validator: (value) {
                    if (value!.length <= 3) {
                      return "Switch Pin cannot be less than 4 letters";
                    }
                    return null;
                  },
                  hintText: "New Pin",
                ),
                richTxt(text: "Switch PassKey"),
                CustomTextField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "PassKey Cannot be empty";
                    }
                    if (value.length <= 7) {
                      return "PassKey Cannot be less than 8 letters";
                    }
                    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
                    if (validCharacters.hasMatch(value)) {
                      return "Passkey should be alphanumeric";
                    }
                    return null;
                  },
                  controller: _passKey,
                  hintText: "New Passkey",
                ),
                richTxt(text: "Select watt range"),
                DropdownButtonFormField<int>(
                  initialValue: selectedValue, // ✅ reactive binding
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: Text(
                    _selectedAppliance == null
                        ? "Select appliance first"
                        : "Select Wattage",
                  ),
                  items: getWattList().map((watt) {
                    return DropdownMenuItem<int>(
                      value: watt,
                      child: Text(CommonServices().formatWatt(watt)),
                    );
                  }).toList(),
                  onChanged: _selectedAppliance == null
                      ? null
                      : (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) return "Please select wattage";
                    return null;
                  },
                ),
                richTxt(text: "Select Switch Type"),
                GestureDetector(
                  onTap: () => _showApplianceBottomSheet(),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: TextEditingController(
                        text: _selectedAppliance?.name ?? "",
                      ),
                      validator: (_) {
                        if (_selectedAppliance == null) {
                          return "Please select an appliance";
                        }
                        return null;
                      },
                      hintText: "Select Appliance",
                      suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _fanRequired,
                      onChanged: (val) {
                        setState(() {
                          _fanRequired = val ?? true;
                          if (!_fanRequired) {
                            _selectedFanController.clear();
                          }
                          if (_fanRequired &&
                              _switchTypeControllers.length > 4) {
                            _switchTypeControllers.removeLast();
                          }
                        });
                      },
                    ),
                    const Text("Fan Required"),
                  ],
                ),
                if (_fanRequired) ...[
                  richTxt(
                    text: "Fan",
                  ),
                  CustomTextField(
                    controller: _selectedFanController,
                    validator: (value) {
                      if (value!.isEmpty) return "Selected fan cannot be empty";
                      return null;
                    },
                    hintText: "Selected Fan",
                  ),
                ],
                richTxt(
                  text: "Switch Types",
                ),
                const SizedBox(height: 8),
                Column(
                  children: List.generate(
                    // ✅ limit length based on fan requirement
                    _switchTypeControllers.length.clamp(
                      0,
                      _fanRequired ? 4 : 5,
                    ),
                    (index) {
                      final switchMap = _switchTypeControllers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: switchMap['type']!,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Switch type cannot be empty";
                                  }
                                  return null;
                                },
                                hintText: "Switch Type ${index + 1}",
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              child: CustomTextField(
                                controller: switchMap['order']!,
                                hintText: "Order",
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                validator: (value) =>
                                    validateOrder(value, index),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _switchTypeControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_switchTypeControllers.length < (_fanRequired ? 4 : 5))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Switch Type"),
                      onPressed: () {
                        setState(() {
                          final nextOrder = getNextAvailableOrder();

                          _switchTypeControllers.add({
                            'type': TextEditingController(),
                            'order': TextEditingController(
                              text: nextOrder.toString(),
                            ),
                          });

                          // Sort the text fields based on order
                          _switchTypeControllers.sort((a, b) {
                            final orderA = int.tryParse(a['order']!.text) ?? 0;
                            final orderB = int.tryParse(b['order']!.text) ?? 0;

                            return orderA.compareTo(orderB);
                          });
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).appColors.background,
        child: loading
            ? Align(
                // alignment: AlignmentDirectional(1, 0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                  child: InkWell(
                    splashColor: Theme.of(context).appColors.textSecondary,
                    // onTap: onPressed,
                    child: Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).appColors.textSecondary,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 1,
                            color: Theme.of(context).appColors.textSecondary,
                            offset: const Offset(0, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).appColors.textSecondary,
                          width: 1,
                        ),
                      ),
                      alignment: const AlignmentDirectional(0, 0),
                      child: CircularProgressIndicator(
                          color: Theme.of(context).appColors.buttonBackground),
                    ),
                  ),
                ),
              )
            : CustomButton(
                width: 200,
                text: "Submit",
                onPressed: () async {
                  debugPrint(_selectedAppliance?.code);
                  if (formKey.currentState!.validate()) {
                    SwitchDetails switchDetails1 = SwitchDetails(
                        privatePin: _privatePin.text,
                        switchId: widget.switchDetails.switchId,
                        switchSSID: _ssid.text,
                        switchPassKey: _passKey.text,
                        switchPassword: _password.text,
                        iPAddress: widget.switchDetails.iPAddress,
                        switchType: _selectedAppliance?.code,
                        switchTypes: _switchTypeControllers
                            .map((switchMap) => {
                                  'name': switchMap['type']!.text,
                                  'order':
                                      int.tryParse(switchMap['order']!.text) ??
                                          0
                                })
                            .toList(),
                        selectedFan: _selectedFanController.text,
                        isAutoLock: widget.switchDetails.isAutoLock,
                        wattage: selectedValue ?? widget.switchDetails.wattage);

                    try {
                      setState(() {
                        loading = true;
                      });
                      await ApiConnect.hitApiGet(
                        "${Constants.routerIP}/",
                      );
                      var data = {
                        "Lock_id": widget.switchDetails.switchId,
                        "lock_name": _ssid.text,
                        "lock_pass": _password.text
                      };
                      debugPrint("$data");
                      await ApiConnect.hitApiPost(
                          "${Constants.routerIP}/settings", data);

                      await ApiConnect.hitApiPost(
                          "${Constants.routerIP}/getSecretKey", {
                        "Lock_id": switchDetails1.switchId,
                        "lock_passkey": _passKey.text
                      });
                      _storageController.updateSwitch(
                          switchDetails1.switchId, switchDetails1);
                      Navigator.pushAndRemoveUntil<dynamic>(
                        navigatorKey.currentContext!,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const TabsPage(),
                        ),
                        (route) => false,
                      );
                    } on DioException {
                      await ApiConnect.hitApiGet(
                        "${Constants.routerIP}/",
                      );
                      await ApiConnect.hitApiPost(
                          "${Constants.routerIP}/getSecretKey", {
                        "Lock_id": switchDetails1.switchId,
                        "lock_passkey": _passKey.text
                      });
                      _storageController.updateSwitch(
                          switchDetails1.switchId, switchDetails1);
                      Navigator.pushAndRemoveUntil<dynamic>(
                        navigatorKey.currentContext!,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const TabsPage(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      debugPrint(e.toString());
                      showToast(navigatorKey.currentContext!,
                          "Failed to Update. Try again");
                      setState(() {
                        loading = false;
                      });
                    }
                  }
                },
              ),
      ),
    );
  }

  void _showApplianceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.grey.shade500,
                automaticallyImplyLeading: false,
                title: Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Text(
                      "Select Switch Type",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView.separated(
                      separatorBuilder: (_, index) {
                        return const SizedBox(height: 10);
                      },
                      padding: const EdgeInsets.all(16),
                      itemCount: _appliances.length,
                      itemBuilder: (_, index) {
                        final appliance = _appliances[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              width: 2,
                              color: _selectedAppliance?.id == appliance.id
                                  ? Theme.of(context).appColors.buttonBackground
                                  : Theme.of(context)
                                      .appColors
                                      .grey
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          leading: Image.asset(
                            Constants().applianceIconAsset(appliance.code),
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                          ),
                          titleTextStyle:
                              Theme.of(context).textTheme.titleMedium,
                          subtitleTextStyle:
                              Theme.of(context).textTheme.titleSmall,
                          title: Text(appliance.name),
                          subtitle: Text(appliance.category),
                          trailing: _selectedAppliance?.id == appliance.id
                              ? const Icon(Icons.check_circle_rounded,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedAppliance = appliance;
                              selectedValue = null; // reset watt
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
