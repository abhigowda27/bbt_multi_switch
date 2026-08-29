class Constants {
  static const String routerIP = "http://192.168.6.6";
  static const String apiEndPoint = "https://api.belbirdtechnologies.co.in";

  // STAGING BBTM
  // static const String apiEndPoint = "https://devapi.belbirdtechnologies.co.in";

  // static const Color whiteColour = Color(0xFFFFFFFF);
  // static const Color blackColour = Color(0xFF000000);
  // static const Color backGroundColour = Color(0xff5788f8);
  // static const Color greyColor = Color(0xff878788);
  //
  // static const Color backGroundColourDark = Color(0x0ffee6e4);
  // static const Color appBarColour = Color(0xff2896ef);
  // static Color redColour = Colors.red.shade200;
  // static Color redButtonColour = Colors.red.shade500;
  // static Color greenColour = Colors.green.shade500;
  // static Color greenButtonColour = Colors.green;

  String applianceIconAsset(String code) {
    switch (code) {
      case 'LIGHT':
        return 'assets/images/appliance/light.png';
      case 'FAN':
        return 'assets/images/appliance/fan.png';
      case 'AC':
        return 'assets/images/appliance/ac.png';
      case 'TV':
        return 'assets/images/appliance/tv.png';
      case 'FRIDGE':
        return 'assets/images/appliance/fridge.png';
      case 'WM':
        return 'assets/images/appliance/washing_machine.png';
      case 'MW':
        return 'assets/images/appliance/microwave.png';
      case 'GEYSER':
        return 'assets/images/appliance/geyser.png';
      case 'DOOR_LOCK':
        return 'assets/images/appliance/smart-door.png';
      default:
        return 'assets/images/switch.png';
    }
  }
}
