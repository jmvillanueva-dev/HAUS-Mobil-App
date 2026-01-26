class PaymentBreakdown {
  final double grossAmount;
  final double platformFee;
  final double netAmount;

  PaymentBreakdown({
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
  });
}

class CalculatePaymentBreakdown {
  static const double _feePercentage = 0.05; // 5%

  PaymentBreakdown call(double grossAmount) {
    if (grossAmount < 0) {
      throw ArgumentError('Gross amount cannot be negative');
    }

    final platformFee = grossAmount * _feePercentage;
    final netAmount = grossAmount - platformFee;

    return PaymentBreakdown(
      grossAmount: grossAmount,
      platformFee: platformFee,
      netAmount: netAmount,
    );
  }
}
