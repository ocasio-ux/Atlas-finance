/// Backend boundary for Atlas.
///
/// The app currently remains local-first. Implementations must never embed
/// production credentials in the Flutter client.
abstract interface class AtlasBackend {
  Future<AtlasSession?> restoreSession();
  Future<void> signOut();
}

class AtlasSession {
  const AtlasSession({required this.userId, required this.expiresAt});

  final String userId;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Safe boundary for a future Open Finance provider.
///
/// OAuth/client secrets and token exchange belong on a trusted backend, never
/// in the mobile app. Until that backend exists, Atlas uses the disabled/mock
/// implementation below.
abstract interface class OpenFinanceGateway {
  Future<List<OpenFinanceAccountSnapshot>> accounts();
}

class OpenFinanceAccountSnapshot {
  const OpenFinanceAccountSnapshot({
    required this.externalId,
    required this.displayName,
    required this.balance,
  });

  final String externalId;
  final String displayName;
  final double balance;
}

class DisabledOpenFinanceGateway implements OpenFinanceGateway {
  const DisabledOpenFinanceGateway();

  @override
  Future<List<OpenFinanceAccountSnapshot>> accounts() async => const [];
}

class LocalBackendPlaceholder implements AtlasBackend {
  const LocalBackendPlaceholder();

  @override
  Future<AtlasSession?> restoreSession() async => null;

  @override
  Future<void> signOut() async {}
}
