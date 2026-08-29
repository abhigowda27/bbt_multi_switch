import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/group_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/router_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/custom_button.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/text_field.dart';
import 'package:flutter/material.dart';

class NewGroupInstallationPage extends StatefulWidget {
  const NewGroupInstallationPage({super.key});

  @override
  State<NewGroupInstallationPage> createState() =>
      _NewGroupInstallationPageState();
}

class _NewGroupInstallationPageState extends State<NewGroupInstallationPage> {
  final StorageController _storage = StorageController();
  final TextEditingController _groupName = TextEditingController();
  bool loading = false;
  List<RouterDetails> selectedSwitches = [];
  List<RouterDetails> availableSwitches = [];
  String? selectedRouter;
  List<RouterDetails> availableRouters = [];

  // Key: SwitchID, Value: Set of selected switch type names
  Map<String, Set<String>> selectedSwitchTypeNames = {};
  Map<String, String?> selectedFans = {};
  // Key: SwitchID, Value: Map of (TypeName -> Controller)
  Map<String, Map<String, TextEditingController>> _switchOrderControllers = {};
  List<int> applianceWattMap = [1000, 3000, 5000, 7500, 10000];
  int? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchAvailableRouters();
  }

  void fetchAvailableSwitches(String routerName) async {
    try {
      List<RouterDetails> allSwitches = await _storage.readRouters();
      List<RouterDetails> filteredSwitches = allSwitches
          .where((switchItem) => (switchItem.routerName.contains(routerName) ||
              routerName.contains(switchItem.routerName)))
          .toList();

      setState(() {
        availableSwitches = filteredSwitches;
      });
    } catch (e) {
      showToast(navigatorKey.currentContext!, "Error fetching switches");
    }
  }

  void fetchAvailableRouters() async {
    try {
      List<RouterDetails> routers = await _storage.readRouters();
      Set<String> seenNames = {};
      List<RouterDetails> uniqueRouters = [];

      for (var router in routers) {
        if (!seenNames.contains(router.routerName)) {
          seenNames.add(router.routerName);
          uniqueRouters.add(router);
        }
      }
      setState(() {
        availableRouters = uniqueRouters;
      });
    } catch (e) {
      showToast(navigatorKey.currentContext!, "Error fetching routers");
    }
  }

  void handleRouterChange(String? selectedRouter) {
    setState(() {
      this.selectedRouter = selectedRouter;

      selectedSwitches.clear();
      selectedSwitchTypeNames.clear();
      selectedFans.clear();
      _switchOrderControllers.clear();

      if (selectedRouter != null) {
        fetchAvailableSwitches(selectedRouter);
      } else {
        availableSwitches = [];
      }
    });
  }

  Future<void> handleSubmit() async {
    if (_groupName.text.isEmpty) {
      showToast(navigatorKey.currentContext!, "Group name cannot be empty.");
      return;
    }
    if (selectedValue == null) {
      showToast(navigatorKey.currentContext!, "Please select maximum wattage");
      return;
    }
    String groupName = _groupName.text;
    bool groupExists = await _storage.groupExists(groupName);
    if (groupExists) {
      showToast(navigatorKey.currentContext!, "Group name already exists.");
      return;
    }
    try {
      setState(() {
        loading = true;
      });

      RouterDetails? selectedRouterDetails = availableRouters
          .firstWhere((router) => router.routerName == selectedRouter);

      List<RouterDetails> finalSelectedSwitches = [];

      for (var sw in selectedSwitches) {
        final switchID = sw.switchID;
        final selectedNames = selectedSwitchTypeNames[switchID] ?? {};
        final controllers = _switchOrderControllers[switchID] ?? {};

        List<Map<String, dynamic>> finalTypes = [];

        for (var typeMap in sw.switchTypes) {
          final typeName = typeMap['name'] as String;
          if (selectedNames.contains(typeName)) {
            finalTypes.add({
              'name': typeName,
              'order': int.tryParse(controllers[typeName]?.text ?? '0') ??
                  typeMap['order'],
            });
          }
        }

        final groupSwitch = RouterDetails.fromJson(sw.toJson());
        groupSwitch.switchTypes = finalTypes;
        finalSelectedSwitches.add(groupSwitch);
      }

      GroupDetails groupDetails = GroupDetails(
          groupName: groupName,
          selectedRouter: selectedRouterDetails.routerName,
          routerPassword: selectedRouterDetails.routerPassword,
          selectedSwitches: finalSelectedSwitches,
          maximumWattage: selectedValue ?? 0);

      await _storage.saveGroupDetails(groupDetails);

      setState(() {
        loading = false;
      });

      Navigator.pushAndRemoveUntil<dynamic>(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => const TabsPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      showToast(navigatorKey.currentContext!, "Unable to connect. Try Again.");
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Group"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: width * 0.04,
            children: [
              CustomTextField(
                controller: _groupName,
                hintText: "New Group Name",
              ),
              DropdownMenuFormField<int>(
                width: double.infinity,
                inputDecorationTheme: InputDecorationThemeData(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                  contentPadding: const EdgeInsets.all(10),
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                ),
                textStyle: Theme.of(context).textTheme.titleSmall,
                alignmentOffset: const Offset(0, 5),
                menuStyle: MenuStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                hintText: "Select Wattage",
                dropdownMenuEntries: applianceWattMap.map((watt) {
                  return DropdownMenuEntry<int>(
                    value: watt,
                    label: CommonServices().formatWatt(watt),
                  );
                }).toList(),
                onSelected: (value) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    selectedValue = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select wattage";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                  hintText: "Select Router",
                  contentPadding: const EdgeInsets.all(10),
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                ),
                initialValue: selectedRouter,
                onChanged: handleRouterChange,
                items: availableRouters
                    .map((routerItem) => DropdownMenuItem(
                          value: routerItem.routerName,
                          child: Text(routerItem.routerName),
                        ))
                    .toList(),
              ),
              Text("Selected Router:",
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold)),
              if (selectedRouter != null)
                ListTile(
                  title: Text(selectedRouter!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline_outlined,
                        color: Theme.of(context).appColors.textSecondary),
                    onPressed: () {
                      setState(() {
                        selectedRouter = null;
                        availableSwitches = [];
                        selectedSwitches = [];
                        selectedFans.clear();
                        selectedSwitchTypeNames.clear();
                      });
                    },
                  ),
                ),
              DropdownButtonFormField<RouterDetails>(
                key: ValueKey(availableSwitches),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  hintText: "Select Switches",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                ),
                initialValue: null,
                onChanged: (selectedSwitch) {
                  setState(() {
                    if (selectedSwitch != null &&
                        !selectedSwitches.any(
                            (s) => s.switchID == selectedSwitch.switchID)) {
                      final clonedSwitch =
                          RouterDetails.fromJson(selectedSwitch.toJson());
                      selectedSwitches.add(clonedSwitch);

                      final switchID = clonedSwitch.switchID;

                      // Pre-select all switch types for this switch
                      Set<String> initialNames = {};
                      _switchOrderControllers[switchID] = {};
                      for (var typeMap in clonedSwitch.switchTypes) {
                        final typeName = typeMap['name'] as String;
                        initialNames.add(typeName);
                        _switchOrderControllers[switchID]![typeName] =
                            TextEditingController(
                                text: typeMap['order'].toString());
                      }
                      selectedSwitchTypeNames[switchID] = initialNames;

                      if (clonedSwitch.selectedFan?.isNotEmpty == true) {
                        selectedFans[switchID] = clonedSwitch.selectedFan!;
                      }
                    }
                  });
                },
                items: availableSwitches
                    .map((switchItem) => DropdownMenuItem(
                          value: switchItem,
                          child: Text(
                              "${switchItem.routerName}_${switchItem.switchName}"),
                        ))
                    .toList(),
              ),
              Text("Selected Switches:",
                  style: TextStyle(
                      fontSize: width * 0.04, fontWeight: FontWeight.bold)),
              ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: selectedSwitches.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final switchItem = selectedSwitches[index];
                  final switchTypes = switchItem.switchTypes;
                  final selectedNames =
                      selectedSwitchTypeNames[switchItem.switchID] ?? {};

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).appColors.primary,
                          Theme.of(context)
                              .appColors
                              .buttonBackground
                              .withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .appColors
                              .textPrimary
                              .withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              switchItem.switchName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .appColors
                                          .background),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Theme.of(context)
                                      .appColors
                                      .textSecondary),
                              onPressed: () {
                                setState(() {
                                  final switchID = switchItem.switchID;
                                  selectedSwitches.removeAt(index);
                                  selectedSwitchTypeNames.remove(switchID);
                                  selectedFans.remove(switchID);
                                  _switchOrderControllers.remove(switchID);
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        if (switchItem.selectedFan?.isNotEmpty == true ||
                            (selectedFans[switchItem.switchID]?.isNotEmpty ??
                                false))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select Fan",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .appColors
                                            .background),
                              ),
                              CheckboxListTile(
                                title: Text(
                                  selectedFans[switchItem.switchID] ??
                                      switchItem.selectedFan ??
                                      '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .appColors
                                              .background),
                                ),
                                value:
                                    switchItem.selectedFan?.isNotEmpty ?? false,
                                dense: true,
                                onChanged: (checked) {
                                  setState(() {
                                    final fanName =
                                        selectedFans[switchItem.switchID] ??
                                            switchItem.selectedFan ??
                                            '';
                                    if (checked == true) {
                                      switchItem.selectedFan = fanName;
                                      selectedFans[switchItem.switchID] =
                                          fanName;
                                    } else {
                                      switchItem.selectedFan = '';
                                      selectedFans[switchItem.switchID] =
                                          fanName;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        if (switchTypes.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Select Switches:",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .appColors
                                            .background),
                              ),
                              ...switchTypes.map((typeMap) {
                                final typeName = typeMap['name'] as String;
                                final isSelected =
                                    selectedNames.contains(typeName);
                                return Row(
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: Text(
                                          typeName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .appColors
                                                      .background),
                                        ),
                                        value: isSelected,
                                        dense: true,
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedSwitchTypeNames[
                                                      switchItem.switchID]!
                                                  .add(typeName);
                                            } else {
                                              selectedSwitchTypeNames[
                                                      switchItem.switchID]!
                                                  .remove(typeName);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).appColors.background,
        child: loading
            ? CircularProgressIndicator(
                color: Theme.of(context).appColors.buttonBackground)
            : CustomButton(
                text: "Submit",
                onPressed: handleSubmit,
              ),
      ),
    );
  }
}
