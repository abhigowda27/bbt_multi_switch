import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/screens/switches/group_page_cloud.dart';
import 'package:bbtml_new/screens/switches/widgets/switch_lists.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'add_switch_tab.dart';

class SwitchCloudPage extends StatefulWidget {
  const SwitchCloudPage({super.key});

  @override
  State<SwitchCloudPage> createState() => _SwitchCloudPageState();
}

class _SwitchCloudPageState extends State<SwitchCloudPage> {
  final SwitchBloc _switchBloc = SwitchBloc();
  List<dynamic> _deviceList = [];
  late stt.SpeechToText _speech;

  bool _isListening = false;

  @override
  void initState() {
    fetchSwitches();
    _speech = stt.SpeechToText();
    super.initState();
  }

  void fetchSwitches() {
    _switchBloc.add(GetSwitchListEvent());
  }

  bool _showListeningUI = false;

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _showListeningUI = true;
      });

      _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _showListeningUI = false; // Hide animation
      });
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device List"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupPageCloud(
                    switchBloc: _switchBloc,
                  ),
                ),
              );
            },
            icon: Image.asset(
              "assets/images/group_icon.png",
              color: Theme.of(context).appColors.background,
            ),
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // roundness
        ),
        child: Icon(
          color: Theme.of(context).appColors.background,
          Icons.add,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddSwitchTab(),
          ));
        },
      ),
      body: Stack(
        children: [
          BlocConsumer<SwitchBloc, CommonState>(
            bloc: _switchBloc,
            listener: (context, state) {
              ApiStatus apiResponse = state.apiStatus;
              if (apiResponse is ApiResponse) {
                final responseData = apiResponse.response;
                debugPrint("Response data====>$responseData");
                if (responseData != null) {
                  final deviceList = responseData['data'] ?? [];
                  _deviceList = deviceList;
                } else {
                  debugPrint("Unexpected response format: $responseData");
                }
              }
            },
            builder: (context, state) {
              ApiStatus apiResponse = state.apiStatus;
              if (apiResponse is ApiResponse) {
                return _deviceList.isNotEmpty
                    ? deviceListWidget()
                    : CommonServices.noDataWidget();
              } else if (apiResponse is ApiLoadingState ||
                  apiResponse is ApiInitialState) {
                return _deviceList.isEmpty
                    ? const SwitchLoader()
                    : deviceListWidget();
              } else if (apiResponse is ApiFailureState) {
                return Center(child: CommonServices.failureWidget(() {
                  fetchSwitches();
                }));
              } else {
                return Container();
              }
            },
          ),
          // 🎙️ LISTENING OVERLAY UI
          if (_showListeningUI)
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.4),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  size: 90,
                  color: Theme.of(context).appColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  final TextEditingController _searchController = TextEditingController();
  Widget deviceListWidget() {
    if (_deviceList.isEmpty) {
      return Center(child: Image.asset("assets/images/no_switch.png"));
    }
    double headerHeight = MediaQuery.of(context).size.height * 0.08;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          spacing: 30,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: Theme.of(context).appColors.primary,
              ),
              height: headerHeight,
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: _deviceList.length,
                itemBuilder: (context, index) {
                  return SwitchesCard(
                    searchController: _searchController,
                    onChanged: () {
                      fetchSwitches();
                    },
                    switchesDetails: _deviceList[index],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 15),
              ),
            ),
          ],
        ),
        Positioned(
          top: headerHeight - 25,
          left: 16,
          right: 16,
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                  flex: 5,
                  child: SearchBar(
                    controller: _searchController,
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).appColors.background,
                    ),
                    surfaceTintColor: WidgetStateProperty.all(
                      Theme.of(context).appColors.background,
                    ),
                    elevation: WidgetStateProperty.all(4),
                    shadowColor: WidgetStateProperty.all(
                        Colors.black.withValues(alpha: 0.1)),
                    leading: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search devices...',
                    hintStyle: WidgetStateProperty.all(Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                  )),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onLongPressStart: (_) => _startListening(),
                  onLongPressEnd: (_) => _stopListening(),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).appColors.background,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      size: 25,
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Theme.of(context).appColors.primary,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
