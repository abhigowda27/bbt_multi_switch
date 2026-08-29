import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/repositories/login_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchBloc extends Bloc<SwitchEvent, CommonState> {
  SwitchBloc() : super(CommonState()) {
    on<AddSwitchEvent>(_onAddSwitchEvent);
    on<TriggerSwitchEvent>(_onTriggerSwitchEvent);
    on<DeleteSwitchEvent>(_onDeleteSwitchEvent);
    on<GetSwitchListEvent>(_onGetSwitchListEvent);
    on<GetSwitchStatus>(_onGetSwitchStatus);
    on<AddGroupEvent>(_onAddGroupEvent);
    on<GetGroupListEvent>(_onGetGroupListEvent);
    on<DeleteGroupEvent>(_onDeleteGroupEvent);
  }

  Future<void> _onGetSwitchListEvent(
      GetSwitchListEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      Repository addSwitchRepository = Repository();
      final switchListResponse = await addSwitchRepository.getSwitchListRepo();

      emit(
          state.copyWith(apiStatus: ApiResponse(response: switchListResponse)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onAddSwitchEvent(
      AddSwitchEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = event.payload;
      Repository addSwitchRepository = Repository();
      final addSwitchResponse =
          await addSwitchRepository.addSwitchRepo(payload);

      emit(state.copyWith(apiStatus: ApiResponse(response: addSwitchResponse)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onTriggerSwitchEvent(
      TriggerSwitchEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = {
        "status": event.status,
        "deviceId": event.deviceId,
        "uid": event.uuid,
        "deviceType": event.deviceType,
        "childuid": event.childuid
      };
      Repository addSwitchRepository = Repository();
      final triggerSwitchResponse =
          await addSwitchRepository.triggerSwitchRepo(payload);

      emit(state.copyWith(
          apiStatus: ApiResponse(response: triggerSwitchResponse)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onDeleteSwitchEvent(
      DeleteSwitchEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = {"uid": event.uuid, "deviceId": event.deviceId};
      Repository addSwitchRepository = Repository();
      final deleteSwitchResponse =
          await addSwitchRepository.deleteSwitchRepo(payload);

      emit(state.copyWith(
          apiStatus: ApiResponse(response: deleteSwitchResponse)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onGetSwitchStatus(
      GetSwitchStatus event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = event.payload;
      Repository addSwitchRepository = Repository();
      final getSwitchStatusResponse =
          await addSwitchRepository.getSwitchStatus(payload);

      if (getSwitchStatusResponse['status'] == 'error') {
        emit(state.copyWith(
            apiStatus: ApiFailureState(
                exception: getSwitchStatusResponse["message"] ??
                    "Something Went Wrong")));
      } else {
        emit(state.copyWith(
            apiStatus: ApiResponse(response: getSwitchStatusResponse)));
      }
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onAddGroupEvent(
      AddGroupEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = event.payload;
      Repository addGroupRepository = Repository();
      final getSwitchStatusResponse =
          await addGroupRepository.addGroupRepo(payload);

      if (getSwitchStatusResponse['status'] == 'error') {
        emit(state.copyWith(
            apiStatus: ApiFailureState(
                exception: getSwitchStatusResponse["message"] ??
                    "Something Went Wrong")));
      } else {
        emit(state.copyWith(
            apiStatus: ApiResponse(response: getSwitchStatusResponse)));
      }
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onGetGroupListEvent(
      GetGroupListEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      Repository getGroupListRepository = Repository();
      final groupListResponse = await getGroupListRepository.getGroupListRepo();

      emit(state.copyWith(apiStatus: ApiResponse(response: groupListResponse)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onDeleteGroupEvent(
      DeleteGroupEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = {"id": event.groupUuid};
      Repository addSwitchRepository = Repository();
      final deleteSwitchResponse =
          await addSwitchRepository.deleteGroupDataRepo(payload);

      emit(state.copyWith(
          apiStatus: ApiResponse(response: deleteSwitchResponse)));
    } catch (e) {
      debugPrint("Error: $e");
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }
}
