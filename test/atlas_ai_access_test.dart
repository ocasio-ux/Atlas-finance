import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/core/access/atlas_ai_access.dart';

void main() {
  test('AI access is available only when the gateway grants it', () {
    const access = AtlasAiAccess(
      status: AtlasAiAccessStatus.available,
      codeId: 'code-1',
    );

    expect(access.canUse, isTrue);
    expect(access.codeId, 'code-1');
  });

  test('disabled gateway never grants AI access', () async {
    const gateway = DisabledAtlasAiAccessGateway();

    final access = await gateway.getAccess();
    final redeemed = await gateway.redeemCode('ATLAS-TEST-CODE');

    expect(access.canUse, isFalse);
    expect(redeemed.canUse, isFalse);
    expect(access.status, AtlasAiAccessStatus.unavailable);
  });

  test('expired access is not considered usable', () {
    final access = AtlasAiAccess(
      status: AtlasAiAccessStatus.expired,
      expiresAt: DateTime(2026, 1, 1),
    );

    expect(access.canUse, isFalse);
    expect(access.isExpired, isTrue);
  });
}
