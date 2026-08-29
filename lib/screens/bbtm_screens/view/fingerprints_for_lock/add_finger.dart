import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/widgets/mandatory_text.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../controllers/apis.dart';
import '../../../../widgets/text_field.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';

class NewFingerInstallationPage extends StatefulWidget {
  const NewFingerInstallationPage({required this.switchDetails, super.key});
  final SwitchDetails switchDetails;

  @override
  State<NewFingerInstallationPage> createState() =>
      _NewFingerInstallationPageState();
}

class _NewFingerInstallationPageState extends State<NewFingerInstallationPage> {
  final TextEditingController _fingerprintName = TextEditingController();
  final StorageController _storageController = StorageController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    debugPrint("${widget.switchDetails.toJson()}");
    return Scaffold(
        appBar: AppBar(title: const Text("Add Fingerprint")),
        body: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  richTxt(text: 'FingerPrint Name'),
                  CustomTextField(
                    controller: _fingerprintName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "FingerPrint Name cannot be empty";
                      }
                      return null;
                    },
                    hintText: "FingerPrint Name",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: "Submit",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await ApiConnect.hitApiGet(
                          "${Constants.routerIP}/",
                        );
                        await ApiConnect.hitApiPost(
                            "${Constants.routerIP}/Fingerenroll", {
                          "FingerID": _fingerprintName.text.toLowerCase(),
                        });
                        await _storageController.addFingerPrint(
                            _fingerprintName.text, widget.switchDetails);
                        Navigator.push(
                            navigatorKey.currentContext!,
                            MaterialPageRoute(
                                builder: (context) => const TabsPage()));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
