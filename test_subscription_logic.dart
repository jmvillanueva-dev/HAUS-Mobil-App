import 'lib/features/auth/domain/entities/subscription_plan.dart';
import 'lib/features/auth/domain/usecases/get_feature_access.dart';

void main() {
  print('--- Testing Subscription Domain Logic ---');

  final getAccess = GetFeatureAccess();

  // 1. Test Free Plan
  print('\n[1] Testing Free Plan:');
  final freeTier = SubscriptionTier.free;

  bool canInvoiceFree =
      getAccess(tier: freeTier, featureId: 'generate_invoice');
  print('Free can generate invoice: $canInvoiceFree (Expected: false)');

  bool canCreate2ContractsFree =
      getAccess(tier: freeTier, featureId: 'create_contract', context: 1);
  print(
      'Free can create 2nd contract (current=1): $canCreate2ContractsFree (Expected: false, max is 1)');

  // 2. Test Pro Plan
  print('\n[2] Testing Pro Plan:');
  final proTier = SubscriptionTier.pro;

  bool canInvoicePro = getAccess(tier: proTier, featureId: 'generate_invoice');
  print('Pro can generate invoice: $canInvoicePro (Expected: true)');

  bool canCreate2ContractsPro =
      getAccess(tier: proTier, featureId: 'create_contract', context: 1);
  print(
      'Pro can create 2nd contract (current=1): $canCreate2ContractsPro (Expected: true, max is 5)');

  bool canCreate6ContractsPro =
      getAccess(tier: proTier, featureId: 'create_contract', context: 5);
  print(
      'Pro can create 6th contract (current=5): $canCreate6ContractsPro (Expected: false, max is 5)');

  // 3. Test Business Plan
  print('\n[3] Testing Business Plan:');
  final businessTier = SubscriptionTier.business;

  bool canCreate100ContractsBusiness =
      getAccess(tier: businessTier, featureId: 'create_contract', context: 100);
  print(
      'Business can create 101st contract: $canCreate100ContractsBusiness (Expected: true)');

  if (!canInvoiceFree &&
      canInvoicePro &&
      !canCreate2ContractsFree &&
      canCreate2ContractsPro) {
    print('\n✅ All Logic Checks Passed');
  } else {
    print('\n❌ Some Logic Checks Failed');
  }
}
