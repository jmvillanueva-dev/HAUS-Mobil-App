import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/loading_overlay.dart';
import 'reset_password_page.dart';
import 'role_selection_page.dart';
import 'social_role_selection_page.dart';
import 'onboarding_page.dart';
import '../../../home/presentation/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
// ... (omitted unchanged parts)

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  // Animation controller for entrance
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _animationController.forward();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Email validation with regex
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _handleSignIn() {
    HapticFeedback.lightImpact();

    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _isEmailValid = emailError == null;
      _isPasswordValid = passwordError == null;
    });

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _navigateWithTransition(Widget page) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is OnboardingRequired) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OnboardingPage(user: state.user),
              ),
            );
          } else if (state is AuthAuthenticated) {
            if (state.needsRoleSelection) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const SocialRoleSelectionPage(),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MainPage(user: state.user),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          // Login icon
                          _buildLoginIcon(),

                          const SizedBox(height: 16),

                          // Sign in header
                          _buildHeader(),

                          const SizedBox(height: 20),

                          // Email field
                          _buildEmailField(),

                          const SizedBox(height: 8),

                          // Password field
                          _buildPasswordField(),

                          // Forgot password
                          _buildForgotPassword(),

                          const SizedBox(height: 12),

                          // Login button
                          _buildLoginButton(isLoading),

                          const SizedBox(height: 14),

                          // Divider
                          _buildDivider(),

                          const SizedBox(height: 12),

                          // Social login text
                          _buildSocialText(),

                          const SizedBox(height: 12),

                          // Social login buttons
                          _buildSocialButtons(),

                          const SizedBox(height: 16),

                          // Terms text
                          _buildTermsText(),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginIcon() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          // Main icon container
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 34,
              color: Colors.white,
            ),
          ),
          // Small lock badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Iniciar sesión',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '¿Nuevo usuario? ',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryDark,
              ),
            ),
            GestureDetector(
              onTap: () => _navigateWithTransition(const RoleSelectionPage()),
              child: const Text(
                'Crear una cuenta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final errorText =
        !_isEmailValid ? _validateEmail(_emailController.text) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !_isEmailValid
                  ? AppTheme.errorColor
                  : _emailFocusNode.hasFocus
                      ? AppTheme.primaryColor
                      : AppTheme.borderDark,
              width: !_isEmailValid ? 2 : (_emailFocusNode.hasFocus ? 2 : 1),
            ),
          ),
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Correo Electrónico',
              hintStyle: TextStyle(
                color: AppTheme.textTertiaryDark,
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (_) => null, // Disable internal validation
            onChanged: (value) {
              if (!_isEmailValid) {
                setState(() {
                  _isEmailValid = _validateEmail(value) == null;
                });
              }
            },
            onTap: () => setState(() {}),
            onEditingComplete: () {
              _passwordFocusNode.requestFocus();
              setState(() {});
            },
          ),
        ),
        // Error text outside the container
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final errorText =
        !_isPasswordValid ? _validatePassword(_passwordController.text) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !_isPasswordValid
                  ? AppTheme.errorColor
                  : _passwordFocusNode.hasFocus
                      ? AppTheme.primaryColor
                      : AppTheme.borderDark,
              width:
                  !_isPasswordValid ? 2 : (_passwordFocusNode.hasFocus ? 2 : 1),
            ),
          ),
          child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Contraseña',
              hintStyle: TextStyle(
                color: AppTheme.textTertiaryDark,
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (_) => null, // Disable internal validation
            onChanged: (value) {
              if (!_isPasswordValid) {
                setState(() {
                  _isPasswordValid = _validatePassword(value) == null;
                });
              }
            },
            onTap: () => setState(() {}),
            onFieldSubmitted: (_) => _handleSignIn(),
          ),
        ),
        // Error text outside the container
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => _navigateWithTransition(const ResetPasswordPage()),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: AppTheme.textSecondaryDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight,
            AppTheme.primaryColor,
            AppTheme.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.backgroundDark,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          isLoading ? 'Cargando...' : 'Iniciar Sesión',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundDark,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.borderDark,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'o',
            style: TextStyle(
              color: AppTheme.textSecondaryDark,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.borderDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialText() {
    return Center(
      child: Text(
        'Continúa con tu red social favorita',
        style: TextStyle(
          color: AppTheme.textSecondaryDark,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google
        _SocialIconButton(
          icon: 'G',
          isText: true,
          onTap: () {
            HapticFeedback.lightImpact();
            context
                .read<AuthBloc>()
                .add(const SocialSignInRequested(OAuthProvider.google));
          },
        ),
        const SizedBox(width: 16),
        // Facebook
        _SocialIconButton(
          icon: Icons.facebook,
          iconColor: const Color(0xFF1877F2),
          onTap: () {
            HapticFeedback.lightImpact();
            context
                .read<AuthBloc>()
                .add(const SocialSignInRequested(OAuthProvider.facebook));
          },
        ),
        const SizedBox(width: 16),
        // X (Twitter)
        _SocialIconButton(
          icon: 'X',
          isText: true,
          onTap: () => _showSocialSnackBar('X'),
        ),
        const SizedBox(width: 16),
        // Apple
        _SocialIconButton(
          icon: Icons.apple_rounded,
          onTap: () => _showSocialSnackBar('Apple'),
        ),
      ],
    );
  }

  void _showSocialSnackBar(String provider) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: Iniciar con $provider'),
        backgroundColor: AppTheme.surfaceDarkElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiaryDark,
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'Al iniciar sesión, aceptas los '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  // TODO: Navigate to Terms
                },
                child: const Text(
                  'Términos de Servicio',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const TextSpan(text: '\ny la '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  // TODO: Navigate to Privacy Policy
                },
                child: const Text(
                  'Política de Privacidad',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

/// Social icon button widget
class _SocialIconButton extends StatefulWidget {
  final dynamic icon;
  final bool isText;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.icon,
    this.isText = false,
    this.iconColor,
    required this.onTap,
  });

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.borderDark,
              width: 1,
            ),
          ),
          child: Center(
            child: widget.isText
                ? Text(
                    widget.icon as String,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.iconColor ?? AppTheme.textPrimaryDark,
                    ),
                  )
                : Icon(
                    widget.icon as IconData,
                    size: 28,
                    color: widget.iconColor ?? AppTheme.textPrimaryDark,
                  ),
          ),
        ),
      ),
    );
  }
}
