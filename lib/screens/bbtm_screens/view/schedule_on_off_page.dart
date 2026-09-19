import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../controllers/apis.dart';
import '../controllers/storage.dart';
import '../models/schedule_model.dart';
import '../widgets/custom/toast.dart';

class ScheduleOnOffPage extends StatefulWidget {
  final String switchName;
  final String ipAddress;

  const ScheduleOnOffPage({
    super.key,
    required this.switchName,
    required this.ipAddress,
  });

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

// ---------------------------------------------------------------------------
// STORAGE
// ---------------------------------------------------------------------------

  Future<void> saveAlarm() async {
    if (alarm != null) {
      await _storageController.saveAlarm(
        widget.switchName,
        alarm!,
      );
    }
  }

  Future<void> loadAlarm() async {
    final loadedAlarm = await _storageController.loadAlarm(
      widget.switchName,
    );

    if (loadedAlarm != null) {
      setState(() {
        alarm = loadedAlarm;
      });
    }
  }

  Future<void> deleteAlarm() async {
    setState(() {
      alarm = null;
    });

    await _storageController.deleteAlarm(
      widget.switchName,
    );
  }

// ---------------------------------------------------------------------------
// SCHEDULE
// ---------------------------------------------------------------------------

  void updateAlarm(
    TimeOfDay newTime, {
    bool isOnTime = true,
  }) {
    if (alarm == null) return;

    setState(() {
      if (isOnTime) {
        alarm!.onTime = newTime;
      } else {
        alarm!.offTime = newTime;
      }
    });

    saveAlarm();
    makeApiCall(alarm!);
  }

  void toggleAlarm(bool value) {
    if (alarm == null) return;

    setState(() {
      alarm!.enabled = value;
    });

    saveAlarm();
    makeApiCall(alarm!);
  }

// ---------------------------------------------------------------------------
// API
// ---------------------------------------------------------------------------

  Future<void> makeApiCall(Schedule alarm) async {
    final DateTime onTime = DateTime(
      2023,
      1,
      1,
      alarm.onTime.hour,
      alarm.onTime.minute,
    );

    final DateTime offTime = DateTime(
      2023,
      1,
      1,
      alarm.offTime.hour,
      alarm.offTime.minute,
    );

    final String formattedOnTime = DateFormat('HH:mm:ss').format(onTime);

    final String formattedOffTime = DateFormat('HH:mm:ss').format(offTime);

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

      final response = await ApiConnect.hitApiPost(
        url,
        payload,
      );

      debugPrint('$response');

      if (response.toLowerCase() == 'ok') {
        showToast(
          navigatorKey.currentContext!,
          alarm.enabled ? 'Successfully scheduled' : 'Successfully removed',
        );

        debugPrint('API call successful: $response');
      } else {
        showToast(
          navigatorKey.currentContext!,
          'Something went wrong',
        );

        debugPrint(
          'API call failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error during API call: $e');
    }
  }

// ---------------------------------------------------------------------------
// TIME PICKER
// ---------------------------------------------------------------------------
  Future<void> selectTime(
    BuildContext context,
    bool isOnTime,
  ) async {
    if (alarm == null) return;

    final TimeOfDay initialTime = isOnTime ? alarm!.onTime : alarm!.offTime;

    final TimeOfDay? newTime = await _showTimePickerSheet(
      context: context,
      initialTime: initialTime,
      title: isOnTime ? 'Set ON Time' : 'Set OFF Time',
      subtitle: isOnTime
          ? 'Choose when the switch should turn on'
          : 'Choose when the switch should turn off',
      icon: isOnTime ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
    );

    if (newTime != null) {
      updateAlarm(
        newTime,
        isOnTime: isOnTime,
      );
    }
  }

