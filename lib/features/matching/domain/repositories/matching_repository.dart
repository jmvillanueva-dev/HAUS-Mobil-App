import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/match_entity.dart';

/// Repositorio abstracto para operaciones de matching
abstract class MatchingRepository {
  /// Obtener candidatos de matching para el usuario actual
  Future<Either<Failure, List<MatchCandidate>>> getCandidates({int limit = 20});

  /// Registrar una interacción (like/skip) con un usuario
  /// Retorna el Match si se creó uno (like mutuo)
  Future<Either<Failure, Match?>> recordInteraction({
    required String targetUserId,
    required InteractionType action,
  });

  /// Obtener los matches del usuario actual
  Future<Either<Failure, List<Match>>> getMatches();

  /// Obtener el conteo de likes realizados hoy
  Future<Either<Failure, int>> getDailyLikesCount();

  /// Verificar si quedan likes disponibles hoy
  Future<Either<Failure, bool>> hasRemainingLikes();

  /// Constante del límite diario de likes
  static const int dailyLikeLimit = 10;
}
