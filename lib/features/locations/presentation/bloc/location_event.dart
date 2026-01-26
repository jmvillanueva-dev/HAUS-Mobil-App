import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object> get props => [];
}

class LoadPrimaryLocation extends LocationEvent {
  final String userId;

  const LoadPrimaryLocation(this.userId);

  @override
  List<Object> get props => [userId];
}
