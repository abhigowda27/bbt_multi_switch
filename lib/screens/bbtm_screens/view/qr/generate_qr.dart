// import 'dart:convert';
//
// import 'package:bbt_multi_switch/screens/bbtm_screens/view/qr/qr.dart';
// import 'package:bbt_multi_switch/theme/app_colors_extension.dart';
// import 'package:flutter/material.dart';
//
// import '../../controllers/storage.dart';
// import '../../models/contacts.dart';
// import '../../models/group_model.dart';
// import '../../models/router_model.dart';
// import '../../models/switch_model.dart';
// import '../../widgets/custom/toast.dart';
//
// enum GenerateType { switches, routers, groups }
//
// class GenerateQRPage extends StatefulWidget {
//   const GenerateQRPage({super.key});
//
//   @override
//   State<GenerateQRPage> createState() => _GenerateQRPageState();
// }
//
// class _GenerateQRPageState extends State<GenerateQRPage> {
//   final StorageController _storageController = StorageController();
//
//   late Future<
//       (
//         List<ContactsModel>,
//         List<SwitchDetails>,
//         List<RouterDetails>,
//         List<GroupDetails>
//       )> _dataFuture;
//
//   List<ContactsModel> contacts = [];
//   List<SwitchDetails> switches = [];
//   List<RouterDetails> routers = [];
//   List<GroupDetails> groups = [];
//
//   GenerateType generateType = GenerateType.switches;
//
//   SwitchDetails selectedSwitch = SwitchDetails(
//     switchId: "default",
//     switchSSID: "def",
//     privatePin: "1234",
//     switchPassword: "default",
//     iPAddress: "0.0.0.0",
//     switchTypes: [],
//     selectedFan: "",
//   );
//
//   RouterDetails selectedRouter = RouterDetails(
//     switchID: "default",
//     routerName: "default",
//     routerPassword: "default",
//     switchPasskey: "default",
//     switchName: "default",
//     switchTypes: [],
//     iPAddress: '',
//     selectedFan: '',
//     deviceMacId: '',
//   );
//
//   GroupDetails selectedGroup = GroupDetails(
//     groupName: 'default',
//     selectedRouter: 'default',
//     selectedSwitches: [],
//     routerPassword: '',
//   );
//
//   ContactsModel selectedContact = ContactsModel(
//     accessType: "default",
//     endDateTime: DateTime.now(),
//     startDateTime: DateTime.now(),
//     name: "default",
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _dataFuture = _getData();
//   }
//
//   Future<
//       (
//         List<ContactsModel>,
//         List<SwitchDetails>,
//         List<RouterDetails>,
//         List<GroupDetails>
//       )> _getData() async {
//     final contacts = await _storageController.readContacts();
//     final switches = await _storageController.readSwitches();
//     final routers = await _storageController.readRouters();
//     final groups = await _storageController.readAllGroups();
//     return (contacts, switches, routers, groups);
//   }
//
//   Widget _buildDropdown<T>({
//     required String label,
//     required List<T> items,
//     required String Function(T) getLabel,
//     required void Function(T) onSelected,
//   }) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(label),
//         DropdownMenu(
//           onSelected: (value) => onSelected(value as T),
//           dropdownMenuEntries: items
//               .map((e) => DropdownMenuEntry(value: e, label: getLabel(e)))
//               .toList(),
//         ),
//       ],
//     );
//   }
//
//   bool _validateSelection() {
//     if (generateType == GenerateType.switches &&
//         selectedSwitch.switchId == "default") {
//       showToast(context, "No switch is selected");
//       return false;
//     }
//     if (generateType == GenerateType.routers &&
//         selectedRouter.switchName == "default") {
//       showToast(context, "No router is selected");
//       return false;
//     }
//     if (generateType == GenerateType.groups &&
//         selectedGroup.groupName == "default") {
//       showToast(context, "No group is selected");
//       return false;
//     }
//     if (selectedContact.accessType == "default") {
//       showToast(context, "No contact is selected");
//       return false;
//     }
//     return true;
//   }
//
//
//   String _generateQRName() {
//     switch (generateType) {
//       case GenerateType.switches:
//         return selectedSwitch.switchSSID;
//       case GenerateType.routers:
//         return "${selectedRouter.routerName}_${selectedRouter.switchName}";
//       case GenerateType.groups:
//         return selectedGroup.groupName;
//     }
//   }
//
//   void _onGenerate() {
//     if (!_validateSelection()) return;
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QRPage(
//           data: _generateQRData(),
//           name: _generateQRName(),
//         ),
//       ),
//     );
//   }
//
//   List<String> selectedSwitchTypes = [];
//   List<String> selectedRouterTypes = [];
//   List<RouterDetails> selectedGroupTypes = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Generate QR")),
//       body: FutureBuilder(
//         future: _dataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                   color: Theme.of(context).appColors.buttonBackground),
//             );
//           }
//           if (!snapshot.hasData) return const Text("No data found");
//
//           final data = snapshot.data!;
//           contacts = data.$1;
//           switches = data.$2;
//           routers = data.$3;
//           groups = data.$4;
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 DropdownMenu<GenerateType>(
//                   initialSelection: generateType,
//                   onSelected: (value) {
//                     if (value != null) {
//                       setState(() {
//                         generateType = value;
//                         selectedContact = ContactsModel(
//                           accessType: "default",
//                           endDateTime: DateTime.now(),
//                           startDateTime: DateTime.now(),
//                           name: "default",
//                         );
//                       });
//                     }
//                   },
//                   dropdownMenuEntries: const [
//                     DropdownMenuEntry(
//                         value: GenerateType.switches, label: "Switches"),
//                     DropdownMenuEntry(
//                         value: GenerateType.routers, label: "Routers"),
//                     DropdownMenuEntry(
//                         value: GenerateType.groups, label: "Groups"),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 if (generateType == GenerateType.switches)
//                   _buildDropdown<SwitchDetails>(
//                     label: "Select Switch",
//                     items: switches,
//                     getLabel: (e) => e.switchSSID,
//                     onSelected: (value) async {
//                       selectedSwitch = await _storageController
//                           .getSwitchBySSID(value.switchSSID);
//                       setState(() {
//                         selectedSwitchTypes.clear();
//                         // Assuming switchTypes is List<String>, else map accordingly
//                         selectedSwitchTypes.addAll(selectedSwitch.switchTypes);
//                       });
//                     },
//                   ),
//                 if (generateType == GenerateType.routers)
//                   _buildDropdown<RouterDetails>(
//                     label: "Select Router",
//                     items: routers,
//                     getLabel: (e) => "${e.routerName}_${e.switchName}",
//                     onSelected: (value) async {
//                       selectedRouter = await _storageController.getRouterByName(
//                           "${value.routerName}_${value.switchName}");
//                       setState(() {
//                         selectedRouterTypes.clear();
//                         // Assuming switchTypes is List<String>, else map accordingly
//                         selectedRouterTypes.addAll(selectedRouter.switchTypes);
//                       });
//                     },
//                   ),
//                 if (generateType == GenerateType.groups)
//                   _buildDropdown<GroupDetails>(
//                     label: "Select Group",
//                     items: groups,
//                     getLabel: (e) => e.groupName,
//                     onSelected: (value) async {
//                       selectedGroup = await _storageController
//                           .getGroupByName(value.groupName);
//                     },
//                   ),
//                 if (generateType == GenerateType.switches &&
//                     selectedSwitch.switchId != "default") ...[
//                   const SizedBox(height: 10),
//                   const Text("Select Switch Types"),
//                   Column(
//                     children: selectedSwitch.switchTypes.map((type) {
//                       final isSelected = selectedSwitchTypes.contains(type);
//                       return CheckboxListTile(
//                         title: Text(type),
//                         value: isSelected,
//                         onChanged: (checked) {
//                           setState(() {
//                             if (checked == true) {
//                               selectedSwitchTypes.add(type);
//                             } else {
//                               selectedSwitchTypes.remove(type);
//                             }
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ],
//                 if (generateType == GenerateType.routers &&
//                     selectedRouter.switchID != "default") ...[
//                   const SizedBox(height: 10),
//                   const Text("Select Switches"),
//                   Column(
//                     children: selectedRouter.switchTypes.map((type) {
//                       final isSelected = selectedRouterTypes.contains(type);
//                       return CheckboxListTile(
//                         title: Text(type),
//                         value: isSelected,
//                         onChanged: (checked) {
//                           setState(() {
//                             if (checked == true) {
//                               selectedRouterTypes.add(type);
//                             } else {
//                               selectedRouterTypes.remove(type);
//                             }
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ],
//                 const SizedBox(height: 16),
//                 _buildDropdown<ContactsModel>(
//                   label: "Select Contact",
//                   items: contacts,
//                   getLabel: (e) => e.name,
//                   onSelected: (value) async {
//                     selectedContact =
//                         await _storageController.getContactByPhone(value.name);
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _onGenerate,
//                       child: Text("Generate",
//                           style: TextStyle(
//                               color: Theme.of(context).appColors.background)),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: Text("Cancel",
//                           style: TextStyle(
//                               color: Theme.of(context).appColors.background)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:bbtml_new/screens/bbtm_screens/view/qr/qr.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../controllers/storage.dart';
import '../../models/contacts.dart';
import '../../models/group_model.dart';
import '../../models/router_model.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/toast.dart';

