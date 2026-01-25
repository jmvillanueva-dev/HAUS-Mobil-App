import 'package:equatable/equatable.dart';

class ListingEntity extends Equatable {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String housingType;
  final String city;
  final String neighborhood;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> amenities;
  final List<String> houseRules;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final bool isAvailable;

  const ListingEntity({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.housingType,
    required this.city,
    required this.neighborhood,
    required this.address,
    this.latitude,
    this.longitude,
    required this.amenities,
    required this.houseRules,
    required this.imageUrls,
    this.createdAt,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        price,
        housingType,
        city,
        neighborhood,
        address,
        latitude,
        longitude,
        amenities,
        houseRules,
        imageUrls,
        imageUrls,
        createdAt,
        isAvailable,
      ];
}
