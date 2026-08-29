import 'package:flutter/material.dart';

class Schedule {
  final String switchId;
  TimeOfDay onTime;
  TimeOfDay offTime;
  bool enabled;

  Schedule({
    required this.switchId,
    required this.onTime,
    required this.offTime,
    this.enabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'switchId': switchId,
      'onTime': '${onTime.hour}:${onTime.minute}',
      'offTime': '${offTime.hour}:${offTime.minute}',
      'enabled': enabled,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final onTimeParts = json['onTime'].split(':');
    final offTimeParts = json['offTime'].split(':');

    return Schedule(
      switchId: json['switchId'],
      onTime: TimeOfDay(
        hour: int.parse(onTimeParts[0]),
        minute: int.parse(onTimeParts[1]),
      ),
      offTime: TimeOfDay(
        hour: int.parse(offTimeParts[0]),
        minute: int.parse(offTimeParts[1]),
      ),
      enabled: json['enabled'],
    );
  }
}
