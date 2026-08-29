import 'router_model.dart';

class GroupDetails {
  late String groupName;
  late String selectedRouter;
  late String routerPassword;
  late int maximumWattage;
  late List<RouterDetails> selectedSwitches;

  GroupDetails({
    required this.groupName,
    required this.selectedRouter,
    required this.routerPassword,
    required this.maximumWattage,
    required this.selectedSwitches,
  });

  GroupDetails.fromJson(Map<String, dynamic> json) {
    groupName = json['groupName'];
    selectedRouter = json['selectedRouter'];
    routerPassword = json['routerPassword'];
    maximumWattage = json['maximumWattage'] ?? 00;
    var switchList = json['selectedSwitches'] as List;
    selectedSwitches =
        switchList.map((e) => RouterDetails.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupName'] = groupName;
    data['selectedRouter'] = selectedRouter;
    data['routerPassword'] = routerPassword;
    data['maximumWattage'] = maximumWattage;
    data['selectedSwitches'] = selectedSwitches.map((e) => e.toJson()).toList();
    return data;
  }
}
