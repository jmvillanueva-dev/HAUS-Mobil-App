import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matching_repository.dart';

// --- EVENTS ---
abstract class HomeMatchingEvent extends Equatable {
  const HomeMatchingEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeMatches extends HomeMatchingEvent {}

// --- STATES ---
abstract class HomeMatchingState extends Equatable {
  const HomeMatchingState();

  @override
  List<Object> get props => [];
}

class HomeMatchingInitial extends HomeMatchingState {}

class HomeMatchingLoading extends HomeMatchingState {}

class HomeMatchingLoaded extends HomeMatchingState {
  final List<MatchCandidate> candidates;

  const HomeMatchingLoaded(this.candidates);

  @override
  List<Object> get props => [candidates];
}

class HomeMatchingError extends HomeMatchingState {
  final String message;

  const HomeMatchingError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BLOC ---
@injectable
class HomeMatchingBloc extends Bloc<HomeMatchingEvent, HomeMatchingState> {
  final MatchingRepository repository;

  HomeMatchingBloc(this.repository) : super(HomeMatchingInitial()) {
    on<LoadHomeMatches>(_onLoadHomeMatches);
  }

  Future<void> _onLoadHomeMatches(
    LoadHomeMatches event,
    Emitter<HomeMatchingState> emit,
  ) async {
    emit(HomeMatchingLoading());

    // Limitamos a 10 para el home para no sobrecargar
    final result = await repository.getCandidates(limit: 10);

    result.fold(
      (failure) => emit(HomeMatchingError(failure.message)),
      (candidates) => emit(HomeMatchingLoaded(candidates)),
    );
  }
}
