import 'package:flutter/cupertino.dart';

class FingerPrintDetails {
  late List<String> names;
  late String switchName;

  FingerPrintDetails({required this.names, required this.switchName});

  FingerPrintDetails.fromJson(Map<String, dynamic> json) {
    debugPrint("$json");
    names = (json['names'] as List).map((e) => e.toString()).toList();
    switchName = json['switchName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['names'] = names;
    data['switchName'] = switchName;
    return data;
  }
}
