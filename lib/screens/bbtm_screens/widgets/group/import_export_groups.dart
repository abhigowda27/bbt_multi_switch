import 'dart:convert';
import 'dart:io';

import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbtml_new/screens/bbtm_screens/models/group_model.dart';
import 'package:bbtml_new/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

final StorageController _storageController = StorageController();

Future<void> _exportGroups() async {
  final groups = await _storageController.readAllGroups();

  if (groups.isEmpty) {
    showFlutterToast("No groups to export");
    return;
  }

  final backup = {
    "type": "group_backup",
    "version": 1,
    "data": groups.map((e) => e.toJson()).toList(),
  };

  final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

  final file = File(
      '/storage/emulated/0/Download/group_backup_${DateTime.now().millisecondsSinceEpoch}.json');

  await file.writeAsString(jsonString, flush: true);
  showFlutterToast("Backup saved to:\n${file.path}");
}

Future<void> _pickAndImportGroups(VoidCallback onImported) async {
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

    await _importGroups(jsonString, onImported);
  } catch (e) {
    showFlutterToast("Failed to read backup file");
  }
}

Future<void> _importGroups(String jsonString, VoidCallback onImported) async {
  try {
    final Map<String, dynamic> backup = jsonDecode(jsonString);

    if (backup["type"] != "group_backup") {
      showFlutterToast(
        "This is not a group backup file.",
      );
      return;
    }

    final List<dynamic> data = backup["data"];

    final importedGroups = data.map((e) => GroupDetails.fromJson(e)).toList();

    await _storageController.mergeGroups(importedGroups);

    onImported();
    showFlutterToast("Groups imported successfully");
  } catch (e) {
    showFlutterToast("Invalid backup file");
  }
}

void _showImportDialog(VoidCallback onImported) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (context) => AlertDialog(
      title: const Text("Import Groups"),
      content: const Text(
        "Select a group backup (.json) file. Existing groups will be merged with the imported data.",
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
            await _pickAndImportGroups(onImported);
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
            title: const Text('Export Groups'),
            onTap: () {
              Navigator.pop(context);
              _exportGroups();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Import Groups'),
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
