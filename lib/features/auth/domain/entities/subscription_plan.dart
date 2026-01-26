enum SubscriptionTier {
  free,
  pro,
  business,
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final String name;
  final double price;
  final int maxContracts;
  final bool canGenerateInvoices;
  final bool canViewAnalytics;
  final bool isPaymentEnabled;

  const SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.price,
    required this.maxContracts,
    required this.canGenerateInvoices,
    required this.canViewAnalytics,
    required this.isPaymentEnabled,
  });

  factory SubscriptionPlan.free() {
    return const SubscriptionPlan(
      tier: SubscriptionTier.free,
      name: 'Free',
      price: 0.0,
      maxContracts: 1,
      canGenerateInvoices: false,
      canViewAnalytics: false,
      isPaymentEnabled: false,
    );
  }

  factory SubscriptionPlan.pro() {
    return const SubscriptionPlan(
      tier: SubscriptionTier.pro,
      name: 'Pro',
      price: 9.99,
      maxContracts: 5,
      canGenerateInvoices: true,
      canViewAnalytics: true,
      isPaymentEnabled: true,
    );
  }

  factory SubscriptionPlan.business() {
    return const SubscriptionPlan(
      tier: SubscriptionTier.business,
      name: 'Business',
      price: 29.99,
      maxContracts: 999, // Unlimited
      canGenerateInvoices: true,
      canViewAnalytics: true,
      isPaymentEnabled: true,
    );
  }

  factory SubscriptionPlan.fromTier(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'pro':
        return SubscriptionPlan.pro();
      case 'business':
        return SubscriptionPlan.business();
      case 'free':
      default:
        return SubscriptionPlan.free();
    }
  }
}
