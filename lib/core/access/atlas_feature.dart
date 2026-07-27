enum AtlasPlan { free, premium }

enum AtlasFeature {
  manualTransactions,
  accountsAndCards,
  historyAndFilters,
  recurringTransactions,
  installments,
  budgets,
  goals,
  openFinance,
  basicForecast,
  basicInsights,
  atlasAiAssistant,
  proactiveInsights,
  advancedForecast,
  smartAlerts,
  unlimitedReceiptOcr,
  advancedPriceComparison,
}

class AtlasFeatureAccess {
  const AtlasFeatureAccess._();

  static const Set<AtlasFeature> freeFeatures = {
    AtlasFeature.manualTransactions,
    AtlasFeature.accountsAndCards,
    AtlasFeature.historyAndFilters,
    AtlasFeature.recurringTransactions,
    AtlasFeature.installments,
    AtlasFeature.budgets,
    AtlasFeature.goals,
    AtlasFeature.openFinance,
    AtlasFeature.basicForecast,
    AtlasFeature.basicInsights,
  };

  static const Set<AtlasFeature> premiumFeatures = {
    ...freeFeatures,
    AtlasFeature.atlasAiAssistant,
    AtlasFeature.proactiveInsights,
    AtlasFeature.advancedForecast,
    AtlasFeature.smartAlerts,
    AtlasFeature.unlimitedReceiptOcr,
    AtlasFeature.advancedPriceComparison,
  };

  static bool canUse(AtlasPlan plan, AtlasFeature feature) =>
      (plan == AtlasPlan.premium ? premiumFeatures : freeFeatures).contains(feature);

  static bool isPremiumOnly(AtlasFeature feature) =>
      !freeFeatures.contains(feature) && premiumFeatures.contains(feature);
}
