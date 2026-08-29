// import 'dart:async';
//
// import 'package:bbt_new/models/switch_model.dart';
// import 'package:bbt_new/view/home_page.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../constants.dart';
// import '../../controllers/apis.dart';
// import '../../controllers/wifi.dart';
// import '../../widgets/custom/custom_appbar.dart';
// import '../../widgets/custom/toast.dart';
//
// class FanSwitchCard extends StatefulWidget {
//   final SwitchDetails switchDetails;
//
//   const FanSwitchCard({
//     required this.switchDetails,
//     super.key,
//   });
//
//   @override
//   State<FanSwitchCard> createState() => _FanSwitchCardState();
// }
//
// class _FanSwitchCardState extends State<FanSwitchCard> {
//   late Timer _timer;
//   late String selectedControl = "OFF";
//   final Duration _timerDuration = const Duration(seconds: 30);
//   List<String> controls = [
//     "OFF",
//     "HIGH",
//     "LOW",
//     "MEDIUM",
//   ];
//   late NetworkService _networkService;
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _networkService = NetworkService();
//     _startTimer();
//     _initNetworkInfo();
//     connectivitySubscription = _connectivity.onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       _updateConnectionStatus(results);
//     });
//   }
//
//   @override
//   void dispose() {
//     connectivitySubscription?.cancel();
//     _timer.cancel();
//     super.dispose();
//   }
//
//   void _startTimer() {
//     _timer = Timer(_timerDuration, _navigateToNextPage);
//   }
//
//   void _resetTimer() {
//     _startTimer();
//     _timer.cancel();
//   }
//
//   String _connectionStatus = 'Unknown';
//   Future<void> _updateConnectionStatus(
//           List<ConnectivityResult> results) async =>
//       _initNetworkInfo();
//
//   Future<void> _initNetworkInfo() async {
//     String? wifiName = await _networkService.initNetworkInfo();
//     setState(() => _connectionStatus = wifiName ?? "Unknown");
//   }
//
//   void _navigateToNextPage() {
//     if (mounted) {
//       Navigator.pushAndRemoveUntil<dynamic>(
//         context,
//         MaterialPageRoute<dynamic>(
//           builder: (BuildContext context) => const TabsPage(),
//         ),
//         (route) => false,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final width = screenSize.width;
//
//     return GestureDetector(
//       onTap: _resetTimer,
//       child: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: appBarColour,
//           onPressed: updateSwitch,
//           child: const Icon(Icons.refresh_rounded),
//         ),
//         appBar: const PreferredSize(
//           preferredSize: Size.fromHeight(60),
//           child: CustomAppBar(heading: "Fan Control"),
//         ),
//         body: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               const SizedBox(
//                 height: 30,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 20.0, horizontal: 16.0),
//                   decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade400,
//                         spreadRadius: 5,
//                         blurRadius: 7,
//                         offset: const Offset(5, 5),
//                       ),
//                     ],
//                     color: appBarColour,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "${widget.switchDetails.switchSSID}_${widget.switchDetails.selectedFan}",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: width * 0.05,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Icon(
//                         Icons.wind_power_outlined,
//                         size: width * 0.1,
//                         color: Colors.white,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 250,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
