import 'dart:async';
import 'dart:convert';

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/finger_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/contacts.dart';
import '../models/group_model.dart';
import '../models/mac_model.dart';
import '../models/router_model.dart';
import '../models/schedule_model.dart';
import '../models/switch_model.dart';

class StorageController {
  final FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      migrateOnAlgorithmChange: true,
    ),
  );

  // for Contacts
  void addContacts(ContactsModel contactsModel) async {
    List<ContactsModel> contactList = await readContacts();
    contactList.add(contactsModel);

    List listContentsInJson = contactList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "contacts", value: json.encode(listContentsInJson));
  }

  Future<void> deleteContacts() async {
    await storage.delete(key: "contacts");
  }

  Future<void> deleteOneContact(ContactsModel contactsModel) async {
    List<ContactsModel> contactList = await readContacts();
    contactList.removeWhere((element) => element.name == contactsModel.name);
    // for (var element in contactList) {
    //   if(element.name == contactsModel.name){}
    // }
    // contactList.(contactsModel);
    List listContectsInJson = contactList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "contacts", value: json.encode(listContectsInJson));
  }

  Future<ContactsModel?>? getContactByPhone(String phone) async {
    List<ContactsModel> switchesList = await readContacts();
    for (var element in switchesList) {
      if (element.name == phone) return element;
    }
    return null;
  }

  Future<List<ContactsModel>> readContacts() async {
    String? contacts = await storage.read(key: "contacts");
    List<ContactsModel> model = [];
    if (contacts == null) {
      List listContectsInJson = model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "contacts", value: json.encode(listContectsInJson));
    } else {
      model = [];
      var jsonContacts = json.decode(contacts);
      for (var element in jsonContacts) {
        model.add(ContactsModel.fromJson(element));
      }
    }
    return model;
  }

  // Switch

  Future<void> updateSwitch(
      String idOfSwitch, SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    List<RouterDetails> routersList = await readRouters();

    debugPrint("-------------");
    debugPrint(
        "Switches before update: ${switchesList.map((e) => e.toJson()).toList()}");
    debugPrint(
        "Routers before update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update switch details in the list
    for (var element in switchesList) {
      if (element.switchId == idOfSwitch) {
        element.switchId = switchDetails.switchId;
        element.switchPassword = switchDetails.switchPassword;
        element.switchSSID = switchDetails.switchSSID;
        element.privatePin = switchDetails.privatePin;
        element.switchPassKey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchType = switchDetails.switchType;
        element.switchTypes = switchDetails.switchTypes;
        element.wattage = switchDetails.wattage;
        break;
      }
    }

    debugPrint(
        "Switches after update: ${switchesList.map((e) => e.toJson()).toList()}");

    await deleteSwitches();
    await storage.write(
        key: "switches",
        value: json.encode(switchesList.map((e) => e.toJson()).toList()));

    // Update router details if the router is associated with the switch
    for (var element in routersList) {
      if (element.switchID == idOfSwitch) {
        element.switchID = switchDetails.switchId;
        element.switchName = switchDetails.switchSSID;
        element.switchPasskey = switchDetails.switchPassKey!;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        element.switchType = switchDetails.switchType;
        element.wattage = switchDetails.wattage;

        // Keep the name, password, and ipAddress the same
        element.deviceMacId = element.deviceMacId;
        element.routerName = element.routerName;
        element.routerPassword = element.routerName;
        element.iPAddress = element.iPAddress;
        break;
      }
    }

    debugPrint(
        "Routers after update: ${routersList.map((e) => e.toJson()).toList()}");

    await deleteRouters();
    await storage.write(
        key: "routers",
        value: json.encode(routersList.map((e) => e.toJson()).toList()));
  }

  Future<void> updateSwitchIfIdExist(
      String idOfSwitch, String switchName, SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    List<RouterDetails> routersList = await readRouters();

    debugPrint("-------------");
    debugPrint(
        "Switches before update: ${switchesList.map((e) => e.toJson()).toList()}");
    debugPrint(
        "Routers before update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update switch details in the list
    for (var element in switchesList) {
      if (element.switchId == idOfSwitch ||
          element.switchSSID == switchDetails.switchSSID) {
        element.switchId = switchDetails.switchId;
        element.switchPassword = switchDetails.switchPassword;
        element.switchSSID = switchDetails.switchSSID;
        element.privatePin = switchDetails.privatePin;
        element.switchPassKey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        element.wattage = switchDetails.wattage;
        break;
      }
    }

    debugPrint(
        "Switches after update: ${switchesList.map((e) => e.toJson()).toList()}");

    await deleteSwitches();
    await storage.write(
        key: "switches",
        value: json.encode(switchesList.map((e) => e.toJson()).toList()));

    // Update router details if the router is associated with the switch
    for (var element in routersList) {
      if (element.switchID == idOfSwitch ||
          element.switchName == switchDetails.switchSSID) {
        element.switchID = switchDetails.switchId;
        element.switchName = switchDetails.switchSSID;
        element.switchPasskey = switchDetails.switchPassKey!;
        element.routerName = element.routerName;
        element.routerPassword = element.routerName;
        element.iPAddress = element.iPAddress;
        element.wattage = switchDetails.wattage;

        break;
      }
    }

    debugPrint(
        "Routers after update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update the storage for routers
    await deleteRouters();
    await storage.write(
        key: "routers",
        value: json.encode(routersList.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteSwitches() async {
    await storage.delete(key: "switches");
  }

  Future<List<SwitchDetails>> readSwitches() async {
    String? switches = await storage.read(key: "switches");
    List<SwitchDetails> model = [];

    if (switches == null) {
      // Write an empty list to storage if no switches exist
      await storage.write(key: "switches", value: json.encode([]));
    } else {
      try {
        // Decode the JSON string into a List of Maps (i.e., List<Map<String, dynamic>>)
        List<dynamic> jsonContacts = json.decode(switches);
        debugPrint(switches);

        // Iterate over the decoded list and convert each map to SwitchDetails
        for (var element in jsonContacts) {
          if (element is Map<String, dynamic>) {
            model.add(SwitchDetails.fromJson(element));
          }
        }
      } catch (e) {
        // Handle potential decoding errors
        debugPrint('Error decoding switches: $e');
      }
    }

    return model;
  }

  Future<List<SwitchDetails>> readSwitchesByType(String type) async {
    List<SwitchDetails> switches = await readSwitches();

    return switches.where((element) => element.switchType == type).toList();
  }

  Future<SwitchDetails?>? getSwitchBySSID(String? switchName) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var element in switchesList) {
      if (element.switchSSID == switchName) return element;
    }
    return null;
  }

  Future<void> deleteOneSwitch(SwitchDetails switchDetails) async {
    List<SwitchDetails> switchList = await readSwitches();
    switchList.removeWhere(
        (element) => element.switchSSID == switchDetails.switchSSID);
    List listContactsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    await deleteSwitches();
    storage.write(key: "switches", value: json.encode(listContactsInJson));
  }

  Future<void> deleteOneSwitchType({
    required SwitchDetails switchDetails,
    required String typeToRemove,
  }) async {
    // Read the list from storage
    List<SwitchDetails> switchList = await readSwitches();

    // Find the switch by SSID
    final index = switchList.indexWhere(
        (element) => element.switchSSID == switchDetails.switchSSID);

    if (index != -1) {
      // Remove the specific switch type
      switchList[index].switchTypes.remove(typeToRemove);

      // If no switchTypes left, remove the whole switch
      if (switchList[index].switchTypes.isEmpty) {
        switchList.removeAt(index);
      }

      // Save updated list back to storage
      final updatedJson =
          switchList.map((switchItem) => switchItem.toJson()).toList();
      await deleteSwitches();
      await storage.write(
        key: "switches",
        value: json.encode(updatedJson),
      );
    }
  }

  Future<bool> isSwitchNameExists(String switchName, String switchId) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var switchDetails in switchesList) {
      if (switchDetails.switchSSID == switchName ||
          switchDetails.switchId == switchId) {
        return true;
      }
    }
    return false;
  }

  Future<void> addSwitches(SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    switchesList.add(switchDetails);
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "switches", value: json.encode(listContectsInJson));
  }

  Future<void> mergeSwitches(List<SwitchDetails> importedSwitches) async {
    final existingSwitches = await readSwitches();

    final Map<String, SwitchDetails> switchMap = {
      for (var s in existingSwitches) s.switchId: s,
    };

    for (final sw in importedSwitches) {
      switchMap[sw.switchId] = sw; // Update if exists, add if not
    }

    await saveSwitches(switchMap.values.toList());
  }

  Future<void> saveSwitches(List<SwitchDetails> switchesList) async {
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    await storage.write(
        key: "switches", value: json.encode(listContectsInJson));
  }

  // ROUTERS

  Future<void> updateRouterIp(
    String switchId,
    String newIp,
  ) async {
    List<RouterDetails> routersList = await readRouters();

    final index = routersList.indexWhere(
      (element) => element.switchID == switchId,
    );

    if (index == -1) {
      debugPrint('Router with ID $switchId not found');
      return;
    }

    // Update only the IP
    routersList[index].iPAddress = newIp;

    await storage.write(
      key: "routers",
      value: json.encode(
        routersList.map((e) => e.toJson()).toList(),
      ),
    );

    debugPrint(
      'Router IP updated: $switchId → $newIp',
    );
  }

  Future<void> updateRouter(
    RouterDetails routerDetails,
  ) async {
    List<RouterDetails> routersList = await readRouters();
    routersList
        .removeWhere((element) => element.switchID == routerDetails.switchID);
    routersList.add(routerDetails);
    await storage.write(
      key: "routers",
      value: json.encode(routersList.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteRouters() async {
    await storage.delete(key: "routers");
  }

  Future<RouterDetails?>? getRouterByName(String? switchName) async {
    List<RouterDetails> routerList = await readRouters();
    for (var element in routerList) {
      if ("${element.routerName}_${element.switchName}" == switchName) {
        return element;
      }
    }
    return null;
  }

  Future<List<RouterDetails>> readRouters() async {
    String? switches = await storage.read(key: "routers");
    List<RouterDetails> model = [];
    if (switches == null) {
      List listContectsInJson = model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "routers", value: json.encode(listContectsInJson));
    } else {
      model = [];
      debugPrint("routers $switches");

      var jsonContacts = json.decode(switches);
      for (var element in jsonContacts) {
        model.add(RouterDetails.fromJson(element));
      }
    }
    return model;
  }

  Future<void> deleteOneRouter(String switchId) async {
    List<RouterDetails> switchList = await readRouters();

    switchList.removeWhere((element) => element.switchID == switchId);

    List listContectsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  Future<void> deleteOneSwitchTypeFromRouter({
    required String switchId,
    required String switchTypeToRemove,
  }) async {
    List<RouterDetails> routerList = await readRouters();

    // Find router by switchID
    final index =
        routerList.indexWhere((element) => element.switchID == switchId);

    if (index != -1) {
      // Remove the specific switchType
      routerList[index].switchTypes.remove(switchTypeToRemove);

      // If no switchTypes left, remove the whole router
      if (routerList[index].switchTypes.isEmpty) {
        routerList.removeAt(index);
      }

      // Save updated list back to storage
      List listRoutersInJson = routerList.map((e) => e.toJson()).toList();
      await storage.write(
          key: "routers", value: json.encode(listRoutersInJson));
    }
  }

  Future<String?> getRouterNameIfSwitchIDExists(String switchID) async {
    List<RouterDetails> routerList = await readRouters();
    for (var switchDetails in routerList) {
      if (switchDetails.switchID == switchID) {
        debugPrint("${switchDetails.switchID} SwitchDetails Switch ID");
        debugPrint("$switchID SwitchID");
        return switchDetails.routerName;
      }
    }
    return null;
  }

  void addRouters(RouterDetails switchDetails) async {
    List<RouterDetails> switchesList = await readRouters();
    switchesList.add(switchDetails);
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  Future<void> mergeRouters(List<RouterDetails> importedSwitches) async {
    final existingSwitches = await readRouters();

    final Map<String, RouterDetails> switchMap = {
      for (var s in existingSwitches) s.switchID: s,
    };

    for (final sw in importedSwitches) {
      switchMap[sw.switchID] = sw;
    }

    await saveRouters(switchMap.values.toList());
  }

  Future<void> saveRouters(List<RouterDetails> switchesList) async {
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    await storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  //Group
  static const _groupStateKey = 'isGroupSwitchOn';

  Future<bool> loadGroupSwitchState() async {
    String? value = await storage.read(key: _groupStateKey);
    return value != null && value.toLowerCase() == 'true';
  }

  Future<void> saveGroupSwitchState(bool value) async {
    await storage.write(key: _groupStateKey, value: value.toString());
  }

  Future<void> deleteGroups() async {
    await storage.delete(key: "groups");
  }

  Future<GroupDetails?>? getGroupByName(String? groupName) async {
    List<GroupDetails> groupList = await readAllGroups();
    for (var element in groupList) {
      if (element.groupName == groupName) return element;
    }
    return null;
  }

  Future<void> saveGroupDetails(GroupDetails groupDetails) async {
    List<GroupDetails> groups = await readAllGroups();
    groups.add(groupDetails);
    List listContectsInJson = groups.map((e) {
      return e.toJson();
    }).toList();
    await storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  Future<List<GroupDetails>> readAllGroups() async {
    String? groupsJson = await storage.read(key: 'groups');
    if (groupsJson == null) return [];
    List<dynamic> groupsList = jsonDecode(groupsJson);
    return groupsList.map((json) => GroupDetails.fromJson(json)).toList();
  }

  Future<bool> groupExists(String groupName) async {
    // Assuming you have a method to fetch all group details from storage
    List<GroupDetails> allGroups = await readAllGroups();

    // Check if any group has the same name as the provided groupName
    return allGroups.any((group) => group.groupName == groupName);
  }

  Future<void> updateGroupDetails(String groupName, String routerName,
      List<RouterDetails> selectedSwitches) async {
    // Assuming you have a method to fetch all group details from storage
    List<GroupDetails> allGroups = await readAllGroups();
    debugPrint("-------------");
    List listContectsInJson = allGroups.map((e) {
      return e.toJson();
    }).toList();
    debugPrint("$listContectsInJson");
    debugPrint("${allGroups.length}");
    for (var element in allGroups) {
      if (element.groupName == groupName) {
        element.groupName = groupName;
        element.selectedRouter = routerName;
        element.selectedSwitches = selectedSwitches;
        break;
      }
    }
    listContectsInJson = allGroups.map((e) {
      return e.toJson();
    }).toList();
    debugPrint("$listContectsInJson");
    await deleteGroups();
    storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  Future<void> deleteOneGroup(GroupDetails groupDetails) async {
    List<GroupDetails> groups = await readAllGroups();
    groups.removeWhere((group) => group.groupName == groupDetails.groupName);
    await storage.write(
      key: 'groups',
      value: jsonEncode(groups.map((group) => group.toJson()).toList()),
    );
  }

  Future<void> mergeGroups(List<GroupDetails> importedSwitches) async {
    final existingSwitches = await readAllGroups();

    final Map<String, GroupDetails> switchMap = {
      for (var s in existingSwitches) s.groupName: s,
    };

    for (final sw in importedSwitches) {
      switchMap[sw.groupName] = sw;
    }

    await saveGroups(switchMap.values.toList());
  }

  Future<void> saveGroups(List<GroupDetails> switchesList) async {
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    await storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  //MACS

  Future<void> deleteMacs() async {
    await storage.delete(key: "macs");
  }

  Future<List<MacsDetails>> readMacs() async {
    String? switches = await storage.read(key: "macs");
    List<MacsDetails> model = [];
    if (switches == null) {
      List listContectsInJson = model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "macs", value: json.encode(listContectsInJson));
    } else {
      model = [];
      var jsonContacts = json.decode(switches);
      for (var element in jsonContacts) {
        model.add(MacsDetails.fromJson(element));
      }
    }
    return model;
  }

  Future<void> deleteOneMacs(MacsDetails switchDetails) async {
    List<MacsDetails> switchList = await readMacs();
    switchList.removeWhere((element) =>
        element.id == switchDetails.id &&
        element.switchDetails.switchSSID ==
            switchDetails.switchDetails.switchSSID);
    List listContentsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "macs", value: json.encode(listContentsInJson));
  }

  Future<void> updateMacStatus(
      MacsDetails switchDetails, BuildContext context) async {
    await deleteOneMacs(switchDetails);
    addMacs(
      switchDetails,
    );
  }

  Future<bool> isMacIDExists(String macId, switchID) async {
    List<MacsDetails> macsList = await readMacs();
    for (var details in macsList) {
      if (details.id == macId && details.switchDetails.switchId == switchID) {
        return true;
      }
    }
    return false;
  }

  void addMacs(MacsDetails macDetails) async {
    bool exists =
        await isMacIDExists(macDetails.id, macDetails.switchDetails.switchId);
    if (exists) {
      final scaffold = ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      );
      scaffold.showSnackBar(
        const SnackBar(
          content: Text("MAC ID already Exist for this switch"),
        ),
      );
      return;
    }
    List<MacsDetails> switchesList = await readMacs();
    switchesList.add(macDetails);

    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "macs", value: json.encode(listContectsInJson));
  }

  Future<void> saveMacState(MacsDetails mac) async {
    await storage.write(
      key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}',
      value: mac.isPresentInESP.toString(),
    );
  }

  // Retrieve the state of a MAC card
  Future<bool> getMacState(MacsDetails mac) async {
    final state = await storage.read(
        key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}');
    return state == 'true';
  }

  // Delete a MAC card's state
  Future<void> deleteMacState(MacsDetails mac) async {
    await storage.delete(key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}');
  } //MACS

  //Finger prints (LOCKS)

  Future<void> deleteFingerPrints() async {
    await storage.delete(key: "fingerprint");
  }

  Future<List<FingerPrintDetails>> readFingerPrints() async {
    String? switches = await storage.read(key: "fingerprint");

    if (switches == null) {
      return [];
    }

    List<dynamic> jsonContacts = json.decode(switches);

    return jsonContacts.map((e) => FingerPrintDetails.fromJson(e)).toList();
  }

  Future<List<FingerPrintDetails>> readFingerPrintsBySwitch(
      String switchName) async {
    String? switches = await storage.read(key: "fingerprint");

    if (switches == null) {
      return [];
    }

    List<dynamic> jsonContacts = json.decode(switches);

    List<FingerPrintDetails> fingerprints =
        jsonContacts.map((e) => FingerPrintDetails.fromJson(e)).toList();

    return fingerprints
        .where((element) => element.switchName == switchName)
        .toList();
  }

  Future<void> deleteOneFingerPrint(String name, String switchName) async {
    List<FingerPrintDetails> switchList = await readFingerPrints();

    for (var element in switchList) {
      if (element.switchName == switchName) {
        element.names.remove(name);
      }
    }

    // Optional: remove switch entry if no fingerprints left
    switchList.removeWhere((element) => element.names.isEmpty);

    List listContentsInJson = switchList.map((e) => e.toJson()).toList();

    await storage.write(
      key: "fingerprint",
      value: json.encode(listContentsInJson),
    );
  }

  Future<void> addFingerPrint(String name, SwitchDetails switchDetails) async {
    List<FingerPrintDetails> switchesList = await readFingerPrints();

    int index = switchesList
        .indexWhere((e) => e.switchName == switchDetails.switchSSID);

    if (index != -1) {
      // Switch already exists
      if (switchesList[index].names.contains(name)) {
        final scaffold = ScaffoldMessenger.of(navigatorKey.currentContext!);
        scaffold.showSnackBar(
          const SnackBar(
            content:
                Text("Same name fingerprint already exists for this switch"),
          ),
        );
        return;
      }

      // Add name to existing list
      switchesList[index].names.add(name);
    } else {
      // Create new fingerprint entry
      final FingerPrintDetails fingerPrintDetails = FingerPrintDetails(
        names: [name],
        switchName: switchDetails.switchSSID,
      );

      switchesList.add(fingerPrintDetails);
    }

    List listContectsInJson = switchesList.map((e) => e.toJson()).toList();

    await storage.write(
      key: "fingerprint",
      value: json.encode(listContectsInJson),
    );
  }
  // QR PIN

  Future<String?> getQrPin() async {
    return await storage.read(key: 'qrPinKey');
  }

  Future<void> setQrPin(String pin) async {
    await storage.write(key: 'qrPinKey', value: pin);
  }

  // factory Reset
  Future<void> deleteEverythingWithRespectToSwitchID(
      SwitchDetails switchDetails) async {
    debugPrint("Deleting all routers");
    List<RouterDetails> routerList = await readRouters();
    routerList
        .removeWhere((element) => element.switchID == switchDetails.switchId);
    List routerListContectsInJson = routerList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(routerListContectsInJson));
    debugPrint("Deleted all routers");
    debugPrint("Deleting all switches");
    deleteOneSwitch(switchDetails);
    debugPrint("Deleted all switches");
  }

  // Schedule ON OFF

  Future<void> saveAlarm(String key, Schedule alarm) async {
    await storage.write(
      key: key,
      value: jsonEncode(alarm.toJson()),
    );
  }

  Future<Schedule?> loadAlarm(String key) async {
    final savedData = await storage.read(key: key);
    if (savedData != null) {
      return Schedule.fromJson(jsonDecode(savedData));
    }
    return null;
  }

  Future<void> deleteAlarm(String key) async {
    await storage.delete(key: key);
  }

  Future<void> updateSwitchAutoStatus(String switchName, bool status) async {
    List<SwitchDetails> switchesList = await readSwitches();
    debugPrint("${switchesList.length}");
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    for (var element in switchesList) {
      if (element.switchSSID == switchName) {
        element.isAutoLock = status;
        break;
      }
    }
    listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    debugPrint("$listContectsInJson");
    await deleteSwitches();
    storage.write(key: "switches", value: json.encode(listContectsInJson));
  }
}
