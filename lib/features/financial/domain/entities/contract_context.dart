import 'rent_contract.dart';

enum UserContractRole {
  host,
  tenant,
  none,
}

class ContractContext {
  final RentContract contract;
  final UserContractRole role;

  ContractContext({
    required this.contract,
    required this.role,
  });

  bool get canPay => role == UserContractRole.tenant;
  bool get canViewEarnings => role == UserContractRole.host;
}
