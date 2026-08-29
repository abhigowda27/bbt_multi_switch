import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/text_field.dart';
import 'package:flutter/material.dart';

import '../controllers/storage.dart';
import 'custom/toast.dart';

class PinDialog {
  final BuildContext context;
  final StorageController _storageController = StorageController();

  PinDialog(this.context);

  Future<void> showPinDialog({
    required bool isFirstTime,
    required Function onSuccess,
  }) async {
    TextEditingController pinController = TextEditingController();
    TextEditingController confirmPinController = TextEditingController();
    TextEditingController oldPinController = TextEditingController();

    bool isResettingPin = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: isFirstTime
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Set QR PIN'),
                        SizedBox(height: 4), // Adjust the spacing as needed
                        Text(
                          'You Need to Remember this PIN for Generating QR code for switches',
                          style: TextStyle(fontSize: 12), // Smaller text size
                        ),
                      ],
                    )
                  : Text(
                      isResettingPin ? 'Reset QR PIN' : 'Enter QR PIN',
                      style:
                          TextStyle(color: Theme.of(context).appColors.primary),
                    ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isResettingPin) ...[
                      CustomTextField(
                        controller: oldPinController,
                        hintText: 'Enter Old PIN',
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),
                      const SizedBox(height: 8),
                    ],
                    CustomTextField(
                      controller: pinController,
                      hintText: isResettingPin ? 'Enter New PIN' : 'Enter PIN',
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                    ),
                    if (isResettingPin) ...[
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: confirmPinController,
                        hintText: 'Confirm New PIN',
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                if (!isFirstTime)
                  TextButton(
                    child: Text(
                      'Reset PIN',
                      style:
                          TextStyle(color: Theme.of(context).appColors.primary),
                    ),
                    onPressed: () {
                      setState(() {
                        isResettingPin = true;
                      });
                    },
                  ),
                TextButton(
                  child: Text(
                    'Cancel',
                    style:
                        TextStyle(color: Theme.of(context).appColors.primary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Submit',
                    style:
                        TextStyle(color: Theme.of(context).appColors.primary),
                  ),
                  onPressed: () async {
                    if (pinController.text.length != 4 ||
                        (isResettingPin &&
                            confirmPinController.text.length != 4)) {
                      showToast(context, 'PIN must be 4 digits.');
                      return;
                    }

                    if (isResettingPin) {
                      final storedPin = await _storageController.getQrPin();
                      if (storedPin != oldPinController.text) {
                        showToast(navigatorKey.currentContext!,
                            'Old PIN is incorrect. Please try again.');
                        return;
                      }
                      if (pinController.text != confirmPinController.text) {
                        showToast(navigatorKey.currentContext!,
                            'New PINs do not match. Please try again.');
                        return;
                      }
                      await _storageController.setQrPin(pinController.text);
                      showToast(navigatorKey.currentContext!,
                          'PIN has been reset successfully.');
                    } else {
                      if (isFirstTime) {
                        await _storageController.setQrPin(pinController.text);
                      } else {
                        final storedPin = await _storageController.getQrPin();
                        if (storedPin != pinController.text) {
                          showToast(navigatorKey.currentContext!,
                              'Invalid PIN. Please try again.');
                          return;
                        }
                      }
                    }
                    Navigator.of(
                      navigatorKey.currentContext!,
                    ).pop();
                    onSuccess();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
