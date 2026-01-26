import '../entities/subscription_plan.dart';

class GetFeatureAccess {
  bool call({
    required SubscriptionTier tier,
    required String featureId,
    dynamic
        context, // Optional context for limits (e.g. current contract count)
  }) {
    final plan = _getPlanFromTier(tier);

    switch (featureId) {
      case 'generate_invoice':
        return plan.canGenerateInvoices;
      case 'view_analytics':
        return plan.canViewAnalytics;
      case 'receive_payments':
        return plan.isPaymentEnabled;
      case 'create_contract':
        if (context is int) {
          return context < plan.maxContracts;
        }
        return true; // If no context provided, assume allowed (or handle differently)
      default:
        return false;
    }
  }

  SubscriptionPlan _getPlanFromTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.pro:
        return SubscriptionPlan.pro();
      case SubscriptionTier.business:
        return SubscriptionPlan.business();
      case SubscriptionTier.free:
        return SubscriptionPlan.free();
    }
  }
}