enum GenerateType { switches, routers, groups }

class GenerateQRPage extends StatefulWidget {
  const GenerateQRPage({super.key});

  @override
  State<GenerateQRPage> createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  final StorageController _storageController = StorageController();
  List<ContactsModel> contacts = [];
  List<SwitchDetails> switches = [];
  List<RouterDetails> routers = [];
  List<GroupDetails> groups = [];

  Future<
      (
        List<ContactsModel>,
        List<SwitchDetails>,
        List<RouterDetails>,
        List<GroupDetails>
      )> getData() async {
    contacts = await _storageController.readContacts();
    switches = await _storageController.readSwitches();
    routers = await _storageController.readRouters();
    groups = await _storageController.readAllGroups();
    return (contacts, switches, routers, groups);
  }

  GenerateType generateType = GenerateType.switches;

  SwitchDetails switchh = SwitchDetails(
      switchId: "default",
      switchSSID: "def",
      privatePin: "1234",
      switchPassword: "default",
      iPAddress: "0.0.0.0",
      switchTypes: [],
      selectedFan: "",
      wattage: 0);

  RouterDetails router = RouterDetails(
      switchID: "default",
      routerName: "default",
      routerPassword: "default",
      switchPasskey: "default",
      switchName: "default",
      switchTypes: [],
      iPAddress: '',
      selectedFan: '',
      deviceMacId: '',
      wattage: 0);

