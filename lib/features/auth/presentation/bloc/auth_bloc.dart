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
        // Si el perfil no está completo, redirigir a onboarding
        if (!user.isProfileComplete) {
          emit(OnboardingRequired(user));
        } else {
          emit(AuthAuthenticated(user));
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
          // Si el perfil no está completo, redirigir a onboarding
          if (!user.isProfileComplete) {
            emit(OnboardingRequired(user));
          } else {
            emit(AuthAuthenticated(user));
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
