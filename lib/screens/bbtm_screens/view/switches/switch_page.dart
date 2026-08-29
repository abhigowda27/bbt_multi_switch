import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/search_utils.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/switches/import_export_switches.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/switches/switches_card.dart';
import '../qr/gallery_qr.dart';
import '../qr/qr_view.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<SwitchDetails> _allSwitches = [];
  List<SwitchDetails> _filteredSwitches = [];
  bool _isFabVisible = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    fetchSwitches();
    _speech = stt.SpeechToText();
    _scrollController.addListener(() {
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
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSwitches() async {
    final switches = await _storageController.readSwitches();
    setState(() {
      _allSwitches = switches;
      _filteredSwitches = switches;
    });
  }

  void _filterSwitches(String query) {
    setState(() {
      _filteredSwitches = smartFilter<SwitchDetails>(
        _allSwitches,
        query,
        [
          (item) => item.switchSSID,
          (item) => item.switchId,
          (item) => item.selectedFan ?? "",
        ],
      );
    });

    if (_filteredSwitches.length == 1) {
      _stopListening();
      Future.delayed(const Duration(milliseconds: 500), () {
        _singleCardKey?.currentState?.performTap();
      });
    }
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
            _filterSwitches(result.recognizedWords);
          });
        },
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _showListeningUI = false;
      });
      _speech.stop();
    }
  }

  GlobalKey<SwitchCardState>? _singleCardKey;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = MediaQuery.of(context).size.height * 0.08;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QRView(),
                ));
              },
              heroTag: "QR",
              child: Icon(Icons.camera_alt_outlined,
                  color: Theme.of(context).appColors.background),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "gallery",
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GalleryQRPage(),
                ));
              },
              child: Icon(Icons.image_outlined,
                  color: Theme.of(context).appColors.background),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("SWITCHES"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showBackupOptions(onImported: fetchSwitches),
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
                child: _filteredSwitches.isEmpty
                    ? CommonServices.noDataWidget()
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSwitches.length,
                        itemBuilder: (context, index) {
                          final reversedIndex =
                              _filteredSwitches.length - 1 - index;
                          final switchDetails =
                              _filteredSwitches[reversedIndex];
                          return SwitchCard(
                            key: _filteredSwitches.length == 1
                                ? (_singleCardKey =
                                    GlobalKey<SwitchCardState>())
                                : GlobalKey(),
                            switchDetails: switchDetails,
                          );
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
                    onChanged: _filterSwitches,
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
