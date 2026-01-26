part of 'fintech_bloc.dart';

abstract class FintechState extends Equatable {
  const FintechState();

  @override
  List<Object> get props => [];
}

class FintechInitial extends FintechState {}

class FintechLoading extends FintechState {}

class FintechContractsLoaded extends FintechState {
  final List<RentContract> contracts;
  final double totalIncome;

  const FintechContractsLoaded({
    required this.contracts,
    required this.totalIncome,
  });

  @override
  List<Object> get props => [contracts, totalIncome];
}

class FintechCalendarLoaded extends FintechState {
  final List<RentPayment> payments;
  final RentContract contract;
  final ContractContext context;

  const FintechCalendarLoaded({
    required this.payments,
    required this.contract,
    required this.context,
  });

  @override
  List<Object> get props => [payments, contract, context];
}

class FintechPaymentSuccess extends FintechState {
  final String message;

  const FintechPaymentSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class FintechError extends FintechState {
  final String message;

  const FintechError(this.message);

  @override
  List<Object> get props => [message];
}
