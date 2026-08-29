import 'dart:convert';

import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddGroupCloudPage extends StatefulWidget {
  const AddGroupCloudPage({super.key, required this.switchBloc});
  final SwitchBloc switchBloc;

  @override
  State<AddGroupCloudPage> createState() => _AddGroupCloudPageState();
}

class _AddGroupCloudPageState extends State<AddGroupCloudPage> {
  final TextEditingController _groupName = TextEditingController();
  final List<Map<String, dynamic>> _selectedSwitches = [];
  final TextEditingController _deviceController = TextEditingController();
  final SwitchBloc _addGroupBloc = SwitchBloc();

  bool _isSwitchSelected(String mainUid, String subUid) {
    return _selectedSwitches.any((m) =>
        m["main_uid"] == mainUid &&
        (m["selected_switches"] as List).any((si) => si["uid"] == subUid));
  }

  bool? _getDeviceSelectionState(String mainUid, List<dynamic> subSwitches) {
    if (subSwitches.isEmpty) return false;
    int mainIndex =
        _selectedSwitches.indexWhere((m) => m["main_uid"] == mainUid);
    if (mainIndex == -1) return false;
    final selected = _selectedSwitches[mainIndex]["selected_switches"] as List;
    if (selected.length == subSwitches.length) return true;
    if (selected.isNotEmpty) return null;
    return false;
  }

  bool _isAllSelected(String mainUid, List<dynamic> subSwitches) {
    if (subSwitches.isEmpty) return false;
    int mainIndex =
        _selectedSwitches.indexWhere((m) => m["main_uid"] == mainUid);
    if (mainIndex == -1) return false;
    final selected = _selectedSwitches[mainIndex]["selected_switches"] as List;
    return selected.length == subSwitches.length;
  }

  void _toggleDeviceSelection(String mainUid, String mainName,
      dynamic deviceType, List<dynamic> subSwitches, bool selectAll) {
    setState(() {
      int mainIndex =
          _selectedSwitches.indexWhere((m) => m["main_uid"] == mainUid);
      if (selectAll) {
        final List<Map<String, dynamic>> allSubs = subSwitches.map((s) {
          final item = Map<String, dynamic>.from(s as Map);
          return {
            "uid": (item["uid"] ?? item["id"] ?? "").toString(),
            "name": (item["device_name"] ?? "Switch").toString(),
            "device_type": item["device_type"] ?? 0,
          };
        }).toList();

        if (mainIndex == -1) {
          _selectedSwitches.add({
            "main_uid": mainUid,
            "main_name": mainName,
            "device_type": deviceType,
            "selected_switches": allSubs,
          });
        } else {
          _selectedSwitches[mainIndex]["selected_switches"] = allSubs;
          _selectedSwitches[mainIndex]["device_type"] = deviceType;
        }
      } else {
        if (mainIndex != -1) {
          _selectedSwitches.removeAt(mainIndex);
        }
      }
      _updateDeviceController();
    });
  }

  void _updateDeviceController() {
    int totalCount = 0;
    for (var m in _selectedSwitches) {
      totalCount += (m["selected_switches"] as List).length;
    }
    _deviceController.text =
        totalCount > 0 ? "$totalCount switches selected" : "";
  }

