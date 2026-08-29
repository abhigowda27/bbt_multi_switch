import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:bbtml_new/widgets/mandatory_text.dart';
import 'package:bbtml_new/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSwitchPage extends StatefulWidget {
  const AddSwitchPage({super.key});

  @override
  State<AddSwitchPage> createState() => _AddSwitchPageState();
}

class _AddSwitchPageState extends State<AddSwitchPage> {
  final TextEditingController _switchId = TextEditingController();
  final TextEditingController _ssid = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final SwitchBloc _addSwitchBloc = SwitchBloc();
  bool isLoading = false;
  final List<Map<String, dynamic>> switchTypes = [
    {"name": "Switch", "type": 1},
    {"name": "Fan", "type": 2},
  ];

  int? selectedSwitchType;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;
    return SingleChildScrollView(
      child: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                richTxt(text: "Switch Type"),
                SizedBox(height: width * 0.03),
                DropdownButtonFormField<int>(
                  initialValue: selectedSwitchType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: "Select Type",
                    hintStyle: TextStyle(
                      color: Theme.of(context).appColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Theme.of(context).appColors.grey,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Theme.of(context).appColors.redButton,
                        width: 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Theme.of(context).appColors.redButton,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Theme.of(context).appColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).appColors.textSecondary,
                  ),
                  items: switchTypes
                      .map(
                        (type) => DropdownMenuItem<int>(
                          value: type["type"],
                          child: Text(type["name"]),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSwitchType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return "Please select a switch type";
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                richTxt(
                  text: "Switch ID",
                ),
                SizedBox(height: width * 0.03),
                CustomTextField(
                  controller: _switchId,
                  validator: (value) {
                    if (value!.isEmpty) return "Switch ID cannot be empty";
                    return null;
                  },
                  hintText: 'Switch ID',
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                richTxt(
                  text: "Switch Name",
                ),
                SizedBox(height: width * 0.03),
                CustomTextField(
                  controller: _ssid,
                  validator: (value) {
                    if (value!.isEmpty) return "SSID cannot be empty";
                    return null;
                  },
                  hintText: 'Switch ID',
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                SizedBox(
                  width: double.infinity,
                  child: BlocListener<SwitchBloc, CommonState>(
                    bloc: _addSwitchBloc,
                    listener: (context, state) {
                      ApiStatus apiResponse = state.apiStatus;
                      if (apiResponse is ApiResponse) {
                        setState(() {
                          isLoading = false;
                        });
                        final responseData = apiResponse.response;
                        debugPrint("Response data====>$responseData");
                        if (responseData != null &&
                            responseData["status"] == "success") {
                          navigateToHome();
                        }
                      } else if (apiResponse is ApiLoadingState) {
                        setState(() {
                          isLoading = true;
                        });
                      } else if (apiResponse is ApiFailureState) {
                        setState(() {
                          isLoading = false;
                        });
                        final exception = apiResponse.exception.toString();
                        debugPrint(exception);
                        String errorMessage =
                            'Something went wrong! Please try again';
                        final messageMatch =
                            RegExp(r'message:\s*([^}]+)').firstMatch(exception);
                        if (messageMatch != null) {
                          errorMessage =
                              messageMatch.group(1)?.trim() ?? errorMessage;
                        }
                        showSnackBar(context, errorMessage);
                      }
                    },
                    child: ElevatedButton(
                      child: isLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Text("Add"),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          {
                            try {
                              _addSwitchBloc.add(AddSwitchEvent(payload: {
                                "deviceName": _ssid.text,
                                "deviceType": selectedSwitchType,
                                "deviceId": _switchId.text
                              }));
                            } catch (e) {
                              debugPrint("Error ${e.toString()}");
                            }
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToHome() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TabsPage()),
        (route) => false,
      );
    }
  }
}
