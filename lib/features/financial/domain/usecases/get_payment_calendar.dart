import '../entities/rent_contract.dart';
import '../entities/rent_payment.dart';
import 'calculate_payment_breakdown.dart';

class GetPaymentCalendar {
  final CalculatePaymentBreakdown _calculateBreakdown;

  GetPaymentCalendar(this._calculateBreakdown);

  List<RentPayment> call(RentContract contract) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final breakdown = _calculateBreakdown(contract.monthlyRent);

    List<RentPayment> calendar = [];

    // Generate payments for the rest of the year (including current month)
    for (int month = currentMonth; month <= 12; month++) {
      // Create a date for the payment day of this month
      // Handle edge cases where paymentDay > days in month (e.g. Feb 30)
      final daysInMonth = DateTime(currentYear, month + 1, 0).day;
      final day =
          contract.paymentDay > daysInMonth ? daysInMonth : contract.paymentDay;
      final dueDate = DateTime(currentYear, month, day);

      // Determine status based on due date
      String status = 'pending';
      if (dueDate.isBefore(now) && !isSameDay(dueDate, now)) {
        status = 'overdue';
      }

      calendar.add(RentPayment(
        id: 'simulated_${month}_${currentYear}', // Temporary ID for simulation
        contractId: contract.id,
        dueDate: dueDate,
        status: status,
        grossAmount: breakdown.grossAmount,
        platformFee: breakdown.platformFee,
        netAmount: breakdown.netAmount,
      ));
    }

    return calendar;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
