import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/listing_entity.dart';

abstract class ListingRepository {
  Future<Either<Failure, ListingEntity>> createListing(
      ListingEntity listing, List<File> images);
  Future<Either<Failure, List<ListingEntity>>> getListings();
  Stream<Either<Failure, List<ListingEntity>>> getListingsStream();
  Future<Either<Failure, void>> deleteListing(String listingId);
}
