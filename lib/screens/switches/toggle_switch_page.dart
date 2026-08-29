import 'dart:async';

import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/switch/switch_event.dart';
import '../../common/api_status.dart';
import '../../common/common_state.dart';
import '../../widgets/common_snackbar.dart';

class SwitchOnOff extends StatefulWidget {
  const SwitchOnOff({
    super.key,
    required this.switchDetails,
  });

  final Map<String, dynamic> switchDetails;

  @override
  State<SwitchOnOff> createState() => _SwitchOnOffState();
}

class _SwitchOnOffState extends State<SwitchOnOff> {
  String switchStatus = "Off";
  bool switchOff = true;
  late Timer _timer;
  final SwitchBloc _switchBloc = SwitchBloc();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 15), _navigateToNextPage);
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const TabsPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: GestureDetector(
        onTap: _resetTimer,
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Theme.of(context).appColors.background,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "The status of the Switch is ",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      switchStatus.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).appColors.background,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _resetTimer();
                        try {
                          String newStatus = switchOff ? "ON" : "OFF";
                          _switchBloc.add(TriggerSwitchEvent(
                            deviceId: widget.switchDetails["device_id"],
                            status: newStatus,
                            uuid: widget.switchDetails["uid"],
                            deviceType: widget.switchDetails["device_type"],
                            childuid: '',
                          ));
                        } on DioException {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unable to perform. Try Again."),
                            ),
                          );
                        } catch (e) {
                          debugPrint(e.toString());
                        } finally {
                          _resetTimer();
                        }
                      },
                      child: BlocConsumer<SwitchBloc, CommonState>(
                          bloc: _switchBloc,
                          listener: (context, state) {
                            ApiStatus apiResponse = state.apiStatus;
                            if (apiResponse is ApiResponse) {
                              final responseData = apiResponse.response;
                              debugPrint("Response data====>$responseData");
                              if (responseData != null) {
                                final String? switchApiStatus =
                                    responseData?['data']?['status'];

                                setState(() {
                                  switchStatus =
                                      switchApiStatus == "ON" ? "On" : "Off";
                                  switchOff = switchApiStatus != "ON";
                                });
                              } else {
                                debugPrint(
                                    "Unexpected response format: $responseData");
                              }
                            } else if (apiResponse is ApiLoadingState) {
                            } else if (apiResponse is ApiFailureState) {
                              final exception =
                                  apiResponse.exception.toString();
                              debugPrint(exception);
                              String errorMessage =
                                  'Something went wrong! Please try again';
                              final messageMatch = RegExp(r'message:\s*([^}]+)')
                                  .firstMatch(exception);
                              if (messageMatch != null) {
                                errorMessage = messageMatch.group(1)?.trim() ??
                                    errorMessage;
                              }
                              showSnackBar(context, errorMessage);
                            }
                          },
                          builder: (context, state) {
                            ApiStatus apiResponse = state.apiStatus;

                            if (apiResponse is ApiLoadingState) {
                              return const CircularProgressIndicator();
                            }
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade400,
                                    blurRadius: 7,
                                    offset: const Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 100,
                                backgroundColor: switchOff
                                    ? Theme.of(context).appColors.red
                                    : Theme.of(context).appColors.green,
                                child: Icon(
                                  Icons.power_settings_new,
                                  size: 60,
                                  color: switchOff
                                      ? Theme.of(context).appColors.redButton
                                      : Theme.of(context).appColors.green,
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
