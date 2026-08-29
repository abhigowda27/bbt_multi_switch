class ApiStatus {
  const ApiStatus();
}

class ApiInitialState extends ApiStatus {
  const ApiInitialState();
}

class ApiLoadingState extends ApiStatus {
  final List<dynamic>? responseList;
  ApiLoadingState({this.responseList});

  List<Object?> get props => [];
}

class ApiSuccessState extends ApiStatus {
  final List<dynamic>? responseList;
  ApiSuccessState({this.responseList});
  ApiSuccessState copyWith({List<dynamic>? response}) {
    return ApiSuccessState(responseList: response ?? responseList);
  }

  List<Object?> get props => [responseList];

  @override
  String toString() {
    return 'ApiSuccessState{responseList: $responseList}';
  }
}

class ApiFailureState extends ApiStatus {
  dynamic exception;
  ApiFailureState({this.exception});
}

class ApiResponse extends ApiStatus {
  dynamic response;
  ApiResponse({this.response});
}
