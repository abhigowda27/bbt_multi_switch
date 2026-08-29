import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkService {
  // 🔹 Singleton Pattern
  static final NetworkService _instance = NetworkService._internal();

  factory NetworkService() => _instance;

  NetworkService._internal();

  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();

  /// Global reactive variable for UI binding
  final ValueNotifier<String?> wifiNameNotifier = ValueNotifier("unknown");

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// 🔹 Cache last valid SSID
  String? _lastValidSsid;

  /// 🔹 Periodic monitor
  Timer? _wifiMonitorTimer;

  /// Prevent multiple simultaneous updates
  bool _isUpdating = false;

  /// Initialize service (call once in main.dart)
  Future<void> init() async {
    await _updateWifiName();

    /// Connectivity listener
    _subscription ??= _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        debugPrint(
          "Connectivity changed: $results",
        );

        // Small delay is important
        await Future.delayed(
          const Duration(seconds: 1),
        );

        await _updateWifiName();
      },
    );

    /// Periodic polling
    _wifiMonitorTimer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        await _updateWifiName();
      },
    );
  }

  /// 🔹 Fetch WiFi name with retry
  Future<String?> _getWifiNameWithRetry() async {
    for (int i = 0; i < 5; i++) {
      try {
        // Android sometimes needs delay
        await Future.delayed(
          const Duration(milliseconds: 300),
        );

        final wifi = await _networkInfo.getWifiName();

        final cleaned = wifi?.replaceAll('"', '').trim();

        debugPrint(
          "Fetched SSID Attempt $i : $cleaned",
        );

        if (cleaned != null &&
            cleaned.isNotEmpty &&
            cleaned.toLowerCase() != "<unknown ssid>" &&
            cleaned.toLowerCase() != "unknown") {
          return cleaned;
        }
      } catch (e) {
        developer.log(
          "Retry SSID fetch failed",
          error: e,
        );

        debugPrint(
          "Retry SSID fetch failed $e",
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 500),
      );
    }

    return null;
  }

  /// 🔹 Main logic to update WiFi name
  Future<void> _updateWifiName() async {
    if (_isUpdating) return;

    _isUpdating = true;

    try {
      /// 1️⃣ Check connectivity
      final results = await _connectivity.checkConnectivity();

      final isWifi = results.contains(ConnectivityResult.wifi);

      debugPrint(
        "Connectivity Results: $results",
      );

      /// Retry once before clearing SSID
      if (!isWifi) {
        debugPrint(
          "WiFi temporarily unavailable",
        );

        await Future.delayed(
          const Duration(seconds: 2),
        );

        final retryResults = await _connectivity.checkConnectivity();

        final retryWifi = retryResults.contains(
          ConnectivityResult.wifi,
        );

        if (!retryWifi) {
          debugPrint(
            "WiFi actually disconnected",
          );

          _lastValidSsid = null;

          _updateNotifier("unknown");

          return;
        }
      }

      /// 2️⃣ Check permissions
      final granted = await _requestPermissions();

      if (!granted) {
        developer.log(
          'SSID access denied: '
          'Location permission not granted.',
        );

        if (_lastValidSsid != null) {
          _updateNotifier(_lastValidSsid);
        } else {
          _updateNotifier("unknown");
        }

        return;
      }

      /// 3️⃣ Check Location Service
      final locationEnabled = await Permission.location.serviceStatus.isEnabled;

      if (!locationEnabled) {
        debugPrint(
          "Location service disabled",
        );

        if (_lastValidSsid != null) {
          _updateNotifier(_lastValidSsid);
        } else {
          _updateNotifier("unknown");
        }

        return;
      }

      /// 4️⃣ Fetch SSID
      final wifiName = await _getWifiNameWithRetry();

      if (wifiName != null) {
        /// SSID changed
        if (_lastValidSsid != wifiName) {
          debugPrint(
            "SSID Changed: "
            "$_lastValidSsid -> $wifiName",
          );
        }

        _lastValidSsid = wifiName;

        _updateNotifier(wifiName);
      } else {
        /// Temporary failure
        debugPrint(
          "SSID fetch failed, "
          "keeping cached SSID",
        );

        if (_lastValidSsid != null) {
          _updateNotifier(_lastValidSsid);
        } else {
          _updateNotifier("unknown");
        }
      }
    } on PlatformException catch (e) {
      developer.log(
        'Failed to get Wifi Name',
        error: e,
      );

      debugPrint(
        "PlatformException: $e",
      );

      if (_lastValidSsid != null) {
        _updateNotifier(_lastValidSsid);
      } else {
        _updateNotifier("unknown");
      }
    } catch (e) {
      developer.log(
        'Unexpected error while fetching SSID',
        error: e,
      );

      debugPrint(
        "Unexpected error: $e",
      );

      if (_lastValidSsid != null) {
        _updateNotifier(_lastValidSsid);
      } else {
        _updateNotifier("unknown");
      }
    } finally {
      _isUpdating = false;
    }
  }

  /// 🔹 Request permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isIOS) {
      final status = await Permission.locationWhenInUse.request();

      return status.isGranted;
    }

    if (Platform.isAndroid) {
      final status = await Permission.location.request();

      return status.isGranted;
    }

    return true;
  }

  /// 🔹 Update notifier safely
  void _updateNotifier(String? newValue) {
    final value = newValue ?? "unknown";

    /// Keep cached SSID during temporary failures
    if (value == "unknown" && _lastValidSsid != null) {
      if (wifiNameNotifier.value != _lastValidSsid) {
        wifiNameNotifier.value = _lastValidSsid!;

        debugPrint(
          "Keeping cached SSID: "
          "$_lastValidSsid",
        );
      }

      return;
    }

    /// Update only if changed
    if (wifiNameNotifier.value != value) {
      wifiNameNotifier.value = value;

      debugPrint(
        "NetworkService: "
        "SSID Updated -> $value",
      );
    }
  }

  /// 🔹 Get current WiFi name
  String get wifiName => wifiNameNotifier.value ?? "unknown";

  /// 🔹 Manual refresh
  Future<void> refreshWifi() async {
    await _updateWifiName();
  }

  /// 🔹 Dispose
  void dispose() {
    _subscription?.cancel();
    _subscription = null;

    _wifiMonitorTimer?.cancel();
    _wifiMonitorTimer = null;

    wifiNameNotifier.dispose();
  }
}
