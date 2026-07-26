import 'package:local_auth/local_auth.dart';

/// Uses the operating system authentication prompt.
/// Atlas never receives or stores fingerprints, face templates, PINs or patterns.
class LocalAuthService {
  LocalAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Desbloqueie o Atlas para acessar seus dados financeiros.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }

  Future<void> cancel() => _auth.stopAuthentication();
}
