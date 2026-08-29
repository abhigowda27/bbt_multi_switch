import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission(Permission permission) async {
  final status = await permission.request();
  debugPrint("$status");

  // setState(() {
  //   _permissionStatus = status;
  //   debugPrint(_permissionStatus);
  // });
}
