import 'package:bbtml_new/controllers/udp_services.dart';
import 'package:flutter/material.dart';

class UDPExampleScreen extends StatefulWidget {
  const UDPExampleScreen({super.key});

  @override
  State<UDPExampleScreen> createState() => _UDPExampleScreenState();
}

class _UDPExampleScreenState extends State<UDPExampleScreen> {
  final UDPService _udpService = UDPService();
  final TextEditingController _ipController =
      TextEditingController(text: '192.168.6.6');
  final TextEditingController _msgController =
      TextEditingController(text: 'Hello via UDP');

  @override
  void initState() {
    super.initState();
    // Start listening on port 8888
    _udpService.startListening(port: 8888);
  }

  @override
  void dispose() {
    _udpService.dispose();
    _ipController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter UDP Demo')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'Target IP'),
            ),
            TextField(
              controller: _msgController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _udpService.sendMessage(
                  _msgController.text,
                  _ipController.text,
                  8888, // Target port
                );
              },
              child: const Text('Send Direct Packet'),
            ),
            ElevatedButton(
              onPressed: () async {
                final devices =
                    await Esp32MultiDiscovery().discoverAllDevices();
                debugPrint(devices.toString());

                // _udpService.sendBroadcastMessage(_msgController.text, 8888);
              },
              child: const Text('Send Local Broadcast'),
            ),
          ],
        ),
      ),
    );
  }
}
