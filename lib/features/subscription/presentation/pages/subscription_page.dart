import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/subscription_plan.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isLoading = false;

  Future<void> _handleSubscribe(SubscriptionPlan plan) async {
    setState(() => _isLoading = true);

    try {
      final repository = GetIt.I<SubscriptionRepository>();
      final result = await repository.updateSubscription(plan.tier);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(failure.message), backgroundColor: Colors.red),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Plan actualizado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh Auth State to update UI immediately
            context.read<AuthBloc>().add(const AuthCheckRequested());
            Navigator.pop(context);
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        SubscriptionTier currentTier = SubscriptionTier.free;
        if (state is AuthAuthenticated) {
          currentTier = state.user.subscriptionTier;
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppTheme.backgroundDark,
              appBar: AppBar(
                backgroundColor: AppTheme.backgroundDark,
                title: const Text('Planes de Suscripción'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mejora tu experiencia',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Elige el plan que mejor se adapte a tus necesidades como Host.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPlanCard(
                      context,
                      SubscriptionPlan.free(),
                      isCurrent: currentTier == SubscriptionTier.free,
                      onTap: () => _handleSubscribe(SubscriptionPlan.free()),
                    ),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      context,
                      SubscriptionPlan.pro(),
                      isCurrent: currentTier == SubscriptionTier.pro,
                      isRecommended: true,
                      onTap: () => _handleSubscribe(SubscriptionPlan.pro()),
                    ),
                    const SizedBox(height: 16),
                    _buildPlanCard(
                      context,
                      SubscriptionPlan.business(),
                      isCurrent: currentTier == SubscriptionTier.business,
                      onTap: () =>
                          _handleSubscribe(SubscriptionPlan.business()),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan, {
    bool isCurrent = false,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    final isFree = plan.price == 0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: isRecommended
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : Border.all(color: AppTheme.borderDark),
        boxShadow: isRecommended
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTUAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isFree ? 'Gratis' : '\$${plan.price} / mes',
                  style: TextStyle(
                    color: isRecommended ? AppTheme.primaryColor : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(
                    'Contratos Activos',
                    isFree
                        ? '1'
                        : (plan.maxContracts > 100
                            ? 'Ilimitados'
                            : '${plan.maxContracts}')),
                _buildFeatureRow(
                    'Generar Facturas', plan.canGenerateInvoices ? 'Sí' : 'No',
                    isCheck: plan.canGenerateInvoices),
                _buildFeatureRow(
                    'Analíticas Avanzadas', plan.canViewAnalytics ? 'Sí' : 'No',
                    isCheck: plan.canViewAnalytics),
                _buildFeatureRow(
                    'Recibir Pagos en App', plan.isPaymentEnabled ? 'Sí' : 'No',
                    isCheck: plan.isPaymentEnabled),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? AppTheme.primaryColor
                          : AppTheme.surfaceDark,
                      foregroundColor: Colors.white,
                      side: isRecommended
                          ? null
                          : const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isCurrent ? 'Plan Actual' : 'Seleccionar'),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'RECOMENDADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value, {bool isCheck = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (isCheck)
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.secondaryColor,
              size: 18,
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
