import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/listing_entity.dart';
import '../repositories/listing_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateListing implements UseCase<ListingEntity, UpdateListingParams> {
  final ListingRepository repository;

  UpdateListing(this.repository);

  @override
  Future<Either<Failure, ListingEntity>> call(
      UpdateListingParams params) async {
    return await repository.updateListing(params.listing, params.newImages);
  }
}

class UpdateListingParams extends Equatable {
  final ListingEntity listing;
  final List<File>? newImages;

  const UpdateListingParams({required this.listing, this.newImages});

  @override
  List<Object?> get props => [listing, newImages];
}
