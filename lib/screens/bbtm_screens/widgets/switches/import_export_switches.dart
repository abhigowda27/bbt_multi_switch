import 'dart:convert';
import 'dart:io';

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/switch_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

final StorageController _storageController = StorageController();

Future<void> _exportSwitches() async {
  final switches = await _storageController.readSwitches();

  if (switches.isEmpty) {
    showFlutterToast("No switches to export");
    return;
  }
  final backup = {
    "type": "switch_backup",
    "version": 1,
    "data": switches.map((e) => e.toJson()).toList(),
  };

  final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
  final file = File(
      '/storage/emulated/0/Download/switch_backup_${DateTime.now().millisecondsSinceEpoch}.json');

  await file.writeAsString(jsonString, flush: true);
  showFlutterToast("Backup saved to:\n${file.path}");
}

Future<void> _pickAndImportSwitches(VoidCallback onImported) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result == null) {
    return;
  }

  final path = result.files.single.path;

  if (path == null) {
    showFlutterToast("Unable to read selected file");
    return;
  }

  try {
    final file = File(path);
    final jsonString = await file.readAsString();

    await _importSwitches(jsonString, onImported);
  } catch (e) {
    showFlutterToast("Failed to read backup file");
  }
}

Future<void> _importSwitches(String jsonString, VoidCallback onImported) async {
  try {
    final Map<String, dynamic> backup = jsonDecode(jsonString);

    if (backup["type"] != "switch_backup") {
      showFlutterToast("This is not a switch backup file.");
      return;
    }

    final List<dynamic> data = backup["data"] ?? [];

    final importedSwitches =
        data.map((e) => SwitchDetails.fromJson(e)).toList();

    await _storageController.mergeSwitches(importedSwitches);

    onImported();
    showFlutterToast("Switches imported successfully");
  } catch (e) {
    showFlutterToast("Invalid backup file");
  }
}

void _showImportDialog(VoidCallback onImported) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: const Text("Import Switches"),
      content: const Text(
        "Select a router backup (.json) file. Existing switches will be merged with the imported data.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _pickAndImportSwitches(onImported);
          },
          child: const Text("Select File"),
        ),
      ],
    ),
  );
}

void showBackupOptions({required VoidCallback onImported}) {
  showModalBottomSheet(
    backgroundColor:
        Theme.of(navigatorKey.currentContext!).appColors.background,
    context: navigatorKey.currentContext!,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Export Switches'),
            onTap: () {
              Navigator.pop(context);
              _exportSwitches();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Import Switches'),
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
