import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, void>> updateSubscription(SubscriptionTier tier);
}
