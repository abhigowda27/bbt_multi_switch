import 'package:bbtml_new/blocs/login/login_bloc.dart';
import 'package:bbtml_new/blocs/login/login_event.dart';
import 'package:bbtml_new/screens/verify_otp_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/api_status.dart';
import '../common/common_state.dart';
import '../widgets/common_snackbar.dart';
import '../widgets/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoginBloc _sendOtpBloc = LoginBloc();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final radius = screenSize.height * 0.1;
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text("Register"),
        // ),
        body: Form(
          key: _formKey,
          child: Padding(
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
                          width: 8,
                          color: Theme.of(context).appColors.redButton),
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
                Text("Login",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).appColors.textSecondary)),
                SizedBox(height: screenWidth * 0.1),

                // richTxt(text: 'Name'),
                // SizedBox(height: screenWidth * 0.03),
                // CustomTextField(
                //   hintText: "Enter name",
                //   controller: nameController,
                // ),
                // SizedBox(height: screenWidth * 0.04),
                // richTxt(text: 'Mobile Number'),
                // SizedBox(height: screenWidth * 0.03),
                CustomTextField(
                  hintText: "Enter Mobile Number",
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mobile number is required';
                    }

                    final RegExp regex = RegExp(r'^\d{10}$');

                    if (!regex.hasMatch(value.trim())) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                // SizedBox(height: screenWidth * 0.04),
                // richTxt(text: 'Password'),
                // SizedBox(height: screenWidth * 0.03),
                // CustomTextField(
                //   obscureText: true,
                //   hintText: "Enter password",
                //   controller: passwordController,
                // ),
                SizedBox(height: screenWidth * 0.04),
                SizedBox(
                    width: screenWidth * 0.5,
                    child: BlocListener<LoginBloc, CommonState>(
                      bloc: _sendOtpBloc,
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OTPPage(
                                        mobile: int.parse(phoneController.text),
                                        countryCode: 91,
                                      )),
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
                          final messageMatch = RegExp(r'message:\s*([^}]+)')
                              .firstMatch(exception);
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
                              _sendOtpBloc.add(SendOtpEvent(
                                  mobile: int.parse(phoneController.text),
                                  countryCode: 91));
                            }
                          },
                          child: !isLoading
                              ? const Text("Login")
                              : const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: Center(
                                    key: Key('login_center_001'),
                                    child: CircularProgressIndicator(
                                      key: Key('login_progress_indicator_001'),
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )),
                    )),
                SizedBox(height: screenWidth * 0.05),
                // Text(
                //   "Already have an account? ",
                //   style: TextStyle(
                //     color: Theme.of(context).appColors.textPrimary,
                //     fontSize: 16,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                // SizedBox(height: screenWidth * 0.02),
                // InkWell(
                //   onTap: () {
                //     Navigator.pushAndRemoveUntil(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const LoginPage()),
                //         (route) => false);
                //   },
                //   child: Text(
                //     "Login",
                //     style: TextStyle(
                //       color: Theme.of(context).appColors.primary,
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
