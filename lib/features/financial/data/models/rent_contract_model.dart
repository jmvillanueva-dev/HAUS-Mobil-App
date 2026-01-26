import '../../domain/entities/rent_contract.dart';

import '../../../auth/domain/entities/subscription_plan.dart';
import '../../../auth/domain/usecases/get_feature_access.dart';

class RentContractModel extends RentContract {
  RentContractModel({
    required super.id,
    required super.listingId,
    required super.hostId,
    required super.roomieId,
    required super.monthlyRent,
    required super.paymentDay,
    required super.status,
    super.isPaymentEnabled,
  });

  factory RentContractModel.fromJson(Map<String, dynamic> json) {
    // Check if we have joined profile data for the host
    bool isPaymentEnabled = false;

    if (json['profiles'] != null) {
      final hostProfile = json['profiles'];
      // Handle both single object (if joined with !inner or single) or list
      final profileData = hostProfile is List
          ? (hostProfile.isNotEmpty ? hostProfile.first : null)
          : hostProfile;

      if (profileData != null) {
        final tierName = profileData['subscription_tier'] as String? ?? 'free';
        final tier = SubscriptionPlan.fromTier(tierName).tier;

        // Use the centralized logic
        isPaymentEnabled = GetFeatureAccess()(
          tier: tier,
          featureId: 'receive_payments',
        );
      }
    }

    return RentContractModel(
      id: json['id'],
      listingId: json['listing_id'],
      hostId: json['host_id'],
      roomieId: json['roomie_id'],
      monthlyRent: (json['monthly_rent'] as num).toDouble(),
      paymentDay: json['payment_day'],
      status: json['status'],
      isPaymentEnabled: isPaymentEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'host_id': hostId,
      'roomie_id': roomieId,
      'monthly_rent': monthlyRent,
      'payment_day': paymentDay,
      'status': status,
    };
  }
}
