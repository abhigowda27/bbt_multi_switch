import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';

class FactoryReset extends StatefulWidget {
  const FactoryReset(
      {required this.switchDetails, required this.currentSwitch, super.key});
  final String currentSwitch;
  final SwitchDetails switchDetails;
  @override
  State<FactoryReset> createState() => _FactoryResetState();
}

class _FactoryResetState extends State<FactoryReset> {
  final PinInputController _controller = PinInputController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pin Code'),
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                'Enter Your Pin',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'This code helps keep your account safe and secure.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              MaterialPinField(
                length: 4,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                autoFocus: true,
                obscureText: false,
                hintCharacter: '-',
                theme: MaterialPinTheme(
                  elevation: 5,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  shape: MaterialPinShape.outlined,
                  cellSize: const Size(56, 64),
                  borderRadius: BorderRadius.circular(8),
                  focusedFillColor: Theme.of(context).appColors.background,
                  filledFillColor: Theme.of(context).appColors.background,
                  fillColor: Theme.of(context).appColors.background,
                  errorBorderColor: Theme.of(context).appColors.redButton,
                  focusedBorderColor: Theme.of(context).appColors.primary,
                  borderColor: Theme.of(context).appColors.textSecondary,
                  hintCharacter: '-',
                ),
                pinController: _controller,
              ),
              CustomButton(
                text: "Confirm",
                onPressed: () async {
                  if (_controller.text == widget.switchDetails.privatePin) {
                    try {
                      await ApiConnect.hitApiPost(
                          "${widget.switchDetails.iPAddress}/Factoryreset", {
                        "USER_DEVID": widget.switchDetails.switchId,
                        "USER_PASSKEY": widget.switchDetails.switchPassKey
                      });
                      _storageController.deleteEverythingWithRespectToSwitchID(
                          widget.switchDetails);
                    } catch (e) {
                      debugPrint(e.toString());
                    } finally {
                      Navigator.pushAndRemoveUntil(
                        navigatorKey.currentContext!,
                        MaterialPageRoute(
                            builder: (context) => const TabsPage()),
                        (route) => false,
                      );
                    }
                  } else {
                    final scaffold = ScaffoldMessenger.of(context);
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text("Incorrect Pin"),
                      ),
                    );
                    _controller.text = "";
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("You are connected to : ${widget.currentSwitch}"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