  void _showDeviceSelectionDialog(List<Map<String, dynamic>> deviceList) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Switches"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: deviceList.length,
                  itemBuilder: (context, index) {
                    final device = deviceList[index];
                    final String mainUid = device["uid"] ?? device["id"] ?? "";
                    final String mainName =
                        device["device_name"] ?? "Unknown Device";
                    final dynamic deviceType = device["device_type"] ?? 0;

                    if (deviceType != 3) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        color: Theme.of(context)
                            .appColors
                            .primary
                            .withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(mainName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .appColors
                                          .background)),
                          secondary: const Icon(Icons.device_hub_outlined),
                          value: _isSwitchSelected(mainUid, mainUid),
                          onChanged: (value) {
                            setDialogState(() {
                              _toggleDeviceSelection(
                                mainUid,
                                mainName,
                                deviceType,
                                [device],
                                value ?? false,
                              );
                            });

                            setState(() {
                              _updateDeviceController();
                            });
                          },
                        ),
                      );
                    }

                    // Assuming the sub-switches are in a key called 'switches' or 'list'
                    final List<dynamic> subSwitches =
                        device["switches"] ?? device["list"] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 1,
                      color: Theme.of(context)
                          .appColors
                          .primary
                          .withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        childrenPadding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: const Icon(
                          Icons.device_hub_outlined,
                        ),
                        title: Text(
                          mainName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: Theme.of(context).appColors.background,
                              ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              tristate: true,
                              value: _getDeviceSelectionState(
                                  mainUid, subSwitches),
                              onChanged: (value) {
                                // If current state is partial (null) or none (false), select all.
                                // If current state is all (true), deselect all.
                                final currentState = _getDeviceSelectionState(
                                    mainUid, subSwitches);
                                final bool selectAll = currentState != true;

                                setDialogState(() {
                                  _toggleDeviceSelection(
                                    mainUid,
                                    mainName,
                                    deviceType,
                                    subSwitches,
                                    selectAll,
                                  );
                                });

                                setState(() {
                                  _updateDeviceController();
                                });
                              },
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        subtitle: Text("${subSwitches.length} available",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .appColors
                                        .background)),
                        children: subSwitches.map((s) {
                          final switchItem =
                              Map<String, dynamic>.from(s as Map);
                          final String subUid =
                              (switchItem["uid"] ?? switchItem["id"] ?? "")
                                  .toString();
                          final String subName =
                              (switchItem["device_name"] ?? "Switch")
                                  .toString();

                          final bool isSelected =
                              _isSwitchSelected(mainUid, subUid);

                          return Card(
                            elevation: 0,
                            color: Colors.grey.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CheckboxListTile(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              secondary: const Icon(
                                Icons.toggle_on_outlined,
                                size: 20,
                              ),
                              title: Text(
                                subName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    int mainIndex =
                                        _selectedSwitches.indexWhere(
                                            (m) => m["main_uid"] == mainUid);
                                    if (mainIndex == -1) {
                                      _selectedSwitches.add({
                                        "main_uid": mainUid,
                                        "main_name": mainName,
                                        "device_type": deviceType,
                                        "selected_switches": [
                                          {
                                            "uid": subUid,
                                            "name": subName,
                                            "device_type":
                                                switchItem["device_type"] ?? 0,
                                          }
                                        ]
                                      });
                                    } else {
                                      (_selectedSwitches[mainIndex]
                                              ["selected_switches"] as List)
                                          .add({
                                        "uid": subUid,
                                        "name": subName,
                                        "device_type":
                                            switchItem["device_type"] ?? 0,
                                      });
                                      _selectedSwitches[mainIndex]
                                          ["device_type"] = deviceType;
                                    }
                                  } else {
                                    int mainIndex =
                                        _selectedSwitches.indexWhere(
                                            (m) => m["main_uid"] == mainUid);
                                    if (mainIndex != -1) {
                                      (_selectedSwitches[mainIndex]
                                              ["selected_switches"] as List)
                                          .removeWhere(
                                              (si) => si["uid"] == subUid);
                                      if ((_selectedSwitches[mainIndex]
                                              ["selected_switches"] as List)
                                          .isEmpty) {
                                        _selectedSwitches.removeAt(mainIndex);
                                      }
                                    }
                                  }
                                });
                                setState(() {
                                  _updateDeviceController();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitGroup() {
    if (_groupName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name")),
      );
      return;
    }
    if (_selectedSwitches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one switch")),
      );
      return;
    }

    // Flatten the selected switches to a list of UIDs
    final List<String> switchUids = _selectedSwitches
        .expand((device) => (device["selected_switches"] as List))
        .map((s) => s["uid"].toString())
        .toList();

    final payload = {
      "groupName": _groupName.text,
      "switches": switchUids,
    };

    debugPrint("Final Payload: ${jsonEncode(payload)}");

    _addGroupBloc.add(AddGroupEvent(payload: payload));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SwitchBloc, CommonState>(
      bloc: _addGroupBloc,
      listener: (context, state) {
        if (state.apiStatus is ApiResponse) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Group created successfully!")),
          );
          Navigator.pop(context, true);
        } else if (state.apiStatus is ApiFailureState) {
          final error = (state.apiStatus as ApiFailureState).exception;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to create group: $error")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Add Group")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              CustomTextField(
                controller: _groupName,
                hintText: "New Group Name",
              ),
              BlocBuilder<SwitchBloc, CommonState>(
                bloc: widget.switchBloc,
                builder: (context, state) {
                  ApiStatus apiResponse = state.apiStatus;
                  if (apiResponse is ApiResponse) {
                    final responseData = apiResponse.response;
                    debugPrint("Response data====>$responseData");
                    List<Map<String, dynamic>> deviceList0 = [];
                    if (responseData != null &&
                        responseData['data'] != null &&
                        responseData['data'] is List &&
                        responseData['data'].isNotEmpty) {
                      final listData = responseData?['data']?[0]?['list'] ?? [];
                      if (listData is List) {
                        deviceList0 = listData
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();
                      }
                    } else {
                      debugPrint("Unexpected response format: $responseData");
                    }
                    return deviceList0.isNotEmpty
                        ? deviceListWidget(deviceList0)
                        : const Center(
                            child: Text("No Switches Found in Cloud"));
                  } else if (apiResponse is ApiLoadingState ||
                      apiResponse is ApiInitialState) {
                    return const CircularProgressIndicator();
                  } else if (apiResponse is ApiFailureState) {
                    return const Center(
                        child: Text("No Switches Found in Cloud"));
                  } else {
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitGroup,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Submit Group"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget deviceListWidget(List<Map<String, dynamic>> deviceList) {
    return InkWell(
      onTap: () => _showDeviceSelectionDialog(deviceList),
      child: IgnorePointer(
        child: CustomTextField(
          controller: _deviceController,
          hintText: "Select Switches",
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
