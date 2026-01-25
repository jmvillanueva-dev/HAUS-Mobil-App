import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_datasource.dart';

/// Implementación del repositorio de matching
@LazySingleton(as: MatchingRepository)
class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingDataSource _dataSource;

  MatchingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<MatchCandidate>>> getCandidates(
      {int limit = 20}) async {
    try {
      final candidates = await _dataSource.getCandidates(limit: limit);
      return Right(candidates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Match?>> recordInteraction({
    required String targetUserId,
    required InteractionType action,
  }) async {
    try {
      // Verificar límite diario para likes
      if (action == InteractionType.like ||
          action == InteractionType.superLike) {
        final dailyCount = await _dataSource.getDailyLikesCount();
        if (dailyCount >= MatchingRepository.dailyLikeLimit) {
          return Left(
              ServerFailure('Has alcanzado el límite de 10 likes diarios'));
        }
      }

      // Registrar la interacción
      await _dataSource.recordInteraction(
        targetUserId: targetUserId,
        action: action,
      );

      // Si fue un like, verificar si hubo match
      if (action == InteractionType.like ||
          action == InteractionType.superLike) {
        final match = await _dataSource.checkForMatch(targetUserId);
        return Right(match);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Match>>> getMatches() async {
    try {
      final matches = await _dataSource.getMatches();
      return Right(matches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getDailyLikesCount() async {
    try {
      final count = await _dataSource.getDailyLikesCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasRemainingLikes() async {
    try {
      final count = await _dataSource.getDailyLikesCount();
      return Right(count < MatchingRepository.dailyLikeLimit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
