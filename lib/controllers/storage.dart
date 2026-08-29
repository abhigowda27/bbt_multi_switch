// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// import '../models/switch_model.dart';
//
// class StorageController {
//   final FlutterSecureStorage storage = const FlutterSecureStorage();
//
//   // Switch
//
//   deleteSwitches() async {
//     await storage.delete(key: "switches");
//   }
//
//   Future<List<SwitchDetails>> readSwitches() async {
//     String? switches = await storage.read(key: "switches");
//     List<SwitchDetails> model = [];
//     if (switches == null) {
//       List listContectsInJson = model.map((e) {
//         return e.toJson();
//       }).toList();
//       storage.write(key: "switches", value: json.encode(listContectsInJson));
//     } else {
//       model = [];
//       var jsonContacts = json.decode(switches);
//       for (var element in jsonContacts) {
//         model.add(SwitchDetails.fromJson(element));
//       }
//     }
//     return model;
//   }
//
//   deleteOneSwitch(SwitchDetails switchDetails) async {
//     List<SwitchDetails> switchList = await readSwitches();
//     switchList.removeWhere(
//         (element) => element.switchName == switchDetails.switchName);
//     List listContectsInJson = switchList.map((e) {
//       return e.toJson();
//     }).toList();
//     await deleteSwitches();
//     storage.write(key: "switches", value: json.encode(listContectsInJson));
//   }
//
//   Future<void> updateSwitch(
//       String idOfSwitch, SwitchDetails switchDetails) async {
//     List<SwitchDetails> switchesList = await readSwitches();
//
//     // Update switch details in the list
//     for (var element in switchesList) {
//       if (element.switchId == idOfSwitch) {
//         element.switchId = switchDetails.switchId;
//         element.switchName = switchDetails.switchName;
//
//         break;
//       }
//     }
//
//     // Update the storage for switches
//     await deleteSwitches();
//     await storage.write(
//         key: "switches",
//         value: json.encode(switchesList.map((e) => e.toJson()).toList()));
//   }
//
//   Future<bool> isSwitchSSIDExists(String switchSSID, String switchId) async {
//     List<SwitchDetails> switchesList = await readSwitches();
//     for (var switchDetails in switchesList) {
//       if (switchDetails.switchName == switchSSID ||
//           switchDetails.switchId == switchId) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   Future<void> updateSwitchIfIdExist(
//       String idOfSwitch, String switchName, SwitchDetails switchDetails) async {
//     List<SwitchDetails> switchesList = await readSwitches();
//
//     // Update switch details in the list
//     for (var element in switchesList) {
//       if (element.switchId == idOfSwitch ||
//           element.switchName == switchDetails.switchName) {
//         element.switchId = switchDetails.switchId;
//         element.switchName = switchDetails.switchName;
//
//         break;
//       }
//     }
//
//     await deleteSwitches();
//     await storage.write(
//         key: "switches",
//         value: json.encode(switchesList.map((e) => e.toJson()).toList()));
//   }
//
//   void addSwitches(SwitchDetails switchDetails) async {
//     List<SwitchDetails> switchesList = await readSwitches();
//     switchesList.add(switchDetails);
//     List listContectsInJson = switchesList.map((e) {
//       return e.toJson();
//     }).toList();
//     storage.write(key: "switches", value: json.encode(listContectsInJson));
//   }
// }
