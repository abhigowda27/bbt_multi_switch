import 'dart:async';

import 'package:bbtml_new/controllers/shared_preference.dart';
import 'package:bbtml_new/screens/account_register.dart';
import 'package:bbtml_new/screens/tabs_page.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    getLoginDetails();
  }

  Future<void> getLoginDetails() async {
    isLoggedIn = SharedPreferenceServices().getLoggedInStatus();
    if (isLoggedIn != null) {
      if (isLoggedIn == false) {
        Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          ),
        );
      } else {
        Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TabsPage()),
          ),
        );
      }
    } else {
      Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final double radius = height * 0.2;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).appColors.primary,
              Theme.of(context).appColors.red,
              Theme.of(context).appColors.primary,
            ],
            stops: const [0, 0.5, 1],
            begin: const AlignmentDirectional(-1, -1),
            end: const AlignmentDirectional(1, 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 100,
                        color: Theme.of(context).appColors.primary,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    shape: BoxShape.circle,
                    border: Border.all(
                        width: 10,
                        color: Theme.of(context).appColors.redButton),
                  ),
                  child: Container(
                    height: radius,
                    width: radius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).appColors.background,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/BBT_Logo_2.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'BelBird Technologies',
                    style: TextStyle(
                      color: Theme.of(context).appColors.background,
                      fontSize: height * .04,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    children: [
                      Text(
                        'Transforming Technologies for tomorrow',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: height * .02,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
