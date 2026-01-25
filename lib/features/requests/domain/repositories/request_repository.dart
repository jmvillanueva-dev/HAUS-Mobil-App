import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/listing_request_entity.dart';

abstract class RequestRepository {
  /// Envia una solicitud para un listing
  Future<Either<Failure, ListingRequestEntity>> sendRequest({
    required String listingId,
    required String hostId,
    String? message,
  });

  /// Obtiene las solicitudes recibidas (siendo el host)
  Future<Either<Failure, List<ListingRequestEntity>>> getReceivedRequests();

  /// Obtiene las solicitudes enviadas (siendo el requester)
  Future<Either<Failure, List<ListingRequestEntity>>> getSentRequests();

  /// Actualiza el estado de una solicitud (Aprobar/Rechazar)
  Future<Either<Failure, ListingRequestEntity>> updateRequestStatus({
    required String requestId,
    required String status,
  });

  /// Obtiene el estado de solicitud para un listing específico (para saber si ya solicité)
  Future<Either<Failure, ListingRequestEntity?>> getRequestForListing(
      String listingId);
}
