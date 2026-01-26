import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SupabaseClient _supabaseClient;

  SubscriptionRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Failure, void>> updateSubscription(
      SubscriptionTier tier) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return Left(AuthFailure('Usuario no autenticado'));
      }

      // Call the secure RPC function
      // Note: The function name must match the SQL script: update_subscription_tier
      await _supabaseClient.rpc('update_subscription_tier', params: {
        'new_tier': tier.name, // 'free', 'pro', 'business'
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al actualizar suscripción: $e'));
    }
  }
}
