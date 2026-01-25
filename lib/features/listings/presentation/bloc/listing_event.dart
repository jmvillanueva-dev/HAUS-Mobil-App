import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

// --- Filter Class ---
class ListingFilter extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final String? housingType;
  final String? city;
  final List<String> amenities;
  final String? searchQuery;

  const ListingFilter({
    this.minPrice,
    this.maxPrice,
    this.housingType,
    this.city,
    this.amenities = const [],
    this.searchQuery,
  });

  bool get isEmpty =>
      minPrice == null &&
      maxPrice == null &&
      housingType == null &&
      city == null &&
      amenities.isEmpty &&
      (searchQuery == null || searchQuery!.isEmpty);

  @override
  List<Object?> get props =>
      [minPrice, maxPrice, housingType, city, amenities, searchQuery];
}

abstract class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object?> get props => [];
}

class LoadListingsEvent extends ListingEvent {}

class LoadMyListingsEvent extends ListingEvent {
  final String userId;
  const LoadMyListingsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CreateListingEvent extends ListingEvent {
  final ListingEntity listing;
  final List<File> images;

  const CreateListingEvent({required this.listing, required this.images});

  @override
  List<Object> get props => [listing, images];
}

class DeleteListingEvent extends ListingEvent {
  final String listingId;

  const DeleteListingEvent({required this.listingId});

  @override
  List<Object> get props => [listingId];
}

class UpdateListingEvent extends ListingEvent {
  final ListingEntity listing;
  final List<File>? newImages;

  const UpdateListingEvent({required this.listing, this.newImages});

  @override
  List<Object?> get props => [listing, newImages];
}

class UpdateFiltersEvent extends ListingEvent {
  final ListingFilter filter;
  const UpdateFiltersEvent({required this.filter});
  @override
  List<Object> get props => [filter];
}
