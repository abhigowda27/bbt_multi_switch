import 'package:bbtml_new/main.dart';
import 'package:flutter/material.dart';

class CommonServices {
  // Show Loading Dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3), // dimmed background
      builder: (BuildContext context) {
        return const PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero, // remove default padding
            child: SizedBox.expand(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
  }

  String formatWatt(int watt) {
    if (watt >= 1000) {
      double kw = watt / 1000;
      if (kw % 1 == 0) {
        return "${kw.toInt()}kW";
      } else {
        return "${kw.toStringAsFixed(1)}kW";
      }
    } else {
      return "${watt}W";
    }
  }

  // Hide Loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Show No Data Widget
  static Widget noDataWidget() {
    return Center(
      child: Image.asset("assets/images/no_data_found.png"),
    );
  }

  // Show Failure Widget
  static Widget failureWidget(final VoidCallback? onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/something_went_wrong.png"),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry"))
        ],
      ),
    );
  }

  static Widget apiFailureWidget({
    String text = "Something went Wrong",
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        spacing: 20,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(navigatorKey.currentContext!)
                .textTheme
                .headlineLarge!
                .copyWith(color: Colors.redAccent),
          ),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  // Optional: Show a snack bar for errors
  static void showSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
