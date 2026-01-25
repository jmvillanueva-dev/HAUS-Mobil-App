import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_data_source.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ListingRepository)
class ListingRepositoryImpl implements ListingRepository {
  final ListingRemoteDataSource remoteDataSource;

  ListingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ListingEntity>> createListing(
      ListingEntity listing, List<File> images) async {
    try {
      final result = await remoteDataSource.uploadListing(listing, images);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getListings() async {
    try {
      final result = await remoteDataSource.fetchListings();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ListingEntity>>> getListingsStream() {
    return remoteDataSource.getListingsStream().map((models) {
      return Right<Failure, List<ListingEntity>>(models);
    }).handleError((error) {
      return Left<Failure, List<ListingEntity>>(
          ServerFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<ListingEntity>>> getMyListingsStream(
      String userId) {
    return remoteDataSource.getMyListingsStream(userId).map((models) {
      return Right<Failure, List<ListingEntity>>(models);
    }).handleError((error) {
      return Left<Failure, List<ListingEntity>>(
          ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, ListingEntity>> updateListing(
      ListingEntity listing, List<File>? newImages) async {
    try {
      final result = await remoteDataSource.updateListing(listing, newImages);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String listingId) async {
    try {
      await remoteDataSource.deleteListing(listingId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> getListingById(String id) async {
    try {
      final result = await remoteDataSource.getListingById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
