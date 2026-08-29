import 'dart:async';

import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/fingerprint_card.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../controllers/storage.dart';
import '../../models/switch_model.dart';

class FingersPage extends StatefulWidget {
  const FingersPage({super.key});

  @override
  State<FingersPage> createState() => _FingersPageState();
}

class _FingersPageState extends State<FingersPage> {
  final StorageController _storageController = StorageController();

  final NetworkService _networkService = NetworkService();
  String _wifiName = "";
  late VoidCallback _wifiListener;
  Future<List<SwitchDetails>> fetchLocks() async {
    return _storageController.readSwitchesByType("DOOR_LOCK");
  }

  @override
  void dispose() {
    _networkService.wifiNameNotifier.removeListener(_wifiListener);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fingerprints")),
      body: FutureBuilder(
          future: fetchLocks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                  color: Theme.of(context).appColors.buttonBackground);
            }
            if (snapshot.hasError) {
              debugPrint("${snapshot.error}");
              debugPrint("StackTrace: ${snapshot.stackTrace}");

              return const Text("ERROR");
            }
            return snapshot.data!.isNotEmpty
                ? ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 16,
                      );
                    },
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return FingerprintCard(
                        switchDetails: snapshot.data![index],
                        wifiName: _wifiName,
                      );
                    })
                : CommonServices.noDataWidget();
          }),
    );
  }
}
