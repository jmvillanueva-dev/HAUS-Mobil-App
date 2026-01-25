import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_preferences_model.dart';

/// Datasource remoto para preferencias de usuario (Supabase)
abstract class PreferencesRemoteDatasource {
  /// Obtener preferencias del usuario actual
  Future<UserPreferencesModel?> getMyPreferences();

  /// Obtener preferencias de un usuario específico
  Future<UserPreferencesModel?> getUserPreferences(String userId);

  /// Crear preferencias
  Future<UserPreferencesModel> createPreferences(
      UserPreferencesModel preferences);

  /// Actualizar preferencias
  Future<UserPreferencesModel> updatePreferences(
      UserPreferencesModel preferences);

  /// Eliminar preferencias
  Future<void> deletePreferences();

  /// Verificar si el usuario tiene preferencias
  Future<bool> hasPreferences();
}

/// Implementación del datasource con Supabase
class PreferencesRemoteDatasourceImpl implements PreferencesRemoteDatasource {
  final SupabaseClient _supabase;

  PreferencesRemoteDatasourceImpl(this._supabase);

  String get _currentUserId => _supabase.auth.currentUser!.id;

  @override
  Future<UserPreferencesModel?> getMyPreferences() async {
    final response = await _supabase
        .from('user_preferences')
        .select()
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (response == null) return null;
    return UserPreferencesModel.fromJson(response);
  }

  @override
  Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    final response = await _supabase
        .from('user_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserPreferencesModel.fromJson(response);
  }

  @override
  Future<UserPreferencesModel> createPreferences(
      UserPreferencesModel preferences) async {
    final data = preferences.toJson();
    data['user_id'] = _currentUserId;

    final response =
        await _supabase.from('user_preferences').insert(data).select().single();

    return UserPreferencesModel.fromJson(response);
  }

  @override
  Future<UserPreferencesModel> updatePreferences(
      UserPreferencesModel preferences) async {
    final response = await _supabase
        .from('user_preferences')
        .update(preferences.toJson())
        .eq('user_id', _currentUserId)
        .select()
        .single();

    return UserPreferencesModel.fromJson(response);
  }

  @override
  Future<void> deletePreferences() async {
    await _supabase
        .from('user_preferences')
        .delete()
        .eq('user_id', _currentUserId);
  }

  @override
  Future<bool> hasPreferences() async {
    final response = await _supabase
        .from('user_preferences')
        .select('preferences_completed')
        .eq('user_id', _currentUserId)
        .maybeSingle();

    if (response == null) return false;
    return response['preferences_completed'] as bool? ?? false;
  }
}
