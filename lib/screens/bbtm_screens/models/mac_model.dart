import 'switch_model.dart';

class MacsDetails {
  late String name;
  late String id;
  late bool isPresentInESP;
  late SwitchDetails switchDetails;

  MacsDetails(
      {required this.id,
      required this.name,
      required this.isPresentInESP,
      required this.switchDetails});

  MacsDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    isPresentInESP = json['isPresentInESP'];
    switchDetails = SwitchDetails.fromJson(json['switchDetails']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    data['isPresentInESP'] = isPresentInESP;
    data['switchDetails'] = switchDetails.toJson();
    return data;
  }
}
