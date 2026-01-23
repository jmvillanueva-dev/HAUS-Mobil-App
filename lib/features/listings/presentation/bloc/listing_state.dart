import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

abstract class ListingState extends Equatable {
  const ListingState();
  
  @override
  List<Object> get props => [];
}

class ListingInitial extends ListingState {}

class ListingLoading extends ListingState {}

class ListingsLoaded extends ListingState {
  final List<ListingEntity> listings;

  const ListingsLoaded({required this.listings});

  @override
  List<Object> get props => [listings];
}

// Estado específico para cuando una acción (crear/borrar) termina bien
class ListingOperationSuccess extends ListingState {
  final String message;

  const ListingOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ListingError extends ListingState {
  final String message;

  const ListingError({required this.message});

  @override
  List<Object> get props => [message];
}