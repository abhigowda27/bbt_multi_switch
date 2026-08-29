import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/controllers/shared_preference.dart';
import 'package:bbtml_new/repositories/login_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, CommonState> {
  LoginBloc() : super(CommonState()) {
    on<UserLoginEvent>(_onUserLoginEvent);
    on<SendOtpEvent>(_onSendOtpEvent);
    on<VerifyOtpEvent>(_onVerifyOtpEvent);
    on<UserLogOutEvent>(_onUserLogOutEvent);
  }

  Future<void> _onUserLoginEvent(
      UserLoginEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = {"password": event.password, "email": event.username};
      Repository loginRepository = Repository();
      final getLoggedInUser = await loginRepository.loginRepo(payload);
      if (getLoggedInUser != null && getLoggedInUser["status"] == "success") {
        SharedPreferenceServices().saveLoggedInStatus(true);
      }
      emit(state.copyWith(apiStatus: ApiResponse(response: getLoggedInUser)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onSendOtpEvent(
      SendOtpEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = {"mobile": event.mobile, "country_code": 91};
      Repository loginRepository = Repository();
      final getLoggedInUser = await loginRepository.sendOtp(payload);
      // if (getLoggedInUser != null && getLoggedInUser["status"] == "success") {
      //   SharedPreferenceServices().saveLoggedInStatus(true);
      // }
      emit(state.copyWith(apiStatus: ApiResponse(response: getLoggedInUser)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onVerifyOtpEvent(
      VerifyOtpEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      final payload = {
        "mobile": event.mobile,
        "country_code": 91,
        "otp": event.otp
      };
      Repository loginRepository = Repository();
      final verifyOtp = await loginRepository.verifyOtp(payload);
      if (verifyOtp != null && verifyOtp["status"] == "success") {
        SharedPreferenceServices().saveLoggedInStatus(true);
      }
      emit(state.copyWith(apiStatus: ApiResponse(response: verifyOtp)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }

  Future<void> _onUserLogOutEvent(
      UserLogOutEvent event, Emitter<CommonState> emit) async {
    emit(state.copyWith(apiStatus: ApiLoadingState()));
    try {
      Repository loginRepository = Repository();
      final userLogout = await loginRepository.logoutRepo();
      if (userLogout != null && userLogout["status"] == "success") {
        SharedPreferenceServices().saveLoggedInStatus(false);
      }
      emit(state.copyWith(apiStatus: ApiResponse(response: userLogout)));
    } catch (e) {
      emit(state.copyWith(apiStatus: ApiFailureState(exception: e)));
    }
  }
}
