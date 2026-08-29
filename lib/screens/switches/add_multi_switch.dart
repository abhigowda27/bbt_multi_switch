import 'package:bbtml_new/blocs/switch/switch_bloc.dart';
import 'package:bbtml_new/blocs/switch/switch_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:bbtml_new/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMultiSwitch extends StatefulWidget {
  const AddMultiSwitch({super.key});

  @override
  State<AddMultiSwitch> createState() => _AddMultiSwitchState();
}

class _AddMultiSwitchState extends State<AddMultiSwitch> {
  final TextEditingController _switchId = TextEditingController();
  final TextEditingController _ssid = TextEditingController();
  final SwitchBloc _addSwitchBloc = SwitchBloc();

  final formKey = GlobalKey<FormState>();
  String? _addFan = "No";
  final TextEditingController _fanNameController = TextEditingController();
  String? _selectedSwitchType;
  String? selectedFan;
  final List<String> _switchesWithFan = [
    'Switch 1',
    'Switch 2',
    'Switch 3',
    'Switch 4',
  ];

  final List<String> _switchesWithoutFan = [
    'Switch 1',
    'Switch 2',
    'Switch 3',
    'Switch 4',
    'Switch 5',
  ];

  List<String> _availableSwitchTypes = [];
  bool isLoading = false;
  List<Map<String, TextEditingController>> selectedSwitches = [];

  @override
  void initState() {
    super.initState();
    _updateAvailableSwitchTypes();
  }

  void _updateAvailableSwitchTypes() {
    setState(() {
      _availableSwitchTypes = _addFan == "Yes"
          ? List.from(_switchesWithFan)
          : List.from(_switchesWithoutFan);
      selectedSwitches.clear(); // reset selections if fan option changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _switchId,
                    validator: (value) {
                      if (value!.isEmpty) return "Switch ID cannot be empty";
                      return null;
                    },
                    hintText: "SwitchID",
                  ),
                  SizedBox(height: height * 0.03),
                  CustomTextField(
                    controller: _ssid,
                    validator: (value) {
                      if (value!.isEmpty) return "SSID cannot be empty";
                      return null;
                    },
                    hintText: "New Switch Name",
                  ),
                  SizedBox(height: height * 0.03),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: DropdownButtonFormField<String>(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: _selectedSwitchType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSwitchType = newValue;
                            });
                          },
                          validator: (value) {
                            if ((_addFan == "No") && selectedSwitches.isEmpty) {
                              return "Please select a switch type";
                            }
                            return null;
                          },
                          items: _availableSwitchTypes.map((switchType) {
                            return DropdownMenuItem<String>(
                              value: switchType,
                              child: Text(switchType),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            hintText:
                                "Select Switches and Rename Them if Needed",
                            hintStyle: TextStyle(
                              color: Theme.of(context).appColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Theme.of(context).appColors.grey,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Theme.of(context).appColors.redButton,
                                width: 1,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
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
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: () {
                            if (_selectedSwitchType != null) {
                              setState(() {
                                selectedSwitches.add({
                                  'name': TextEditingController(
                                      text: _selectedSwitchType),
                                });
                                _availableSwitchTypes
                                    .remove(_selectedSwitchType);
                                _selectedSwitchType = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (selectedSwitches.isNotEmpty) ...[
                    Column(
                      children: selectedSwitches.map((switchMap) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: switchMap['name']!,
                                  hintText: "Rename Switch",
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    _availableSwitchTypes
                                        .add(switchMap['name']!.text);
                                    selectedSwitches.remove(switchMap);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: height * 0.03),
                  const Text(
                    "Do you want to add a fan?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text("Yes"),
                          leading: Radio<String>(
                            value: "Yes",
                            groupValue: _addFan,
                            onChanged: (value) {
                              setState(() {
                                _addFan = value;
                                _updateAvailableSwitchTypes();
                                _fanNameController.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text("No"),
                          leading: Radio<String>(
                            value: "No",
                            groupValue: _addFan,
                            onChanged: (value) {
                              setState(() {
                                _addFan = value;
                                _fanNameController.clear();
                                _updateAvailableSwitchTypes();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_addFan == "Yes") ...[
                    CustomTextField(
                      controller: _fanNameController,
                      validator: (value) {
                        if (_addFan == "Yes" &&
                            (value == null || value.isEmpty)) {
                          return "Fan name cannot be empty";
                        }
                        return null;
                      },
                      hintText: "Fan Name",
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).appColors.background,
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
              if (responseData != null && responseData["status"] == "success") {
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
              String errorMessage = 'Something went wrong! Please try again';
              final messageMatch =
                  RegExp(r'message:\s*([^}]+)').firstMatch(exception);
              if (messageMatch != null) {
                errorMessage = messageMatch.group(1)?.trim() ?? errorMessage;
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
                    // Build the switches list
                    List<Map<String, dynamic>> switchesPayload = [];

                    // Add selected switches
                    for (int i = 0; i < selectedSwitches.length; i++) {
                      final switchMap = selectedSwitches[i];
                      switchesPayload.add({
                        "type": 1, // 1 = switch
                        "name": switchMap['name']!.text,
                        "order": i + 1, // index starting from 1
                      });
                    }

                    // Add fan if selected
                    if (_addFan == "Yes") {
                      switchesPayload.add({
                        "type": 2, // 2 = fan
                        "name": _fanNameController.text,
                        // "id": "" // optional
                      });
                    }
                    // Final payload
                    final payload = {
                      "deviceName": _ssid.text,
                      "deviceType": 3,
                      "deviceId": _switchId.text,
                      "switches": switchesPayload
                    };

                    _addSwitchBloc.add(AddSwitchEvent(payload: payload));
                  } catch (e) {
                    debugPrint("Error ${e.toString()}");
                  }
                }
              }
            },
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
