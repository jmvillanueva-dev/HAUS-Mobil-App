import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String id;
  final String userId;
  final String label;
  final String purpose;
  final String address;
  final String city;
  final String neighborhood;
  final double latitude;
  final double longitude;
  final bool isPrimary;

  const LocationEntity({
    required this.id,
    required this.userId,
    required this.label,
    required this.purpose,
    required this.address,
    required this.city,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
  });

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
      ];
}
