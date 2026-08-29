// import 'dart:async';
//
// import 'package:bbtml_new/screens/bbtm_screens/controllers/wifi.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// mixin WifiStatusMixin<T extends StatefulWidget> on State<T>
//     implements WidgetsBindingObserver {
//   final Connectivity connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
//
//   late NetworkService networkService;
//   String connectionStatus = "Unknown";
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addObserver(this);
//
//     networkService = NetworkService();
//     initNetworkInfo();
//
//     connectivitySubscription = connectivity.onConnectivityChanged.listen((_) {
//       initNetworkInfo();
//     });
//   }
//
//   Future<void> initNetworkInfo() async {
//     try {
//       String? wifiName = await networkService.initNetworkInfo();
//       final newStatus = wifiName ?? "Unknown";
//
//       if (!mounted || newStatus == connectionStatus) return;
//
//       setState(() {
//         connectionStatus = newStatus;
//       });
//     } catch (e) {
//       debugPrint("WiFi fetch error: $e");
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       initNetworkInfo();
//     }
//   }
//
//   @override
//   void dispose() {
//     connectivitySubscription?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
//
//   /// ✅ Utility
//   bool isSameWifi(String a, String b) {
//     return a.replaceAll('"', '').trim().toLowerCase() ==
//         b.replaceAll('"', '').trim().toLowerCase();
//   }
// }
