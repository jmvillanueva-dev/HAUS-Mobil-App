import 'package:equatable/equatable.dart';

class RentContract extends Equatable {
  final String id;
  final String listingId;
  final String hostId;
  final String roomieId;
  final double monthlyRent;
  final int paymentDay;
  final String status; // 'active', 'terminated'
  final bool isPaymentEnabled;

  const RentContract({
    required this.id,
    required this.listingId,
    required this.hostId,
    required this.roomieId,
    required this.monthlyRent,
    required this.paymentDay,
    required this.status,
    this.isPaymentEnabled = false,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        hostId,
        roomieId,
        monthlyRent,
        paymentDay,
        status,
        isPaymentEnabled,
      ];

  factory RentContract.fromJson(Map<String, dynamic> json) {
    return RentContract(
      id: json['id'],
      listingId: json['listing_id'],
      hostId: json['host_id'],
      roomieId: json['roomie_id'],
      monthlyRent: (json['monthly_rent'] as num).toDouble(),
      paymentDay: json['payment_day'],
      status: json['status'],
    );
  }
}
