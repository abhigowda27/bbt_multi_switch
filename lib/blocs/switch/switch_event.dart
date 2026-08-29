abstract class SwitchEvent {}

class GetSwitchListEvent extends SwitchEvent {
  GetSwitchListEvent();
}

class AddSwitchEvent extends SwitchEvent {
  final Map<String, dynamic> payload;

  AddSwitchEvent({required this.payload});
}

class TriggerSwitchEvent extends SwitchEvent {
  final String status;
  final String deviceId;
  final String uuid;
  final String childuid;
  final int deviceType;

  TriggerSwitchEvent({
    required this.deviceId,
    required this.status,
    required this.uuid,
    required this.childuid,
    required this.deviceType,
  });
}

class DeleteSwitchEvent extends SwitchEvent {
  final String deviceId;
  final String uuid;

  DeleteSwitchEvent({
    required this.deviceId,
    required this.uuid,
  });
}

class GetSwitchStatus extends SwitchEvent {
  final Map<String, dynamic> payload;

  GetSwitchStatus({required this.payload});
}

class AddGroupEvent extends SwitchEvent {
  final Map<String, dynamic> payload;

  AddGroupEvent({required this.payload});
}

class GetGroupListEvent extends SwitchEvent {
  GetGroupListEvent();
}

class DeleteGroupEvent extends SwitchEvent {
  final String groupUuid;

  DeleteGroupEvent({
    required this.groupUuid,
  });
}
