import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/rent_contract.dart';
import '../../domain/entities/rent_payment.dart';
import '../../domain/repositories/financial_repository.dart';
import '../../domain/usecases/get_payment_calendar.dart';
import '../../domain/usecases/process_simulated_payment.dart';
import '../../domain/entities/contract_context.dart';
import '../../domain/usecases/get_contract_context.dart';
import '../../domain/usecases/calculate_monthly_earnings.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For current user ID
import 'package:get_it/get_it.dart';
import '../../../../core/services/notification_service.dart';

part 'fintech_event.dart';
part 'fintech_state.dart';

class FintechBloc extends Bloc<FintechEvent, FintechState> {
  final FinancialRepository repository;
  final GetPaymentCalendar getPaymentCalendar;
  final ProcessSimulatedPayment processSimulatedPayment;
  final GetContractContext getContractContext;
  final CalculateMonthlyEarnings calculateMonthlyEarnings;

  FintechBloc({
    required this.repository,
    required this.getPaymentCalendar,
    required this.processSimulatedPayment,
    required this.getContractContext,
    required this.calculateMonthlyEarnings,
  }) : super(FintechInitial()) {
    on<LoadContracts>(_onLoadContracts);
    on<LoadPaymentCalendar>(_onLoadPaymentCalendar);
    on<SimulatePayment>(_onSimulatePayment);
    on<SubscribeToPaymentUpdates>(_onSubscribeToPaymentUpdates);
  }

  Future<void> _onSubscribeToPaymentUpdates(
    SubscribeToPaymentUpdates event,
    Emitter<FintechState> emit,
  ) async {
    await emit.forEach<List<RentPayment>>(
      repository.subscribeToPayments(event.contractId),
      onData: (payments) {
        final currentState = state;
        if (currentState is FintechCalendarLoaded) {
          // BUG FIX: If the stream returns empty (no payments in DB yet)
          // but we are showing simulated payments, do NOT overwrite with empty.
          if (payments.isEmpty &&
              currentState.payments.any((p) => p.id.startsWith('simulated_'))) {
            return currentState;
          }

          // Check for new payments to notify
          if (currentState.context.canViewEarnings) {
            _checkAndNotifyNewPayments(currentState.payments, payments);
          }

          return FintechCalendarLoaded(
            payments: payments,
            contract: currentState.contract,
            context: currentState.context,
          );
        }
        return state;
      },
      onError: (error, stackTrace) => FintechError(error.toString()),
    );
  }

  void _checkAndNotifyNewPayments(
      List<RentPayment> oldList, List<RentPayment> newList) {
    // Find payments that were not paid before but are paid now
    for (var newPayment in newList) {
      if (newPayment.status == 'paid') {
        final oldPayment = oldList.firstWhere(
          (p) => p.id == newPayment.id,
          orElse: () => newPayment, // Should not happen if lists are synced
        );

        if (oldPayment.status != 'paid') {
          // Trigger notification
          GetIt.I<NotificationService>().showListingRequestNotification(
            title: '¡Nuevo Pago Recibido!',
            body:
                'Has recibido un pago de renta por \$${newPayment.netAmount.toStringAsFixed(2)}',
            requestId: newPayment.id, // Using request ID field for payment ID
            listingId: newPayment.contractId,
          );
        }
      }
    }
  }

  Future<void> _onLoadContracts(
    LoadContracts event,
    Emitter<FintechState> emit,
  ) async {
    emit(FintechLoading());
    try {
      final contracts = await repository.getContracts();

      // Calculate total income using the new use case
      // We need to fetch payments for active contracts to calculate earnings
      // This is a bit heavy, but correct for the requirement
      double totalIncome = 0;
      for (var contract in contracts) {
        if (contract.status == 'active') {
          // Fetch payments for this contract
          final payments =
              await repository.fetchPaymentsByContract(contract.id);
          // Calculate earnings for this contract
          totalIncome += calculateMonthlyEarnings(payments);
        }
      }

      emit(FintechContractsLoaded(
        contracts: contracts,
        totalIncome: totalIncome,
      ));

      // Subscribe to updates for all active contracts to keep dashboard in sync
      for (var contract in contracts) {
        if (contract.status == 'active') {
          add(SubscribeToPaymentUpdates(contract.id));
        }
      }
    } catch (e) {
      emit(FintechError(e.toString()));
    }
  }

  Future<void> _onLoadPaymentCalendar(
    LoadPaymentCalendar event,
    Emitter<FintechState> emit,
  ) async {
    emit(FintechLoading());
    try {
      // 1. Try to get real payments from DB
      List<RentPayment> payments =
          await repository.fetchPaymentsByContract(event.contract.id);

      // 2. If no payments exist (simulation), generate them locally
      if (payments.isEmpty) {
        payments = getPaymentCalendar(event.contract);
      }

      // 3. Get Contract Context (Role)
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final context = getContractContext(event.contract, userId);

      emit(FintechCalendarLoaded(
        payments: payments,
        contract: event.contract,
        context: context,
      ));

      // Subscribe to real-time updates
      add(SubscribeToPaymentUpdates(event.contract.id));
    } catch (e) {
      emit(FintechError(e.toString()));
    }
  }

  Future<void> _onSimulatePayment(
    SimulatePayment event,
    Emitter<FintechState> emit,
  ) async {
    // Keep current state to restore it or update it
    final currentState = state;
    if (currentState is! FintechCalendarLoaded) return;

    emit(FintechLoading());
    try {
      // Simulate payment processing
      final processedPayment = await processSimulatedPayment(event.payment);

      // Update DB to trigger Realtime for other users and get the real ID
      final updatedPayment = await repository.upsertPayment(processedPayment);

      // We don't strictly need to update local state manually if we are subscribed to the stream,
      // but for immediate feedback we can do it.
      // However, since we have the stream subscription, let's rely on that for the "Realtime" proof.
      // But to be safe and fast:
      final updatedPayments = currentState.payments.map((p) {
        return p.dueDate == updatedPayment.dueDate ? updatedPayment : p;
      }).toList();

      emit(FintechCalendarLoaded(
        payments: updatedPayments,
        contract: currentState.contract,
        context: currentState.context,
      ));

      // Emit a one-time success event?
      // Bloc pattern usually avoids ephemeral states if possible, but we can handle it in UI listener
      // Or we can just stay in CalendarLoaded and let UI show success based on change
    } catch (e) {
      emit(FintechError(e.toString()));
      // Restore previous state
      emit(currentState);
    }
  }
}
