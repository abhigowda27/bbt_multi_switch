// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:bbt_multi_switch/common/api_status.dart';
// import 'package:bbt_multi_switch/screens/account_register.dart';
// import 'package:bbt_multi_switch/screens/tabs_page.dart';
// import 'package:bbt_multi_switch/theme/app_colors_extension.dart';
// import 'package:bbt_multi_switch/widgets/text_field.dart';
//
// import '../blocs/login/login_bloc.dart';
// import '../blocs/login/login_event.dart';
// import '../common/common_state.dart';
// import '../widgets/common_snackbar.dart';
// import '../widgets/mandatory_text.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final LoginBloc loginBloc = LoginBloc();
//
//   bool isLoading = false;
//   bool _isHidden = true;
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final screenWidth = screenSize.width;
//     final screenHeight = screenSize.height;
//     final double radius = screenHeight * 0.1;
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.05),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     margin: EdgeInsets.all(screenWidth * 0.05),
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           blurRadius: 100,
//                           color: Theme.of(context).appColors.primary,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                       borderRadius: BorderRadius.circular(radius),
//                       border: Border.all(
//                           width: 8,
//                           color: Theme.of(context).appColors.redButton),
//                     ),
//                     child: Container(
//                       height: radius,
//                       width: radius,
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).appColors.background,
//                         borderRadius: BorderRadius.circular(radius),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(radius),
//                         child: Image.asset(
//                           "assets/images/BBT_Logo_2.png",
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 richTxt(
//                   text: "Email ID",
//                 ),
//                 SizedBox(height: screenWidth * 0.03),
//                 CustomTextField(
//                   controller: usernameController,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.deny(RegExp(r'[<>{}$^%\[]')),
//                   ],
//                   hintText: 'Email ID',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Email is required';
//                     }
//                     final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 richTxt(
//                   text: "Password",
//                 ),
//                 SizedBox(height: screenWidth * 0.03),
//                 CustomTextField(
//                   hintText: 'Password',
//                   controller: passwordController,
//                   obscureText: _isHidden,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       !_isHidden
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                       color: Theme.of(context).appColors.grey,
//                     ),
//                     onPressed: _togglePasswordView,
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Password is required';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: screenWidth * 0.04),
//                 Center(
//                   child: Column(
//                     children: [
//                       Text(
//                         "Don't have an account? ",
//                         style: TextStyle(
//                           color: Theme.of(context).appColors.textPrimary,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: screenWidth * 0.02),
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const RegisterPage()),
//                           );
//                         },
//                         child: Text(
//                           "Register",
//                           style: TextStyle(
//                             color: Theme.of(context).appColors.buttonBackground,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Theme.of(context).appColors.backgroundDark,
//         child: BlocListener<LoginBloc, CommonState>(
//           bloc: loginBloc,
//           listener: (context, state) {
//             ApiStatus apiResponse = state.apiStatus;
//             if (apiResponse is ApiResponse) {
//               setState(() {
//                 isLoading = false;
//               });
//               final responseData = apiResponse.response;
//               debugPrint("Response data====>$responseData");
//               if (responseData != null && responseData["status"] == "success") {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const TabsPage()),
//                 );
//               }
//             } else if (apiResponse is ApiLoadingState) {
//               setState(() {
//                 isLoading = true;
//               });
//             } else if (apiResponse is ApiFailureState) {
//               setState(() {
//                 isLoading = false;
//               });
//               final exception = apiResponse.exception.toString();
//               debugPrint(exception);
//               String errorMessage = 'Something went wrong! Please try again';
//               final messageMatch =
//                   RegExp(r'message:\s*([^}]+)').firstMatch(exception);
//               if (messageMatch != null) {
//                 errorMessage = messageMatch.group(1)?.trim() ?? errorMessage;
//               }
//               showSnackBar(context, errorMessage);
//             }
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: ElevatedButton(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all(
//                     Theme.of(context).appColors.primary,
//                   ),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                 ),
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     final username = usernameController.text;
//                     final password = passwordController.text;
//                     loginBloc.add(
//                       UserLoginEvent(
//                         username: username,
//                         password: password,
//                       ),
//                     );
//                   }
//                 },
//                 child: !isLoading
//                     ? const Text("Login",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                         ))
//                     : const SizedBox(
//                         height: 25,
//                         width: 25,
//                         child: Center(
//                           key: Key('login_center_001'),
//                           child: CircularProgressIndicator(
//                             key: Key('login_progress_indicator_001'),
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         ),
//                       )),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _togglePasswordView() {
//     setState(() {
//       _isHidden = !_isHidden;
//     });
//   }
// }
