import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listing_request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_datasource.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;

  RequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ListingRequestEntity>> sendRequest({
    required String listingId,
    required String hostId,
    String? message,
  }) async {
    try {
      final request =
          await remoteDataSource.sendRequest(listingId, hostId, message);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingRequestEntity>>>
      getReceivedRequests() async {
    try {
      final requests = await remoteDataSource.getReceivedRequests();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingRequestEntity>>> getSentRequests() async {
    try {
      final requests = await remoteDataSource.getSentRequests();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListingRequestEntity>> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      final request =
          await remoteDataSource.updateRequestStatus(requestId, status);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListingRequestEntity?>> getRequestForListing(
      String listingId) async {
    try {
      final request = await remoteDataSource.getRequestForListing(listingId);
      return Right(request);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
