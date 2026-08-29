import 'package:bbtml_new/blocs/login/login_bloc.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../blocs/login/login_event.dart';
import '../common/api_status.dart';
import '../common/common_state.dart';
import '../widgets/common_snackbar.dart';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key, required this.mobile, required this.countryCode});
  final int mobile;
  final int countryCode;
  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _controller = TextEditingController();
  final LoginBloc _verifyOtpBloc = LoginBloc();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final radius = screenSize.height * 0.1;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 100,
                      color: Theme.of(context).appColors.primary,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                      width: 8, color: Theme.of(context).appColors.redButton),
                ),
                child: Container(
                  height: radius,
                  width: radius,
                  decoration: BoxDecoration(
                    color: Theme.of(context).appColors.background,
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: Image.asset(
                      "assets/images/BBT_Logo_2.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenSize.height * 0.15),
            Text("Verify OTP",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).appColors.textSecondary)),
            SizedBox(height: screenWidth * 0.1),
            Form(
              key: _formKey,
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                enablePinAutofill: false,
                errorTextSpace: 20,
                showCursor: true,
                cursorColor: Theme.of(context).appColors.primary,
                hintCharacter: '-',
                textStyle:
                    TextStyle(color: Theme.of(context).appColors.textSecondary),
                controller: _controller,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'OTP is required';
                  }
                  final RegExp regex = RegExp(r'^\d{6}$'); // exactly 6 digits
                  if (!regex.hasMatch(value.trim())) {
                    return 'Enter a valid 6-digit OTP';
                  }
                  return null; // valid
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  activeFillColor: Theme.of(context).appColors.background,
                  inactiveFillColor: Theme.of(context).appColors.background,
                  selectedFillColor: Theme.of(context).appColors.background,
                  errorBorderColor: Theme.of(context).appColors.redButton,
                  activeColor: Theme.of(context).appColors.primary,
                  inactiveColor: Theme.of(context).appColors.textSecondary,
                  selectedColor: Theme.of(context).appColors.primary,
                  borderWidth: 2,
                ),
              ),
            ),
            SizedBox(
              height: screenWidth * 0.04,
            ),
            SizedBox(
                width: screenWidth * 0.5,
                child: BlocListener<LoginBloc, CommonState>(
                  bloc: _verifyOtpBloc,
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TabsPage()),
                          (route) => false,
                        );
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _verifyOtpBloc.add(VerifyOtpEvent(
                              mobile: widget.mobile,
                              countryCode: widget.countryCode,
                              otp: int.parse(_controller.text)));
                        }
                      },
                      child: const Text("Verify")),
                )),
            SizedBox(
              height: screenWidth * 0.04,
            ),
            TextButton(onPressed: () {}, child: const Text("Resend OTP")),
          ],
        ),
      ),
    );
  }
}
