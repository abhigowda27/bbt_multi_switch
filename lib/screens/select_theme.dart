enum AppThemeMode {
  light,
  dark,
  system,
}

String appThemeModeToString(AppThemeMode mode) => mode.name;

AppThemeMode stringToAppThemeMode(String value) {
  return AppThemeMode.values.firstWhere(
    (e) => e.name == value,
    orElse: () => AppThemeMode.system,
  );
}
