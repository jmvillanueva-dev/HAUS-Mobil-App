import '../entities/rent_payment.dart';

class CalculateMonthlyEarnings {
  double call(List<RentPayment> payments) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return payments
        .where((payment) =>
            payment.status == 'paid' &&
            payment.dueDate.month == currentMonth &&
            payment.dueDate.year == currentYear)
        .fold(0.0, (sum, payment) => sum + payment.netAmount);
  }
}
