import '../../domain/entities/listing_entity.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.price,
    required super.housingType,
    required super.city,
    required super.neighborhood,
    required super.address,
    super.latitude,
    super.longitude,
    required super.amenities,
    required super.houseRules,
    required super.imageUrls,
    super.createdAt,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      housingType: json['housing_type'] ?? '',
      city: json['city'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      amenities: List<String>.from(json['amenities'] ?? []),
      houseRules: List<String>.from(json['house_rules'] ?? []),
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'housing_type': housingType,
      'city': city,
      'neighborhood': neighborhood,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'amenities': amenities,
      'house_rules': houseRules,
      'image_urls': imageUrls,
    };
  }
}
