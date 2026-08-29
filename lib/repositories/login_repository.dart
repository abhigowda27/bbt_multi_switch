import '../api_providers/api_provider.dart';

class Repository {
  final ApiProvider apiProvider = ApiProvider();

  Future<dynamic> loginRepo(Map<String, dynamic> payload) async {
    return apiProvider.login(payload);
  }

  Future<dynamic> logoutRepo() async {
    return apiProvider.logout();
  }

  Future<dynamic> sendOtp(Map<String, dynamic> payload) async {
    return apiProvider.sendOtp(payload);
  }

  Future<dynamic> verifyOtp(Map<String, dynamic> payload) async {
    return apiProvider.verifyOtp(payload);
  }

  Future<dynamic> addSwitchRepo(Map<String, dynamic> payload) async {
    return apiProvider.addSwitch(payload);
  }

  Future<dynamic> getSwitchListRepo() async {
    return apiProvider.getSwitchList();
  }

  Future<dynamic> triggerSwitchRepo(Map<String, dynamic> payload) async {
    return apiProvider.triggerSwitch(payload);
  }

  Future<dynamic> deleteSwitchRepo(Map<String, dynamic> payload) async {
    return apiProvider.deleteSwitch(payload);
  }

  Future<dynamic> getSwitchStatus(Map<String, dynamic> payload) async {
    return apiProvider.getSwitchStatus(payload);
  }

  Future<dynamic> addGroupRepo(Map<String, dynamic> payload) async {
    return apiProvider.addGroup(payload);
  }

  Future<dynamic> getGroupListRepo() async {
    return apiProvider.getGroupList();
  }

  Future<dynamic> deleteGroupDataRepo(Map<String, dynamic> payload) async {
    return apiProvider.deleteGroupData(payload);
  }
}
