import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/core/access/atlas_feature.dart';
import 'package:atlas_finance/core/backend/atlas_backend.dart';

void main() {
  test('keeps core finance and Open Finance capabilities free', () {
    expect(
      AtlasFeatureAccess.canUse(
        AtlasPlan.free,
        AtlasFeature.manualTransactions,
      ),
      isTrue,
    );
    expect(
      AtlasFeatureAccess.canUse(AtlasPlan.free, AtlasFeature.openFinance),
      isTrue,
    );
    expect(
      AtlasFeatureAccess.canUse(AtlasPlan.free, AtlasFeature.basicForecast),
      isTrue,
    );
    expect(
      AtlasFeatureAccess.canUse(AtlasPlan.free, AtlasFeature.atlasAiAssistant),
      isFalse,
    );
  });

  test('premium unlocks active intelligence without changing free features', () {
    expect(
      AtlasFeatureAccess.canUse(
        AtlasPlan.premium,
        AtlasFeature.atlasAiAssistant,
      ),
      isTrue,
    );
    expect(
      AtlasFeatureAccess.isPremiumOnly(AtlasFeature.advancedForecast),
      isTrue,
    );
    expect(
      AtlasFeatureAccess.isPremiumOnly(AtlasFeature.openFinance),
      isFalse,
    );
  });

  test('safe Open Finance boundary returns no production data by default', () async {
    const gateway = DisabledOpenFinanceGateway();

    expect(await gateway.accounts(), isEmpty);
  });

  test('local backend placeholder does not create a session', () async {
    const backend = LocalBackendPlaceholder();

    expect(await backend.restoreSession(), isNull);
    await backend.signOut();
  });
}
