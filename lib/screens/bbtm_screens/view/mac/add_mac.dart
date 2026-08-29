import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/widgets/mandatory_text.dart';
import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../controllers/apis.dart';
import '../../../../widgets/text_field.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/mac_model.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';

class NewMacInstallationPage extends StatefulWidget {
  const NewMacInstallationPage({required this.switchDetails, super.key});
  final SwitchDetails switchDetails;

  @override
  State<NewMacInstallationPage> createState() => _NewMacInstallationPageState();
}

class _NewMacInstallationPageState extends State<NewMacInstallationPage> {
  final TextEditingController _macID = TextEditingController();
  final TextEditingController _macName = TextEditingController();
  final StorageController _storageController = StorageController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Add Mac")),
        body: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  richTxt(text: 'Mac ID'),
                  CustomTextField(
                    controller: _macID,
                    maxLength: 12,
                    validator: (value) {
                      if (value!.isEmpty) return "Mac ID cannot be empty";
                      return null;
                    },
                    hintText: "Mac ID",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  richTxt(text: 'Mac Name'),

                  CustomTextField(
                    controller: _macName,
                    validator: (value) {
                      if (value!.isEmpty) return "Mac Name cannot be empty";
                      return null;
                    },
                    hintText: "Mac Name",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: "Submit",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        MacsDetails macsDetails = MacsDetails(
                            switchDetails: widget.switchDetails,
                            id: _macID.text,
                            name: _macName.text,
                            isPresentInESP: true);
                        _storageController.addMacs(macsDetails);
                        var isExist = await _storageController.isMacIDExists(
                            _macID.text, widget.switchDetails.switchSSID);
                        debugPrint("$isExist");
                        debugPrint("<<<<<<<<");
                        if (isExist) {
                          await ApiConnect.hitApiGet(
                            "${Constants.routerIP}/",
                          );
                          await ApiConnect.hitApiPost(
                              "${Constants.routerIP}/macid", {
                            "MacID": _macID.text.toLowerCase(),
                          });
                        }
                        Navigator.push(
                            navigatorKey
                                .currentContext!,
                            MaterialPageRoute(
                                builder: (context) => const TabsPage()));
                      }
                    },
                  ),
                  // CustomButton(
                  //     width: 200,
                  //     onPressed: () async {
                  //       if (formKey.currentState!.validate()) {
                  //         await ApiConnect.hitApiGet(
                  //           routerIP + "/",
                  //         );
                  //         var res = await ApiConnect.hitApiPost(
                  //             "$routerIP/deletemac", {
                  //           "MacID": _macID.text.toLowerCase(),
                  //         });
                  //       }
                  //     },
                  //     text: "Delete"),
                ],
              ),
            ),
          ),
        ));
  }
}
