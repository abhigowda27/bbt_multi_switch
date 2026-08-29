import 'api_status.dart';

class CommonState {
  final ApiStatus apiStatus;

  CommonState({this.apiStatus = const ApiInitialState()});

  CommonState copyWith({ApiStatus? apiStatus}) {
    return CommonState(apiStatus: apiStatus ?? this.apiStatus);
  }
}
