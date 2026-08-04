/// Provider-agnostic authentication primitives for Atlas.
///
/// Firebase/Google adapters can implement [AtlasAuthGateway] later without
/// leaking SDK-specific types into the rest of the app or requiring secrets
/// in source control.
enum AtlasAuthProvider { google }

class AtlasUserSession {
  const AtlasUserSession({
    required this.userId,
    required this.provider,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  final String userId;
  final AtlasAuthProvider provider;
  final String? displayName;
  final String? email;
  final String? photoUrl;
}

abstract interface class AtlasAuthGateway {
  AtlasUserSession? get currentSession;

  Future<AtlasUserSession> signInWithGoogle();

  Future<void> signOut();
}

/// Used while cloud authentication has not been configured on the device.
/// Local-first Atlas features remain available and no credential is stored.
class UnconfiguredAuthGateway implements AtlasAuthGateway {
  const UnconfiguredAuthGateway();

  @override
  AtlasUserSession? get currentSession => null;

  @override
  Future<AtlasUserSession> signInWithGoogle() {
    throw const AtlasAuthNotConfiguredException();
  }

  @override
  Future<void> signOut() async {}
}

class AtlasAuthNotConfiguredException implements Exception {
  const AtlasAuthNotConfiguredException();

  @override
  String toString() => 'Atlas cloud authentication is not configured.';
}
