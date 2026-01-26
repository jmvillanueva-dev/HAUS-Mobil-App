import '../entities/rent_payment.dart';

class ProcessSimulatedPayment {
  Future<RentPayment> call(RentPayment payment) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (payment.status == 'paid') {
      throw Exception('Payment is already paid');
    }

    // In a real scenario, this would call a repository to update the database
    // For simulation, we just return a new object with status 'paid'
    return payment.copyWith(status: 'paid');
  }
}
