/// Access boundary for Atlas AI beta and future commercial plans.
///
/// The Flutter client must never generate or validate real invitation codes
/// locally. Production validation belongs to a trusted backend.
///
/// This contract lets the app prepare the beta experience now while keeping
/// code generation, redemption, revocation and usage limits server-authorized.
enum AtlasAiAccessStatus {
  unavailable,
  available,
  expired,
  revoked,
}

class AtlasAiAccess {
  const AtlasAiAccess({
    required this.status,
    this.expiresAt,
    this.codeId,
  });

  final AtlasAiAccessStatus status;
  final DateTime? expiresAt;
  final String? codeId;

  bool get canUse => status == AtlasAiAccessStatus.available;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Backend contract for Atlas AI access.
///
/// A production implementation should:
/// - authenticate the current user;
/// - validate invitation codes server-side;
/// - bind a redeemed code to one user;
/// - enforce expiration/revocation/use limits;
/// - never return the raw invitation code after redemption;
/// - keep code generation in an admin/trusted environment.
abstract interface class AtlasAiAccessGateway {
  Future<AtlasAiAccess> getAccess();

  Future<AtlasAiAccess> redeemCode(String code);
}

/// Safe default while the Atlas AI backend is not configured.
class DisabledAtlasAiAccessGateway implements AtlasAiAccessGateway {
  const DisabledAtlasAiAccessGateway();

  @override
  Future<AtlasAiAccess> getAccess() async =>
      const AtlasAiAccess(status: AtlasAiAccessStatus.unavailable);

  @override
  Future<AtlasAiAccess> redeemCode(String code) async =>
      const AtlasAiAccess(status: AtlasAiAccessStatus.unavailable);
}
