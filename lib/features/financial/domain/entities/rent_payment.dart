class RentPayment {
  final String id;
  final String contractId;
  final DateTime dueDate;
  final String status; // 'pending', 'paid', 'overdue'
  final double grossAmount;
  final double platformFee;
  final double netAmount;

  RentPayment({
    required this.id,
    required this.contractId,
    required this.dueDate,
    required this.status,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
  });

  factory RentPayment.fromJson(Map<String, dynamic> json) {
    return RentPayment(
      id: json['id'],
      contractId: json['contract_id'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      grossAmount: (json['gross_amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }

  RentPayment copyWith({
    String? id,
    String? contractId,
    DateTime? dueDate,
    String? status,
    double? grossAmount,
    double? platformFee,
    double? netAmount,
  }) {
    return RentPayment(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      grossAmount: grossAmount ?? this.grossAmount,
      platformFee: platformFee ?? this.platformFee,
      netAmount: netAmount ?? this.netAmount,
    );
  }
}