  GroupDetails group = GroupDetails(
      groupName: 'default',
      selectedRouter: 'default',
      selectedSwitches: [],
      routerPassword: '',
      maximumWattage: 00);

  ContactsModel contact = ContactsModel(
    accessType: "default",
    endDateTime: DateTime.now(),
    startDateTime: DateTime.now(),
    name: "default",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generate QR")),
      body: Center(
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                  color: Theme.of(context).appColors.buttonBackground);
            }
            debugPrint("${snapshot.data.runtimeType}");
            var x = snapshot.data as (
              List<ContactsModel>,
              List<SwitchDetails>,
              List<RouterDetails>,
              List<GroupDetails>,
            );
            contacts = x.$1;
            switches = x.$2;
            routers = x.$3;
            groups = x.$4;
            return Column(
              children: [
                const SizedBox(height: 30),
                DropdownMenu(
                    initialSelection: generateType,
                    onSelected: (value) async {
                      setState(() {
                        debugPrint("$value");
                        generateType = value!;
                        contact = ContactsModel(
                          accessType: "default",
                          endDateTime: DateTime.now(),
                          startDateTime: DateTime.now(),
                          name: "default",
                        );
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(
                          value: GenerateType.switches, label: "Switches"),
                      DropdownMenuEntry(
                          value: GenerateType.routers, label: "Routers"),
                      DropdownMenuEntry(
                          value: GenerateType.groups, label: "Groups"),
                    ]),
                const SizedBox(height: 10),
                if (generateType == GenerateType.switches)
                  const Text("Select Switch"),
                if (generateType == GenerateType.routers)
                  const Text("Select Router"),
                if (generateType == GenerateType.groups)
                  const Text("Select Group"),
                if (generateType == GenerateType.switches)
                  DropdownMenu(
                    onSelected: (value) async {
                      switchh =
                          (await _storageController.getSwitchBySSID(value))!;
                    },
                    dropdownMenuEntries: switches
                        .map((e) => DropdownMenuEntry(
                            value: e.switchSSID, label: e.switchSSID))
                        .toList(),
                  ),
                if (generateType == GenerateType.routers)
                  DropdownMenu(
                    onSelected: (value) async {
                      router =
                          (await _storageController.getRouterByName(value))!;
                    },
                    dropdownMenuEntries: routers
                        .map((e) => DropdownMenuEntry(
                            value: "${e.routerName}_${e.switchName}",
                            label: "${e.routerName}_${e.switchName}"))
                        .toList(),
                  ),
                if (generateType == GenerateType.groups)
                  DropdownMenu(
                    onSelected: (value) async {
                      group = (await _storageController.getGroupByName(value))!;
                    },
                    dropdownMenuEntries: groups
                        .map((e) => DropdownMenuEntry(
                            value: e.groupName, label: e.groupName))
                        .toList(),
                  ),
                const SizedBox(height: 10),
                const Text("Select Contact"),
                contacts.isEmpty
                    ? GestureDetector(
                        onTap: () {
                          showFlutterToast(
                              "No contacts yet! Add users from the Home page.");
                        },
                        child: const AbsorbPointer(
                          child: DropdownMenu(
                            dropdownMenuEntries: [],
                          ),
                        ),
                      )
                    : DropdownMenu(
                        onSelected: (value) async {
                          contact = (await _storageController
                              .getContactByPhone(value ?? ""))!;
                        },
                        dropdownMenuEntries: contacts
                            .map((e) =>
                                DropdownMenuEntry(value: e.name, label: e.name))
                            .toList(),
                      ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (generateType == GenerateType.switches &&
                            switchh.switchId.contains("default")) {
                          showToast(context, "No switch is selected");
                          return;
                        }

                        if (generateType == GenerateType.routers &&
                            router.switchName.contains("default")) {
                          showToast(context, "No router is selected");
                          return;
                        }
                        if (generateType == GenerateType.groups &&
                            group.groupName.contains("default")) {
                          showToast(context, "No group is selected");
                          return;
                        }
                        if (contact.accessType.contains("default")) {
                          showToast(context, "No contact is selected");
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRPage(
                              // data: generateType == GenerateType.switches
                              //     ? "${switchh.toSwitchQR()},${contact.toContactsQR()}"
                              //     : generateType == GenerateType.routers
                              //         ? "${router.toRouterQR()},${contact.toContactsQR()}"
                              //         : "${group.toGroupQR()},${contact.toContactsQR()}",
                              data: _generateQRData(),
                              name: generateType == GenerateType.switches
                                  ? switchh.switchSSID
                                  : generateType == GenerateType.routers
                                      ? "${router.routerName}_${router.switchName}"
                                      : group.groupName,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Generate",
                        style: TextStyle(
                            color: Theme.of(context).appColors.background),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Theme.of(context).appColors.background),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _generateQRData() {
    switch (generateType) {
      case GenerateType.switches:
        return jsonEncode({
          "data": {
            "switch": switchh.toJson(),
            "contact": contact.toJson(),
          }
        });

      case GenerateType.routers:
        return jsonEncode({
          "data": {
            "router": router.toJson(),
            "contact": contact.toJson(),
          }
        });

      case GenerateType.groups:
        return jsonEncode({
          "data": {
            "group": group.toJson(),
            "contact": contact.toJson(),
          }
        });
    }
  }
}
