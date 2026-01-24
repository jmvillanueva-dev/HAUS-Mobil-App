import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_location_entity.dart';
import '../../domain/usecases/get_my_locations_usecase.dart';

// Events
abstract class LocationsEvent extends Equatable {
  const LocationsEvent();

  @override
  List<Object> get props => [];
}

class LoadMyLocations extends LocationsEvent {
  final String userId;

  const LoadMyLocations(this.userId);

  @override
  List<Object> get props => [userId];
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

  LocationsBloc({required this.getMyLocations}) : super(LocationsInitial()) {
    on<LoadMyLocations>(_onLoadMyLocations);
  }

  Future<void> _onLoadMyLocations(
    LoadMyLocations event,
    Emitter<LocationsState> emit,
  ) async {
    emit(LocationsLoading());
    final result = await getMyLocations(event.userId);
    result.fold(
      (failure) => emit(const LocationsError('Error al cargar ubicaciones')),
      (locations) => emit(LocationsLoaded(locations)),
    );
  }
}