  Future<TimeOfDay?> _showTimePickerSheet({
    required BuildContext context,
    required TimeOfDay initialTime,
    required String title,
    required String subtitle,
    required IconData icon,
  }) async {
    final colors = Theme.of(context).appColors;

    TimeOfDay selectedTime = initialTime;

    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      icon,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      primaryColor: colors.primary,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: false,
                      initialDateTime: DateTime(
                        2023,
                        1,
                        1,
                        initialTime.hour,
                        initialTime.minute,
                      ),
                      onDateTimeChanged: (dateTime) {
                        selectedTime = TimeOfDay(
                          hour: dateTime.hour,
                          minute: dateTime.minute,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, selectedTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// ---------------------------------------------------------------------------
// CREATE SCHEDULE
// ---------------------------------------------------------------------------

  Future<void> addNewAlarm() async {
    if (alarm != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Schedule Exists'),
          content: const Text(
            'An alarm already exists for this switch.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    final TimeOfDay? onTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select ON Time',
    );

    if (onTime == null) return;

    final TimeOfDay? offTime = await showTimePicker(
      context: context,
      initialTime: onTime,
      helpText: 'Select OFF Time',
    );

    if (offTime == null) return;

    final Schedule newAlarm = Schedule(
      switchId: widget.switchName,
      onTime: onTime,
      offTime: offTime,
      enabled: false,
    );

    setState(() {
      alarm = newAlarm;
    });

    await saveAlarm();
  }

// ---------------------------------------------------------------------------
// DELETE CONFIRMATION
// ---------------------------------------------------------------------------

  Future<void> confirmDeleteSchedule() async {
    if (alarm == null) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).appColors;

        return AlertDialog(
          title: const Text('Delete schedule?'),
          content: const Text(
            'This will remove the scheduled ON/OFF times for this switch.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: colors.redButton,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteAlarm();

      if (mounted) {
        showToast(
          navigatorKey.currentContext!,
          'Schedule deleted',
        );
      }
    }
  }

// ---------------------------------------------------------------------------
// BUILD
// ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(
          'Schedule',
        ),
      ),
      body: alarm == null
          ? _buildEmptyState(colors)
          : _buildScheduleContent(colors),
    );
  }

// ---------------------------------------------------------------------------
// EMPTY STATE
// ---------------------------------------------------------------------------

  Widget _buildEmptyState(AppColors colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 46,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No schedule yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Automate this switch by setting an ON and OFF time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: addNewAlarm,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Create schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

// ---------------------------------------------------------------------------
// SCHEDULE CONTENT
// ---------------------------------------------------------------------------

  Widget _buildScheduleContent(AppColors colors) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceHeader(colors),
            const SizedBox(height: 24),
            Text(
              'Schedule times',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeCard(
                    colors: colors,
                    title: 'TURN ON',
                    time: alarm!.onTime,
                    icon: Icons.wb_sunny_outlined,
                    onEdit: () => selectTime(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeCard(
                    colors: colors,
                    title: 'TURN OFF',
                    time: alarm!.offTime,
                    icon: Icons.nightlight_outlined,
                    onEdit: () => selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSummaryCard(colors),
            const SizedBox(height: 28),
            _buildDeleteButton(colors),
          ],
        ),
      ),
    );
  }

// ---------------------------------------------------------------------------
// DEVICE HEADER
// ---------------------------------------------------------------------------

  Widget _buildDeviceHeader(AppColors colors) {
    final bool enabled = alarm!.enabled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 30,
              color: enabled ? colors.primary : colors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.switchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            enabled ? colors.greenButton : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      enabled ? 'Schedule active' : 'Schedule disabled',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: toggleAlarm,
            activeColor: colors.greenButton,
            activeTrackColor: colors.green,
            inactiveThumbColor: colors.redButton,
            inactiveTrackColor: colors.red,
          ),
        ],
      ),
    );
  }

// ---------------------------------------------------------------------------
// TIME CARD
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------

  Widget _buildTimeCard({
    required AppColors colors,
    required String title,
    required TimeOfDay time,
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textSecondary.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: colors.primary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              time.format(context),
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Every day',
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
// SUMMARY
// ---------------------------------------------------------------------------

  Widget _buildSummaryCard(AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            colors,
            Icons.wb_sunny_outlined,
            'Turns ON',
            alarm!.onTime.format(context),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            colors,
            Icons.nightlight_outlined,
            'Turns OFF',
            alarm!.offTime.format(context),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            colors,
            Icons.repeat_rounded,
            'Repeats',
            'Every day',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    AppColors colors,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

// ---------------------------------------------------------------------------
// DELETE
// ---------------------------------------------------------------------------

  Widget _buildDeleteButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: confirmDeleteSchedule,
        icon: Icon(
          Icons.delete_outline_rounded,
          color: colors.redButton,
        ),
        label: Text(
          'Delete schedule',
          style: TextStyle(
            color: colors.redButton,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: colors.redButton.withValues(alpha: 0.35),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
