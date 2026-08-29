import 'package:bbtml_new/main.dart';
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
  final TextEditingController _controller = TextEditingController();
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
              PinCodeTextField(
                autoDisposeControllers: false,
                appContext: context,
                length: 4,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                enableActiveFill: false,
                autoFocus: true,
                enablePinAutofill: false,
                errorTextSpace: 0,
                showCursor: true,
                cursorColor: const Color(0xFF4B39EF),
                obscureText: false,
                hintCharacter: '-',
                controller: _controller,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
