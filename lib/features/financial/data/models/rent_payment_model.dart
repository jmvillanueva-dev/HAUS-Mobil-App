import '../../domain/entities/rent_payment.dart';

class RentPaymentModel extends RentPayment {
  RentPaymentModel({
    required super.id,
    required super.contractId,
    required super.dueDate,
    required super.status,
    required super.grossAmount,
    required super.platformFee,
    required super.netAmount,
  });

  factory RentPaymentModel.fromJson(Map<String, dynamic> json) {
    return RentPaymentModel(
      id: json['id'],
      contractId: json['contract_id'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      grossAmount: (json['gross_amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_id': contractId,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'gross_amount': grossAmount,
      'platform_fee': platformFee,
      'net_amount': netAmount,
    };
  }
}
