import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    required String role,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<UserModel?> getProfile(String userId);

  Future<void> updateProfile(UserModel user);

  Future<void> updateUserMetadata(Map<String, dynamic> data);

  Future<bool> signInWithOAuth(OAuthProvider provider);

  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final result = await supabaseClient.auth.signInWithOAuth(
        provider,
        redirectTo: 'hausapp://callback',
      );
      return result;
    } on AuthException catch (e) {
      throw Exception('Error de autenticación social: ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido en login social: $e');
    }
  }

  @override
  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      await supabaseClient.auth.updateUser(
        UserAttributes(data: data),
      );
    } catch (e) {
      throw Exception('Error al actualizar metadata: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('No se pudo iniciar sesión');
      }

      // Obtener datos del perfil desde la tabla profiles
      final profile = await _fetchProfile(response.user!.id);

      return UserModel.fromAuthAndProfile(response.user!, profile);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    required String role,
  }) async {
    try {
      // Preparar metadata para auth.users y trigger
      final metadata = <String, dynamic>{
        'role': role,
      };

      if (firstName != null) metadata['first_name'] = firstName;
      if (lastName != null) metadata['last_name'] = lastName;

      // También agregar display_name para compatibilidad
      if (firstName != null || lastName != null) {
        metadata['display_name'] = '$firstName $lastName'.trim();
      }

      // developer.log('DEBUG: SignUp sending metadata: $metadata', name: 'Auth');

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      if (response.user == null) {
        throw AuthException('No se pudo crear la cuenta');
      }

      // Supabase devuelve identidades vacías si el usuario ya existe
      if (response.user!.identities != null &&
          response.user!.identities!.isEmpty) {
        throw AuthException('User already registered');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      // developer.log('DEBUG: AuthException in SignUp: ${e.message}', name: 'Auth');
      rethrow;
    } catch (e) {
      // developer.log('DEBUG: Generic Exception in SignUp: $e', name: 'Auth');
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) return null;

      // Obtener datos del perfil
      final profile = await _fetchProfile(authUser.id);

      return UserModel.fromAuthAndProfile(authUser, profile);
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<UserModel?> getProfile(String userId) async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      final profile = await _fetchProfile(userId);

      if (authUser != null && authUser.id == userId) {
        return UserModel.fromAuthAndProfile(authUser, profile);
      }

      if (profile == null) return null;

      return UserModel.fromProfileJson(profile);
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      final updateData = user.toProfileUpdateJson();

      if (updateData.isEmpty) return;

      await supabaseClient
          .from('profiles')
          .update(updateData)
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      // Intentar obtener el perfil
      try {
        final profile = await _fetchProfile(user.id);
        return UserModel.fromAuthAndProfile(user, profile);
      } catch (e) {
        // Si falla obtener el perfil, devolver solo datos de auth
        return UserModel.fromSupabaseUser(user);
      }
    });
  }

  /// Helper para obtener datos del perfil desde la tabla profiles
  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      // developer.log('DEBUG: Error fetching profile: $e', name: 'Auth');
      return null;
    }
  }
}
