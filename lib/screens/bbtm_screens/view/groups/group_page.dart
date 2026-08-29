import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/common/search_utils.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/groups/group_on_off.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../controllers/storage.dart';
import '../../models/group_model.dart';
import '../../widgets/group/group_card.dart';
import '../../widgets/group/import_export_groups.dart';
import 'add_group.dart';
import 'connect_to_group.dart';

class GroupingPage extends StatefulWidget {
  const GroupingPage({super.key});

  @override
  State<GroupingPage> createState() => _GroupingPageState();
}

class _GroupingPageState extends State<GroupingPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  List<GroupDetails> _allGroups = [];
  List<GroupDetails> _filteredGroups = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final NetworkService _networkService = NetworkService();
  String _wifiName = "";
  late VoidCallback _wifiListener;

  @override
  void dispose() {
    _networkService.wifiNameNotifier.removeListener(_wifiListener);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _wifiName = _networkService.wifiName;

    _wifiListener = () {
      if (!mounted) return;
      setState(() {
        _wifiName = _networkService.wifiName;
      });
    };

    _networkService.wifiNameNotifier.addListener(_wifiListener);
    _speech = stt.SpeechToText();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final groups = await _storageController.readAllGroups();
    setState(() {
      _allGroups = groups;
      _filteredGroups = groups;
    });
  }

  void _filterGroups(String query) {
    setState(() {
      _filteredGroups = smartFilter<GroupDetails>(
        _allGroups,
        query,
        [
          (item) => item.groupName,
          (item) => item.selectedRouter,
        ],
      );
    });
  }

  // ✅ Helper method (clean + reusable)
  bool _isConnectedToRouter(String routerName) {
    return _wifiName.toLowerCase().contains(routerName.toLowerCase()) ||
        routerName.toLowerCase().contains(_wifiName.toLowerCase());
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
            _filterGroups(result.recognizedWords);
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Theme.of(context).appColors.background),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewGroupInstallationPage(),
            ),
          );
        },
      ),
      appBar: AppBar(
        title: const Text("GROUPS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showBackupOptions(onImported: fetchGroups),
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
                child: _filteredGroups.isEmpty
                    ? CommonServices.noDataWidget()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        itemCount: _filteredGroups.length,
                        itemBuilder: (context, index) {
                          final groupDetails = _filteredGroups[index];
                          return GestureDetector(
                              onTap: () {
                                !_isConnectedToRouter(
                                        groupDetails.selectedRouter)
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ConnectToGroupWidget(
                                                  groupName:
                                                      groupDetails.groupName,
                                                  selectedRouter: groupDetails
                                                      .selectedRouter,
                                                  selectedSwitches: groupDetails
                                                      .selectedSwitches,
                                                  maximumWattage: groupDetails
                                                      .maximumWattage,
                                                )))
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GroupSwitchOnOff(
                                            maximumWattage:
                                                groupDetails.maximumWattage,
                                            groupName: groupDetails.groupName,
                                            selectedRouter:
                                                groupDetails.selectedRouter,
                                            selectedSwitches:
                                                groupDetails.selectedSwitches,
                                          ),
                                        ),
                                      );
                              },
                              child: GroupCard(
                                groupDetails: groupDetails,
                              ));
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
                    onChanged: _filterGroups,
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
