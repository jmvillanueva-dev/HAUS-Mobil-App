import '../../domain/entities/user_location_entity.dart';

/// Modelo de ubicación para interactuar con Supabase
class UserLocationModel extends UserLocationEntity {
  const UserLocationModel({
    required super.id,
    required super.userId,
    required super.label,
    required super.purpose,
    super.address,
    super.city,
    super.neighborhood,
    super.latitude,
    super.longitude,
    super.isPrimary,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crear modelo desde JSON de Supabase
  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: LocationLabel.fromString(json['label'] as String?),
      purpose: LocationPurpose.fromString(json['purpose'] as String?),
      address: json['address'] as String?,
      city: json['city'] as String?,
      neighborhood: json['neighborhood'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertir a JSON para guardar en Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label.value,
      'purpose': purpose.value,
      'address': address,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': isPrimary,
    };
  }

  /// Convertir a JSON para insertar (sin id ni timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'label': label.value,
      'purpose': purpose.value,
      'address': address,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': isPrimary,
    };
  }

  /// Convertir a JSON para actualizar
  Map<String, dynamic> toUpdateJson() {
    return {
      'label': label.value,
      'purpose': purpose.value,
      'address': address,
      'city': city,
      'neighborhood': neighborhood,
      'latitude': latitude,
      'longitude': longitude,
      'is_primary': isPrimary,
    };
  }

  /// Crear modelo desde entidad
  factory UserLocationModel.fromEntity(UserLocationEntity entity) {
    return UserLocationModel(
      id: entity.id,
      userId: entity.userId,
      label: entity.label,
      purpose: entity.purpose,
      address: entity.address,
      city: entity.city,
      neighborhood: entity.neighborhood,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isPrimary: entity.isPrimary,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convertir a entidad pura
  UserLocationEntity toEntity() {
    return UserLocationEntity(
      id: id,
      userId: userId,
      label: label,
      purpose: purpose,
      address: address,
      city: city,
      neighborhood: neighborhood,
      latitude: latitude,
      longitude: longitude,
      isPrimary: isPrimary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
