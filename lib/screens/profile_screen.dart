import 'package:bbtml_new/api_providers/theme_provider.dart';
import 'package:bbtml_new/blocs/login/login_bloc.dart';
import 'package:bbtml_new/blocs/login/login_event.dart';
import 'package:bbtml_new/common/api_status.dart';
import 'package:bbtml_new/common/common_state.dart';
import 'package:bbtml_new/controllers/shared_preference.dart';
import 'package:bbtml_new/screens/account_register.dart';
import 'package:bbtml_new/screens/select_theme.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:bbtml_new/widgets/common_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LoginBloc _logoutBloc = LoginBloc();
  void navigateToHome() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
        (route) => false,
      );
    }
  }

  bool isLoading = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final appColors = Theme.of(context).appColors;

        return AlertDialog(
          backgroundColor: appColors.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.only(top: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          actionsPadding:
              const EdgeInsets.only(bottom: 16, right: 12, left: 12),
          title: Column(
            children: [
              Image.asset(
                "assets/images/logout.gif",
                height: 100,
                width: 100,
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: appColors.grey,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: appColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            BlocListener<LoginBloc, CommonState>(
              bloc: _logoutBloc,
              listener: (context, state) {
                final apiResponse = state.apiStatus;
                if (apiResponse is ApiResponse) {
                  setState(() {
                    isLoading = false;
                  });
                  final responseData = apiResponse.response;
                  debugPrint("Response data====>$responseData");
                  if (responseData != null &&
                      responseData["status"] == "success") {
                    showSnackBar(context, "User Logged out successfully!");
                    SharedPreferenceServices().saveLoggedInStatus(false);
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
                onPressed: () {
                  _logoutBloc.add(UserLogOutEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.redButton,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Theme.of(context).appColors.background,
            leading: Icon(Icons.color_lens_rounded,
                color: Theme.of(context).appColors.primary),
            title: Text(
              'Theme',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).appColors.textSecondary,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).appColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: Theme.of(context).appColors.grey
                    .withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            onTap: () => _showThemeDialog(context),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Theme.of(context).appColors.background,
            leading: Icon(Icons.logout_rounded,
                color: Theme.of(context).appColors.redButton),
            title: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).appColors.textSecondary,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).appColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: Theme.of(context).appColors.grey
                    .withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            onTap: _showLogoutDialog,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    final provider = context.read<ThemeProvider>();
    AppThemeMode selectedMode = provider.appThemeMode;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: appColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Theme",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...AppThemeMode.values.map((mode) {
                final isSelected = selectedMode == mode;
                IconData icon;
                switch (mode) {
                  case AppThemeMode.system:
                    icon = Icons.settings;
                    break;
                  case AppThemeMode.light:
                    icon = Icons.light_mode;
                    break;
                  case AppThemeMode.dark:
                    icon = Icons.dark_mode;
                    break;
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(context);
                    provider.setTheme(mode);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? appColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? appColors.primary : appColors.grey
                          .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon,
                            color: isSelected
                                ? appColors.primary
                                : appColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            mode.name[0].toUpperCase() + mode.name.substring(1),
                            style: TextStyle(
                              color: isSelected
                                  ? appColors.primary
                                  : appColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: appColors.primary, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
