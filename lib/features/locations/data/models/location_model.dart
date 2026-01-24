import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.userId,
    required super.label,
    required super.purpose,
    required super.address,
    required super.city,
    required super.neighborhood,
    required super.latitude,
    required super.longitude,
    required super.isPrimary,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      userId: json['user_id'],
      label: json['label'],
      purpose: json['purpose'],
      address: json['address'],
      city: json['city'],
      neighborhood: json['neighborhood'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'purpose': purpose,
      'address': address,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': isPrimary,
    };
  }
}
