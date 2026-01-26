import '../entities/rent_contract.dart';
import '../entities/rent_payment.dart';

abstract class FinancialRepository {
  Future<List<RentContract>> getContracts();
  Future<List<RentPayment>> fetchPaymentsByContract(String contractId);
  Stream<List<RentPayment>> subscribeToPayments(String contractId);
  Future<RentPayment> upsertPayment(RentPayment payment);
}
