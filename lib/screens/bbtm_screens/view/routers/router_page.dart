import 'dart:io';

import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/search_utils.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/router_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/nearby_wifi_page.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/router/import_export_routers.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/router/router_card.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'add_router.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  @override
  State<RouterPage> createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<RouterDetails> _allRouters = [];
  List<RouterDetails> _filteredRouters = [];
  bool _isFabVisible = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    fetchRouters();
    _speech = stt.SpeechToText();
    _scrollController.addListener(_handleScroll);
  }

  Future<void> fetchRouters() async {
    final routers = await _storageController.readRouters();
    setState(() {
      _allRouters = routers;
      _filteredRouters = routers;
    });
  }

  void _filterRouters(String query) {
    setState(() {
      _filteredRouters = smartFilter<RouterDetails>(
        _allRouters,
        query,
        [
          (item) => item.routerName,
          (item) => item.switchName,
          (item) => item.switchID,
          (item) => item.selectedFan ?? "",
        ],
      );
    });
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      if (_isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      }
    } else {
      if (!_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
          listenMode: stt.ListenMode.search,
        ),
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _filterRouters(result.recognizedWords);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = MediaQuery.of(context).size.height * 0.08;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // roundness
              ),
              child: Transform.rotate(
                angle: -90 * 3.1415926535897932 / 180,
                child: SvgPicture.asset(
                  "assets/images/wifi.svg",
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).appColors.background, BlendMode.srcIn),
                ),
              ),
              onPressed: () {
                if (Platform.isIOS) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddNewRouterPage(
                        isFromSwitch: false,
                        selectedWifiName: "",
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NearbyWifiPage(
                        isFromSwitch: false,
                      ),
                    ),
                  );
                }
              },
            )
          : null,
      appBar: AppBar(
        title: const Text('ROUTERS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showBackupOptions(onImported: fetchRouters),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            spacing: 30,
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
                child: _filteredRouters.isEmpty
                    ? CommonServices.noDataWidget()
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRouters.length,
                        itemBuilder: (context, index) {
                          final reversedIndex =
                              _filteredRouters.length - 1 - index;
                          final routerDetails = _filteredRouters[reversedIndex];
                          return RouterCard(routerDetails: routerDetails);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(height: screenWidth * 0.04);
                        },
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
                    elevation: WidgetStateProperty.all(4),
                    shadowColor: WidgetStateProperty.all(
                        Colors.black.withValues(alpha: 0.1)),
                    controller: _searchController,
                    onChanged: _filterRouters,
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).appColors.background,
                    ),
                    surfaceTintColor: WidgetStateProperty.all(
                      Theme.of(context).appColors.background,
                    ),
                    leading: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search devices...',
                    hintStyle: WidgetStateProperty.all(Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
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
}
