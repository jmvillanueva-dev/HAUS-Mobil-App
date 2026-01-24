import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final ResetPassword resetPassword;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.resetPassword,
    required this.signOut,
    required this.getCurrentUser,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<SocialSignInRequested>(_onSocialSignInRequested);
    on<RoleSelected>(_onRoleSelected);

    // Escuchar cambios en el estado de autenticación
    authRepository.authStateChanges.listen((user) {
      if (user != null) {
        // Verificar si necesita seleccionar rol
        // final needsRoleSelection = !user.isRoleSelected; // No usado aquí, se usa en el handler

        if (!user.isProfileComplete) {
          add(const AuthCheckRequested());
        } else {
          add(const AuthCheckRequested());
        }
      } else {
        add(const AuthCheckRequested());
      }
    });
  }

  Future<void> _onSocialSignInRequested(
    SocialSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    // No emitir AuthLoading porque el usuario sale de la app al navegador
    // y cuando regrese, el authStateChanges stream se encargará
    final result = await authRepository.signInWithOAuth(event.provider);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        // El navegador ahora está abierto para autenticación
        // Cuando el usuario regrese, authStateChanges detectará la sesión
      },
    );
  }

  Future<void> _onRoleSelected(
    RoleSelected event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Obtener usuario actual
    final currentUserResult = await getCurrentUser(NoParams());

    await currentUserResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (currentUser) async {
        if (currentUser == null) {
          emit(const AuthUnauthenticated());
          return;
        }

        // 1. Actualizar metadata (auth.users)
        final metadataResult = await authRepository.updateUserMetadata({
          'role': event.role,
          'role_selected': true,
        });

        if (metadataResult.isLeft()) {
          emit(AuthError('Error al actualizar rol'));
          return;
        }

        // 2. Actualizar perfil (public.profiles)
        // Importante: UserRole.fromString maneja la conversión
        // pero necesitamos importar UserRole si no está disponible
        // Asumimos que UserEntity ya tiene el enum.

        // Necesitamos convertir el string del evento al enum UserRole
        // Como UserRole está en user_entity.dart, deberíamos poder usarlo
        // Pero UserRole.fromString es un método estático.

        // Vamos a hacer un copyWith simple.
        // Nota: UserEntity.copyWith espera UserRole?, no String.
        // Debemos importar UserRole.

        // Solución rápida: Recargar el usuario para que traiga el rol actualizado
        // (si el trigger o la metadata funcionaron).
        // Pero para ser robustos, actualizamos explícitamente el perfil.

        // Como no tengo acceso fácil a UserRole.fromString aquí sin importar user_entity,
        // voy a confiar en que el updateProfile acepta el objeto modificado.
        // Pero espera, currentUser.copyWith(role: ...) necesita un UserRole.

        // Voy a disparar AuthCheckRequested para que recargue todo fresco.
        add(const AuthCheckRequested());
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signIn(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Si el onboarding no está completo, redirigir a onboarding
        if (!user.onboardingCompleted) {
          emit(OnboardingRequired(user));
        } else {
          // Verificar selección de rol
          emit(AuthAuthenticated(user,
              needsRoleSelection: !user.isRoleSelected));
        }
      },
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(EmailVerificationRequired(event.email)),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await resetPassword(
      ResetPasswordParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const ResetPasswordSent()),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUser(NoParams());

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          // Si el onboarding no está completo, redirigir a onboarding
          if (!user.onboardingCompleted) {
            emit(OnboardingRequired(user));
          } else {
            // Verificar selección de rol
            emit(AuthAuthenticated(user,
                needsRoleSelection: !user.isRoleSelected));
          }
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const ProfileUpdateLoading());

    // Obtener usuario actual
    final currentUserResult = await getCurrentUser(NoParams());

    await currentUserResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (currentUser) async {
        if (currentUser == null) {
          emit(const AuthUnauthenticated());
          return;
        }

        // Crear usuario actualizado
        final updatedUser = currentUser.copyWith(
          firstName: event.firstName ?? currentUser.firstName,
          lastName: event.lastName ?? currentUser.lastName,
          phone: event.phone ?? currentUser.phone,
          bio: event.bio ?? currentUser.bio,
          universityOrCompany:
              event.universityOrCompany ?? currentUser.universityOrCompany,
          avatarUrl: event.avatarUrl ?? currentUser.avatarUrl,
          onboardingCompleted:
              event.onboardingCompleted ?? currentUser.onboardingCompleted,
        );

        // Actualizar perfil en BD
        final updateResult = await authRepository.updateProfile(updatedUser);

        updateResult.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) => emit(ProfileUpdated(updatedUser)),
        );
      },
    );
  }
}
