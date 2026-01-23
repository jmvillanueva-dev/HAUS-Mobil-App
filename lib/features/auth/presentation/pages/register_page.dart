import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';
import 'email_verification_sent_page.dart';
import 'welcome_page.dart';

class RegisterPage extends StatefulWidget {
  final String role;

  const RegisterPage({
    super.key,
    required this.role,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              role: widget.role,
            ),
          );
    }
  }

  IconData get _roleIcon {
    return widget.role == 'student' ? Icons.school_rounded : Icons.work_rounded;
  }

  Color get _themeColor {
    return widget.role == 'worker'
        ? AppTheme.secondaryColor
        : AppTheme.primaryColor;
  }

  Color get _themeDarkColor {
    return widget.role == 'worker'
        ? AppTheme.secondaryDark
        : AppTheme.primaryDark;
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
          } else if (state is EmailVerificationRequired) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => EmailVerificationSentPage(email: state.email),
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => WelcomePage(user: state.user),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: _themeColor,
                  ),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: _themeColor,
                selectionColor: _themeColor.withValues(alpha: 0.3),
                selectionHandleColor: _themeColor,
              ),
              inputDecorationTheme:
                  Theme.of(context).inputDecorationTheme.copyWith(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: _themeColor, width: 2),
                        ),
                      ),
            ),
            child: LoadingOverlay(
              isLoading: isLoading,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        // Header con botón de regreso
                        _buildHeader(),

                        const SizedBox(height: 16),

                        // Register icon
                        _buildRegisterIcon(),

                        const SizedBox(height: 16),

                        // Title
                        _buildTitle(),

                        const SizedBox(height: 24),

                        // Name fields (row)
                        _buildNameFields(),

                        const SizedBox(height: 12),

                        // Email field
                        CustomTextField(
                          controller: _emailController,
                          label: 'Correo electrónico',
                          hint: 'tu@email.com',
                          prefixIcon: Icons.email_outlined,
                          iconColor: _themeColor,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            final emailRegex =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password field
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: 'Mínimo 6 caracteres',
                          prefixIcon: Icons.lock_outline,
                          iconColor: _themeColor,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Confirm password field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar contraseña',
                          hint: 'Repite tu contraseña',
                          prefixIcon: Icons.lock_outline,
                          iconColor: _themeColor,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        _buildRegisterButton(isLoading),

                        const SizedBox(height: 12),

                        // Info text
                        _buildInfoText(),

                        const SizedBox(height: 16),
                      ],
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

  Widget _buildHeader() {
    return const SizedBox.shrink();
  }

  Widget _buildRegisterIcon() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _themeColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          // Main icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _themeColor,
                  _themeDarkColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _themeColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              _roleIcon,
              size: 28,
              color: widget.role == 'worker'
                  ? AppTheme.backgroundDark
                  : Colors.white,
            ),
          ),
          // Small plus badge
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _themeColor,
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
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: _themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Crea tu cuenta',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Completa tus datos para comenzar a buscar tu roomie ideal',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondaryDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _firstNameController,
            label: 'Nombre',
            hint: 'Tu nombre',
            prefixIcon: Icons.person_outline,
            iconColor: _themeColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Requerido';
              }
              if (value.length < 2) {
                return 'Mínimo 2 letras';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomTextField(
            controller: _lastNameController,
            label: 'Apellido',
            hint: 'Tu apellido',
            prefixIcon: Icons.person_outline,
            iconColor: _themeColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Requerido';
              }
              if (value.length < 2) {
                return 'Mínimo 2 letras';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            _themeColor,
            _themeDarkColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Crear cuenta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.backgroundDark,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: _themeColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Recibirás un correo de verificación para activar tu cuenta',
              style: TextStyle(
                color: AppTheme.textSecondaryDark,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
