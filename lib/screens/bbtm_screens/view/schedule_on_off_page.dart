import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controllers/apis.dart';
import '../controllers/storage.dart';
import '../models/schedule_model.dart';
import '../widgets/custom/toast.dart';

class ScheduleOnOffPage extends StatefulWidget {
  final String switchName;
  final String ipAddress;
  const ScheduleOnOffPage(
      {super.key, required this.switchName, required this.ipAddress});

  @override
  State<ScheduleOnOffPage> createState() => _ScheduleOnOffPageState();
}

class _ScheduleOnOffPageState extends State<ScheduleOnOffPage> {
  final StorageController _storageController = StorageController();
  Schedule? alarm;

  @override
  void initState() {
    super.initState();
    loadAlarm();
  }

  Future<void> saveAlarm() async {
    if (alarm != null) {
      await _storageController.saveAlarm(widget.switchName, alarm!);
    }
  }

  Future<void> loadAlarm() async {
    final loadedAlarm = await _storageController.loadAlarm(widget.switchName);
    if (loadedAlarm != null) {
      setState(() {
        alarm = loadedAlarm;
      });
    }
  }

  void deleteAlarm() {
    setState(() {
      alarm = null;
    });
    _storageController.deleteAlarm(widget.switchName);
  }

  void updateAlarm(TimeOfDay newTime, {bool isOnTime = true}) {
    setState(() {
      if (isOnTime) {
        alarm?.onTime = newTime;
        makeApiCall(alarm!);
      } else {
        alarm?.offTime = newTime;
        makeApiCall(alarm!);
      }
    });
    saveAlarm();
  }

  void toggleAlarm(bool value) {
    setState(() {
      if (alarm != null) {
        alarm!.enabled = value;
        saveAlarm();
        makeApiCall(alarm!);
      }
    });
  }

  Future<void> makeApiCall(Schedule alarm) async {
    DateTime onTime =
        DateTime(2023, 1, 1, alarm.onTime.hour, alarm.onTime.minute);
    DateTime offTime =
        DateTime(2023, 1, 1, alarm.offTime.hour, alarm.offTime.minute);

    // Format the time as HH:mm:ss
    String formattedOnTime = DateFormat('HH:mm:ss').format(onTime);
    String formattedOffTime = DateFormat('HH:mm:ss').format(offTime);

    debugPrint('Formatted On Time: $formattedOnTime');
    debugPrint('Formatted Off Time: $formattedOffTime');
    try {
      final String url = alarm.enabled
          ? '${widget.ipAddress}/AutoTime'
          : '${widget.ipAddress}/deleteAutoTime';
      final Map<String, dynamic> payload = alarm.enabled
          ? {
              'ONTIME': formattedOnTime,
              'OFFTIME': formattedOffTime,
            }
          : {};
      final response = await ApiConnect.hitApiPost(url, payload);
      debugPrint("$response");
      if (response.toLowerCase() == "ok") {
        showToast(navigatorKey.currentContext!,
            alarm.enabled ? "Successfully scheduled" : "Successfully removed");
        debugPrint('API call successful: $response');
      } else {
        showToast(navigatorKey.currentContext!, "Something went wrong");
        debugPrint('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error during API call: $e');
    }
  }

  Future<void> selectTime(BuildContext context, bool isOnTime) async {
    final initialTime = isOnTime
        ? alarm?.onTime ?? TimeOfDay.now()
        : alarm?.offTime ?? TimeOfDay.now();
    final newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (newTime != null) {
      updateAlarm(newTime, isOnTime: isOnTime);
    }
  }

  Future<void> addNewAlarm() async {
    if (alarm != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Schedule Exists"),
          content: const Text("An alarm already exists for this switch."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final onTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select ON Time',
    );
    if (onTime == null) return;

    final offTime = await showTimePicker(
      context: navigatorKey.currentContext!,
      initialTime: onTime,
      helpText: 'Select OFF Time',
    );
    if (offTime == null) return;

    final newAlarm = Schedule(
      switchId: widget.switchName,
      onTime: onTime,
      offTime: offTime,
      enabled: false,
    );

    setState(() {
      alarm = newAlarm;
    });
    saveAlarm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule On/Off")),
      body: alarm == null
          ? const Center(child: Text("No alarm added"))
          : Center(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).appColors.textSecondary
                              .withValues(alpha: 0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(5, 5),
                          ),
                        ],
                        color: Theme.of(context).appColors.background,
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Switch Name: ",
                              style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).appColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                            Flexible(
                              child: Text(
                                widget.switchName,
                                style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        Theme.of(context).appColors.textPrimary,
                                    fontWeight: FontWeight.w400),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  color:
                                      Theme.of(context).appColors.textPrimary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'On Time: ${alarm!.onTime.format(context)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .appColors
                                          .textPrimary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => selectTime(context, true),
                              icon: Image.asset(
                                "assets/images/edit.png",
                                height: 25,
                                color: Theme.of(context).appColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled_outlined,
                                  color:
                                      Theme.of(context).appColors.textPrimary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Off Time: ${alarm!.offTime.format(context)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .appColors
                                          .textPrimary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => selectTime(context, false),
                              icon: Image.asset(
                                "assets/images/edit.png",
                                height: 25,
                                color: Theme.of(context).appColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).appColors.primary,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: Theme.of(context)
                                        .appColors
                                        .textSecondary),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Schedule"),
                                      content: const Text(
                                          "Are you sure you want to delete this alarm?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteAlarm();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Switch(
                                value: alarm!.enabled,
                                onChanged: toggleAlarm,
                                activeColor:
                                    Theme.of(context).appColors.greenButton,
                                activeTrackColor:
                                    Theme.of(context).appColors.green,
                                inactiveThumbColor:
                                    Theme.of(context).appColors.redButton,
                                inactiveTrackColor:
                                    Theme.of(context).appColors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: alarm != null
          ? null
          : FloatingActionButton(
              heroTag: "addTimer",
              onPressed: addNewAlarm,
              child: const Icon(Icons.add),
            ),
    );
  }
}
