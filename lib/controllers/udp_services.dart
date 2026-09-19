import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class UDPService {
  RawDatagramSocket? _socket;
  StreamSubscription? _subscription;

  /// Bind to a local port to start listening for UDP datagrams
  Future<void> startListening({int port = 8888}) async {
    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        port,
      );

      _socket!.broadcastEnabled = true;

      debugPrint(
        'UDP Listener running on '
        '${_socket!.address.address}:${_socket!.port}',
      );

      _subscription = _socket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final Datagram? dg = _socket!.receive();

            if (dg != null) {
              final String message = utf8.decode(dg.data);

              debugPrint(
                'Received UDP packet from '
                '${dg.address.address}:${dg.port}',
              );

              debugPrint(
                'Message: $message',
              );
            }
          }
        },
      );
    } catch (e) {
      debugPrint(
        'Error starting UDP listener: $e',
      );
    }
  }

  void sendMessage(dynamic message, String targetIp, int targetPort) {
    if (_socket == null) {
      debugPrint(
        'Socket not initialized. Call startListening first or initialize socket.',
      );
      return;
    }

    final String payload = message is String ? message : jsonEncode(message);

    final List<int> data = utf8.encode(payload);
    final InternetAddress destination = InternetAddress(targetIp);

    final int bytesSent = _socket!.send(
      data,
      destination,
      targetPort,
    );

    debugPrint('Sent $bytesSent bytes to $targetIp:$targetPort');
    debugPrint('Payload: $payload');
  }

  /// Broadcast a UDP message across the local network
  void sendBroadcastMessage(String message, int targetPort) {
    if (_socket == null) return;

    // Enable broadcast mode on the socket
    _socket!.broadcastEnabled = true;

    List<int> data = utf8.encode(message);
    InternetAddress broadcastAddress = InternetAddress('255.255.255.255');

    int bytesSent = _socket!.send(data, broadcastAddress, targetPort);
    debugPrint('Broadcast $bytesSent bytes to port $targetPort');
  }

  /// Close socket and cancel subscriptions
  void dispose() {
    _subscription?.cancel();
    _socket?.close();
    debugPrint('UDP socket closed.');
  }
}

class SmartDevice {
  final String id;
  final String ip;
  final String type;

  SmartDevice({required this.id, required this.ip, required this.type});
}

class Esp32MultiDiscovery {
  static const int udpPort = 8888;
  static const String broadcastAddress = "255.255.255.255";
  static const Duration timeoutDuration = Duration(seconds: 2);

  Future<List<SmartDevice>> discoverAllDevices() async {
    List<SmartDevice> foundDevices = [];
    RawDatagramSocket? socket;

    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;

      // Send the single PING to wake up all devices on port 8888
      List<int> payload = utf8.encode("PING");
      socket.send(payload, InternetAddress(broadcastAddress), udpPort);

      final stopwatch = Stopwatch()..start();

      while (stopwatch.elapsed < timeoutDuration) {
        Datagram? packet = socket.receive();

        if (packet != null) {
          String rawJsonString = utf8.decode(packet.data).trim();
          String senderIP = 'http://${packet.address.address}';
          // String senderIP = 'http://192.168.1.100';
          debugPrint("Raw JSON String: $rawJsonString");
          debugPrint("address ${packet.address.type}");
          try {
            Map<String, dynamic> jsonObject = jsonDecode(rawJsonString);
            String deviceId = jsonObject['id'] ?? "";
            String deviceType = jsonObject['type'] ?? "";

            // Check if we already added this specific device ID to prevent duplicates
            bool alreadyExists =
                foundDevices.any((device) => device.id == deviceId);

            if (deviceId.isNotEmpty && !alreadyExists) {
              foundDevices.add(
                  SmartDevice(id: deviceId, ip: senderIP, type: deviceType));
              debugPrint("Found Device! ID: $deviceId at IP: $senderIP");
            }
          } catch (e) {
            // Ignore malformed packets from other devices
          }
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      debugPrint("Discovery Socket Error: $e");
    } finally {
      socket?.close();
    }

    return foundDevices; // Returns a clean list of all discovered unique locks/switches
  }
}
