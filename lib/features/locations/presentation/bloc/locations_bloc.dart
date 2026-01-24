import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_my_locations_usecase.dart';

// Events
abstract class LocationsEvent extends Equatable {
  const LocationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyLocations extends LocationsEvent {
  final String userId;

  const LoadMyLocations(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddLocation extends LocationsEvent {
  final String userId;
  final LocationLabel label;
  final LocationPurpose purpose;
  final String? address;
  final String? city;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  const AddLocation({
    required this.userId,
    required this.label,
    required this.purpose,
    this.address,
    this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        userId,
        label,
        purpose,
        address,
        city,
        neighborhood,
        latitude,
        longitude
      ];
}

class UpdateLocation extends LocationsEvent {
  final String userId;
  final String locationId;
  final LocationLabel label;
  final LocationPurpose purpose;
  final String? address;
  final String? city;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  const UpdateLocation({
    required this.userId,
    required this.locationId,
    required this.label,
    required this.purpose,
    this.address,
    this.city,
    this.neighborhood,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        userId,
        locationId,
        label,
        purpose,
        address,
        city,
        neighborhood,
        latitude,
        longitude
      ];
}

// States
abstract class LocationsState extends Equatable {
  const LocationsState();

  @override
  List<Object> get props => [];
}

class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsLoaded extends LocationsState {
  final List<UserLocationEntity> locations;

  const LocationsLoaded(this.locations);

  @override
  List<Object> get props => [locations];
}

class LocationsError extends LocationsState {
  final String message;

  const LocationsError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final GetMyLocationsUseCase getMyLocations;
  final LocationRepository repository;

  LocationsBloc({
    required this.getMyLocations,
    required this.repository,
  }) : super(LocationsInitial()) {
    on<LoadMyLocations>(_onLoadMyLocations);
    on<AddLocation>(_onAddLocation);
    on<UpdateLocation>(_onUpdateLocation);
  }

  Future<void> _onLoadMyLocations(
    LoadMyLocations event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    final result = await getMyLocations(event.userId);
    result.fold(
      (failure) => emit(LocationsError(_mapFailureToMessage(failure))),
      (locations) => emit(LocationsLoaded(locations)),
    );
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    final result = await repository.createLocation(
      userId: event.userId,
      label: event.label,
      purpose: event.purpose,
      address: event.address,
      city: event.city,
      neighborhood: event.neighborhood,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(LocationsError(_mapFailureToMessage(failure))),
      (_) => add(LoadMyLocations(event.userId)),
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    final result = await repository.updateLocation(
      locationId: event.locationId,
      label: event.label,
      purpose: event.purpose,
      address: event.address,
      city: event.city,
      neighborhood: event.neighborhood,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(LocationsError(_mapFailureToMessage(failure))),
      (_) => add(LoadMyLocations(event.userId)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return (failure as ServerFailure).message;
      case CacheFailure _:
        return (failure as CacheFailure).message;
      default:
        return 'Unexpected Error';
    }
  }
}
