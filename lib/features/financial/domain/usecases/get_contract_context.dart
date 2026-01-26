import '../entities/contract_context.dart';
import '../entities/rent_contract.dart';

class GetContractContext {
  ContractContext call(RentContract contract, String currentUserId) {
    UserContractRole role = UserContractRole.none;

    if (contract.hostId == currentUserId) {
      role = UserContractRole.host;
    } else if (contract.roomieId == currentUserId) {
      role = UserContractRole.tenant;
    }

    return ContractContext(
      contract: contract,
      role: role,
    );
  }
}
