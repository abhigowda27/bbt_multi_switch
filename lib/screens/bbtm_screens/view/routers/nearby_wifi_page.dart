import 'package:bbtml_new/screens/bbtm_screens/models/switch_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/add_router.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

class NearbyWifiPage extends StatefulWidget {
  const NearbyWifiPage(
      {super.key, this.switchDetails, required this.isFromSwitch});
  final SwitchDetails? switchDetails;
  final bool isFromSwitch;

  @override
  State<NearbyWifiPage> createState() => _NearbyWifiPageState();
}

class _NearbyWifiPageState extends State<NearbyWifiPage> {
  List<WiFiAccessPoint> wifiList = [];
  bool loading = false;
  bool permissionDenied = false;

  @override
  void initState() {
    super.initState();
    initScan();
  }

  Future<void> initScan() async {
    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => permissionDenied = true);
      return;
    }

    fetchNearbyWifi();
  }

  Future<void> fetchNearbyWifi() async {
    setState(() => loading = true);

    const int maxRetries = 10;
    int attempt = 0;

    List<WiFiAccessPoint> networks = [];

    while (attempt < maxRetries) {
      attempt++;

      final canScan = await WiFiScan.instance.canStartScan();

      if (canScan != CanStartScan.yes) {
        debugPrint("❌ Cannot scan: $canScan");
        break;
      }

      // 🔥 IMPORTANT: wait before fetching results
      await Future.delayed(const Duration(seconds: 2));

      final canGet = await WiFiScan.instance.canGetScannedResults();
      if (canGet != CanGetScannedResults.yes) {
        debugPrint("Cannot get results: $canGet");
        break;
      }

      networks = await WiFiScan.instance.getScannedResults();

      if (networks.isNotEmpty) {
        debugPrint("✅ WiFi found: ${networks.length}");
        break;
      }

      debugPrint("⚠️ Empty result, retrying... ($attempt/$maxRetries)");

      // 🔥 IMPORTANT: longer delay to avoid throttling
      await Future.delayed(const Duration(seconds: 4));
    }

    setState(() {
      wifiList = networks;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby WiFi Networks"),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowsRotate),
            onPressed: fetchNearbyWifi,
          )
        ],
      ),
      body: permissionDenied
          ? const Center(
              child: Text(
                "Location permission is required to scan Wi-Fi networks.",
                textAlign: TextAlign.center,
              ),
            )
          : loading
              ? const Center(child: CircularProgressIndicator())
              : wifiList.isEmpty
                  ? const Center(
                      child: Text("No WiFi networks found"),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Select a Router",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Please choose the router you want to configure your new smart switch with. "
                            "Tap on a Wi-Fi name below to proceed.",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Colors.grey[600], height: 1.4),
                          ),
                        ),
// After title & description, before ListView
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .appColors
                                .primary
                                .withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context)
                                  .appColors
                                  .primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).appColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "🔌 Make sure your mobile is connected to the device WiFi\n\n"
                                  "▼ Then select your HOME router from the list below. "
                                  "This router WiFi will be used for connecting the switch to your network.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .appColors
                                            .textPrimary,
                                        height: 1.5,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(10),
                            itemCount: wifiList.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final network = wifiList[index];

                              return Card(
                                color: Theme.of(context).appColors.background,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.wifi,
                                    size: 30,
                                    color:
                                        Theme.of(context).appColors.textPrimary,
                                  ),
                                  title: Text(network.ssid.isNotEmpty
                                      ? network.ssid
                                      : "Hidden Network"),
                                  titleTextStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                  // subtitle: Text(
                                  //   "Signal: ${network.level} dBm",
                                  // ),
                                  // subtitleTextStyle:
                                  //     Theme.of(context).textTheme.labelMedium,
                                  onTap: () {
                                    // Pass SSID to next page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddNewRouterPage(
                                          isFromSwitch: widget.isFromSwitch,
                                          switchDetails: widget.switchDetails,
                                          selectedWifiName: network.ssid,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}
