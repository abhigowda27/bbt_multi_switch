import 'dart:convert';
import 'dart:io';

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/router_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

final StorageController _storageController = StorageController();

Future<void> _exportRouters() async {
  final routers = await _storageController.readRouters();

  if (routers.isEmpty) {
    showFlutterToast("No routers to export");
    return;
  }

  final backup = {
    "type": "router_backup",
    "version": 1,
    "data": routers.map((e) => e.toJson()).toList(),
  };

  final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

  final file = File(
      '/storage/emulated/0/Download/router_backup_${DateTime.now().millisecondsSinceEpoch}.json');

  await file.writeAsString(jsonString, flush: true);
  showFlutterToast("Backup saved to:\n${file.path}");
}

Future<void> _pickAndImportRouters(VoidCallback onImported) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result.isEmpty) {
    return;
  }

  final path = result.single.path;

  if (path == null) {
    showFlutterToast("Unable to read selected file");
    return;
  }

  try {
    final file = File(path);
    final jsonString = await file.readAsString();

    await _importRouters(jsonString, onImported);
  } catch (e) {
    showFlutterToast("Failed to read backup file");
  }
}

Future<void> _importRouters(String jsonString, VoidCallback onImported) async {
  try {
    final Map<String, dynamic> backup = jsonDecode(jsonString);

    if (backup["type"] != "router_backup") {
      showFlutterToast(
        "This is not a router backup file.",
      );
      return;
    }

    final List<dynamic> data = backup["data"];

    final importedRouters = data.map((e) => RouterDetails.fromJson(e)).toList();

    await _storageController.mergeRouters(importedRouters);

    onImported();
    showFlutterToast("Routers imported successfully");
  } catch (e) {
    showFlutterToast("Invalid backup file");
  }
}

void _showImportDialog(VoidCallback onImported) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: const Text("Import Routers"),
      content: const Text(
        "Select a router backup (.json) file. Existing routers will be merged with the imported data.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).appColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            Navigator.pop(context);
            await _pickAndImportRouters(onImported);
          },
          child: const Text("Select File"),
        ),
      ],
    ),
  );
}

void showBackupOptions({required VoidCallback onImported}) {
  showModalBottomSheet(
    context: navigatorKey.currentContext!,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Export Routers'),
            onTap: () {
              Navigator.pop(context);
              _exportRouters();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Import Routers'),
            onTap: () {
              Navigator.pop(context);
              _showImportDialog(onImported);
            },
          ),
        ],
      ),
    ),
  );
}
