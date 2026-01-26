import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/rent_contract.dart';
import '../../domain/entities/rent_payment.dart';
import '../../domain/repositories/financial_repository.dart';
import '../models/rent_contract_model.dart';
import '../models/rent_payment_model.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  final SupabaseClient _supabaseClient;
  final uuid = const Uuid();

  FinancialRepositoryImpl(this._supabaseClient);

  @override
  Future<List<RentContract>> getContracts() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // RLS policies on Supabase will automatically filter rows
      // We join with profiles to get the host's subscription tier
      // Note: We use !host_id to specify the foreign key relationship if needed,
      // or just profiles if it's unambiguous. Given we have host_id and roomie_id,
      // we need to be specific. Assuming foreign key is set up correctly.
      // Supabase syntax: table!foreign_key(columns)
      final response = await _supabaseClient
          .from('rent_contracts')
          .select('*, profiles!host_id(subscription_tier)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RentContractModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching contracts: $e');
    }
  }

  @override
  Future<List<RentPayment>> fetchPaymentsByContract(String contractId) async {
    try {
      // RLS Policy Check: Supabase ensures user is either host or roomie of this contract
      final response = await _supabaseClient
          .from('rent_payments')
          .select()
          .eq('contract_id', contractId)
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => RentPaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  @override
  Stream<List<RentPayment>> subscribeToPayments(String contractId) {
    return _supabaseClient
        .from('rent_payments')
        .stream(primaryKey: ['id'])
        .eq('contract_id', contractId)
        .order('due_date', ascending: true)
        .map((data) =>
            data.map((json) => RentPaymentModel.fromJson(json)).toList());
  }

  @override
  Future<RentPayment> upsertPayment(RentPayment payment) async {
    try {
      final model = RentPaymentModel(
        id: payment.id.startsWith('simulated_')
            ? uuid.v4() // Generate a real UUID for the DB
            : payment.id,
        contractId: payment.contractId,
        dueDate: payment.dueDate,
        status: payment.status,
        grossAmount: payment.grossAmount,
        platformFee: payment.platformFee,
        netAmount: payment.netAmount,
      );

      await _supabaseClient.from('rent_payments').upsert(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Error saving payment: $e');
    }
  }
}
