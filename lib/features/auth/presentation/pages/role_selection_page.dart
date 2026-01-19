import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'register_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              const Spacer(),

              // Title section
              _buildTitle(context),

              SizedBox(height: size.height * 0.06),

              // Role cards
              _RoleCard(
                icon: Icons.school_rounded,
                title: 'Soy Estudiante',
                subtitle: 'Busco roomie cerca de mi universidad',
                gradient: [
                  AppTheme.primaryColor,
                  AppTheme.primaryDark,
                ],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(role: 'student'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _RoleCard(
                icon: Icons.work_rounded,
                title: 'Soy Trabajador',
                subtitle: 'Busco roomie cerca de mi trabajo',
                gradient: [
                  AppTheme.secondaryColor,
                  AppTheme.secondaryDark,
                ],
                isSecondary: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(role: 'worker'),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Info text
              _buildInfoText(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderDark,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
            color: AppTheme.textPrimaryDark,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Spacer(),
        // Mini logo
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_rounded,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'HAUS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        // Icono principal
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.2),
                AppTheme.primaryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.person_search_rounded,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¿Cuál es tu perfil?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Esto nos ayudará a mostrarte roomies\nque se ajusten a tu estilo de vida',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryDark,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoText() {
    return Text(
      'Podrás cambiar esto más adelante en tu perfil',
      style: TextStyle(
        fontSize: 12,
        color: AppTheme.textTertiaryDark,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final bool isSecondary;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.isSecondary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradient[0].withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container with gradient
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSecondary ? AppTheme.backgroundDark : Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: gradient[0].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: gradient[0],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
