import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool isSupported = await _auth.isDeviceSupported();

      if (!isSupported) {
        debugPrint('Local authentication is not supported.');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Authenticate to generate the QR code',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      debugPrint(
        'Local authentication failed: ${e.code}',
      );

      return false;
    } catch (e) {
      debugPrint(
        'Local authentication error: $e',
      );

      return false;
    }
  }
}
