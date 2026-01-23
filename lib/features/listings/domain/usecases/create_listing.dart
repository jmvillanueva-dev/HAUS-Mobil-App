import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';
import 'package:injectable/injectable.dart';


class CreateListingParams {
  final ListingEntity listing;
  final List<File> images;

  CreateListingParams({required this.listing, required this.images});
}

@lazySingleton
class CreateListing implements UseCase<ListingEntity, CreateListingParams> {
  final ListingRepository repository;

  CreateListing(this.repository);

  @override
  Future<Either<Failure, ListingEntity>> call(CreateListingParams params) async {
    return await repository.createListing(params.listing, params.images);
  }
}