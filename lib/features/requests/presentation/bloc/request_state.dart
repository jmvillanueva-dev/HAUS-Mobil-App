import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_request_entity.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestOperationSuccess extends RequestState {
  final String message;
  final ListingRequestEntity? request; // Optional updated request

  const RequestOperationSuccess({required this.message, this.request});

  @override
  List<Object?> get props => [message, request];
}

class RequestsLoaded extends RequestState {
  final List<ListingRequestEntity> requests;

  const RequestsLoaded({required this.requests});

  @override
  List<Object> get props => [requests];
}

class RequestStatusLoaded extends RequestState {
  final ListingRequestEntity? request; // Null if no request yet

  const RequestStatusLoaded({this.request});

  @override
  List<Object?> get props => [request];
}

class RequestError extends RequestState {
  final String message;

  const RequestError({required this.message});

  @override
  List<Object> get props => [message];
}
