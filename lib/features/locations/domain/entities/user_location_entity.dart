import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Propósito de la ubicación
enum LocationPurpose {
  search, // Ubicación para buscar roomies cerca
  listing; // Ubicación de vivienda para publicar

  String get value {
    switch (this) {
      case LocationPurpose.search:
        return 'search';
      case LocationPurpose.listing:
        return 'listing';
    }
  }

  static LocationPurpose fromString(String? value) {
    switch (value) {
      case 'listing':
        return LocationPurpose.listing;
      case 'search':
      default:
        return LocationPurpose.search;
    }
  }

  String get displayName {
    switch (this) {
      case LocationPurpose.search:
        return 'Búsqueda';
      case LocationPurpose.listing:
        return 'Publicación';
    }
  }
}

/// Tipo/etiqueta de la ubicación
enum LocationLabel {
  home,
  work,
  university,
  other;

  String get value {
    switch (this) {
      case LocationLabel.home:
        return 'home';
      case LocationLabel.work:
        return 'work';
      case LocationLabel.university:
        return 'university';
      case LocationLabel.other:
        return 'other';
    }
  }

  static LocationLabel fromString(String? value) {
    switch (value) {
      case 'home':
        return LocationLabel.home;
      case 'university':
        return LocationLabel.university;
      case 'other':
        return LocationLabel.other;
      case 'work':
      default:
        return LocationLabel.work;
    }
  }

  String get displayName {
    switch (this) {
      case LocationLabel.home:
        return 'Casa';
      case LocationLabel.work:
        return 'Trabajo';
      case LocationLabel.university:
        return 'Universidad';
      case LocationLabel.other:
        return 'Otro';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationLabel.home:
        return Icons.home_rounded;
      case LocationLabel.work:
        return Icons.work_rounded;
      case LocationLabel.university:
        return Icons.school_rounded;
      case LocationLabel.other:
        return Icons.location_on_rounded;
    }
  }
}

/// Entidad de ubicación de usuario
class UserLocationEntity extends Equatable {
  final String id;
  final String userId;
  final LocationLabel label;
  final LocationPurpose purpose;
  final String? address;
  final String? city;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserLocationEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.purpose,
    this.address,
    this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Si la ubicación tiene coordenadas
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Dirección formateada para mostrar
  String get formattedAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (neighborhood != null && neighborhood!.isNotEmpty)
      parts.add(neighborhood!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.isNotEmpty ? parts.join(', ') : 'Sin dirección';
  }

  UserLocationEntity copyWith({
    String? id,
    String? userId,
    LocationLabel? label,
    LocationPurpose? purpose,
    String? address,
    String? city,
    String? neighborhood,
    double? latitude,
    double? longitude,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserLocationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      purpose: purpose ?? this.purpose,
      address: address ?? this.address,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        label,
        purpose,
        address,
        city,
        neighborhood,
        latitude,
        longitude,
        isPrimary,
        createdAt,
        updatedAt,
      ];
}
