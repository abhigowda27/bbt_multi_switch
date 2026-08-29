import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/home_screen.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/qr/generate_qr.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/routers/router_page.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/settings.dart';
import 'package:bbtml_new/screens/bbtm_screens/view/switches/switch_page.dart';
import 'package:bbtml_new/screens/switches/switch_page_cloud.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/storage.dart';
import '../controllers/wifi.dart';
import '../widgets/qr_pin.dart';
import 'contacts/contacts_page.dart';
import 'groups/group_page.dart';
import 'mac/mac_page.dart';

class GridItem {
  final String name;
  final String icon;
  final Color? color;
  final Widget navigateTo;

  GridItem(
      {required this.name,
      required this.icon,
      required this.navigateTo,
      this.color});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final StorageController _storageController = StorageController();
  final List<GridItem> lists = [
    GridItem(
        name: 'Users',
        icon: "assets/images/user.png",
        navigateTo: const ContactsPage(),
        color: Colors.lightBlue),
    GridItem(
        name: 'Switches',
        icon: "assets/images/switch.png",
        navigateTo: const SwitchPage(),
        color: Colors.redAccent),
    GridItem(
        name: 'Routers',
        icon: "assets/images/wifi-router.png",
        navigateTo: const RouterPage(),
        color: Colors.deepPurple),
    GridItem(
        name: 'Groups',
        icon: "assets/images/group_icon.png",
        navigateTo: const GroupingPage(),
        color: Colors.green),
    GridItem(
        name: 'MACs Page',
        icon: "assets/images/MAC.png",
        navigateTo: const MacsPage(),
        color: null),
    GridItem(
      name: 'Cloud',
      icon: "assets/images/cloud-connect.png",
      navigateTo: const SwitchCloudPage(),
    ),
    GridItem(
        name: 'Generate QR',
        icon: "assets/images/qr-code.png",
        navigateTo: const SettingsPage(),
        color: Colors.orange),
    GridItem(
        name: 'Settings',
        icon: "assets/images/settings.png",
        navigateTo: const SettingsPage(),
        color: Colors.orange),
  ];

  bool _locationEnabled = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestAllPermissions();
    });
  }

  Future<void> _showPermissionDialog(Permission permission) async {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint("Cannot show permission dialog: navigatorKey context is null");
      return; // Or fallback to something else
    }

    String permissionName = permission.toString().split('.').last;
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text("$permissionName Permission Required"),
          content: Text(
              "The app needs $permissionName permission to function properly. Please enable it in Settings."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }

  Future<void> requestAllPermissions() async {
    // List of permissions you need
    List<Permission> permissions = [
      Permission.camera,
      Permission.contacts,
      Permission.locationWhenInUse,
      Permission.microphone,
      Permission.location,
    ];

    for (var permission in permissions) {
      PermissionStatus status = await permission.status;

      if (status.isDenied) {
        status = await permission.request();
      }

      if (status.isPermanentlyDenied) {
        // Open app settings so the user can manually enable it
        await _showPermissionDialog(permission);
      }

      debugPrint("Permission: $permission, Status: $status");
    }

    // Check location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() => _locationEnabled = serviceEnabled);

    if (!serviceEnabled) {
      _showEnableLocationDialog();
    }
  }

  void _showEnableLocationDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint("Cannot show location dialog: context null");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).appColors.background,
            content: const Text(
              "Location services are turned off. Please enable GPS to continue.",
            ),
            icon: Image.asset(
              "assets/images/gps.gif",
              height: 100,
              width: 100,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Go To Settings"),
                  onPressed: () async {
                    await AppSettings.openAppSettings(
                        type: AppSettingsType.location);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (serviceEnabled && !_locationEnabled) {
        setState(() => _locationEnabled = true);

        if (Navigator.canPop(navigatorKey.currentContext!)) {
          Navigator.of(navigatorKey.currentContext!).pop();
        }
      } else if (!serviceEnabled && _locationEnabled) {
        setState(() => _locationEnabled = false);
        _showEnableLocationDialog();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return Scaffold(
      // backgroundColor: Theme.of(context).appColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ValueListenableBuilder<String?>(
              valueListenable: NetworkService().wifiNameNotifier,
              builder: (context, wifiName, _) {
                return ImageCarouselWidget(
                  connectionStatus: wifiName ?? "Unknown",
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverGrid.builder(
              itemCount: lists.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width > 600 ? 4 : 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: width > 600 ? 25 : 20,
                mainAxisSpacing: width > 600 ? 25 : 20,
              ),
              itemBuilder: (context, index) {
                final item = lists[index];
                return GestureDetector(
                  onTap: () async {
                    if (item.name == 'Generate QR') {
                      final qrPin = await _storageController.getQrPin();
                      PinDialog pinDialog =
                          PinDialog(navigatorKey.currentContext!);
                      pinDialog.showPinDialog(
                        isFirstTime: qrPin == null,
                        onSuccess: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GenerateQRPage(),
                            ),
                          );
                        },
                      );
                    } else {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, _, __) => item.navigateTo,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .appColors
                          .primary
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Theme.of(context).appColors.primary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item.icon,
                            height: height * .045, color: item.color),
                        const SizedBox(height: 10),
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom image section - fills remaining space and positions image at bottom
          SliverFillRemaining(
            hasScrollBody: false, // Prevents extra nested scrolling
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                color: Theme.of(context).appColors.textPrimary,
                'assets/images/place_holder.png', // Replace with your image path (add to pubspec.yaml)
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "wifi",
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.wifi);
            },
            child: const Icon(Icons.wifi_find),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: "location",
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.location);
            },
            child: const Icon(Icons.location_on_rounded),
          ),
        ],
      ),
    );
  }
}
