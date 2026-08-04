import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePreferences {
  SecurePreferences({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _appLockKey = 'atlas_app_lock_enabled';

  Future<bool> isAppLockEnabled() async {
    return await _storage.read(key: _appLockKey) == 'true';
  }

  Future<void> setAppLockEnabled(bool enabled) {
    return _storage.write(key: _appLockKey, value: enabled.toString());
  }

  /// Call on sign-out so account-scoped secrets/preferences do not leak
  /// into the next session on a shared device.
  Future<void> clearOnSignOut() => _storage.deleteAll();
}
