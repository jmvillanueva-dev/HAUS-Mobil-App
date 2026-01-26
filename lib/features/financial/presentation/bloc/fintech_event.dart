part of 'fintech_bloc.dart';

abstract class FintechEvent extends Equatable {
  const FintechEvent();

  @override
  List<Object> get props => [];
}

class LoadContracts extends FintechEvent {}

class LoadPaymentCalendar extends FintechEvent {
  final RentContract contract;

  const LoadPaymentCalendar(this.contract);

  @override
  List<Object> get props => [contract];
}

class SubscribeToPaymentUpdates extends FintechEvent {
  final String contractId;

  const SubscribeToPaymentUpdates(this.contractId);

  @override
  List<Object> get props => [contractId];
}

class SimulatePayment extends FintechEvent {
  final RentPayment payment;

  const SimulatePayment(this.payment);

  @override
  List<Object> get props => [payment];
}
