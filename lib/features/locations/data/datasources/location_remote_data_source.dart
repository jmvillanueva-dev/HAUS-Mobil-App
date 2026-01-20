import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_location_model.dart';
import '../../domain/entities/user_location_entity.dart';

abstract class LocationRemoteDataSource {
  /// Obtener todas las ubicaciones de un usuario
  Future<List<UserLocationModel>> getUserLocations(String userId);

  /// Obtener ubicaciones por propósito (search/listing)
  Future<List<UserLocationModel>> getUserLocationsByPurpose(
    String userId,
    LocationPurpose purpose,
  );

  /// Obtener la ubicación primaria de un usuario
  Future<UserLocationModel?> getPrimaryLocation(String userId);

  /// Crear una nueva ubicación
  Future<UserLocationModel> createLocation(UserLocationModel location);

  /// Actualizar una ubicación existente
  Future<UserLocationModel> updateLocation(UserLocationModel location);

  /// Eliminar una ubicación
  Future<void> deleteLocation(String locationId);

  /// Establecer ubicación como primaria
  Future<void> setPrimaryLocation(String locationId);
}

@LazySingleton(as: LocationRemoteDataSource)
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  LocationRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<UserLocationModel>> getUserLocations(String userId) async {
    final response = await _supabaseClient
        .from('user_locations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => UserLocationModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<UserLocationModel>> getUserLocationsByPurpose(
    String userId,
    LocationPurpose purpose,
  ) async {
    final response = await _supabaseClient
        .from('user_locations')
        .select()
        .eq('user_id', userId)
        .eq('purpose', purpose.value)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => UserLocationModel.fromJson(json))
        .toList();
  }

  @override
  Future<UserLocationModel?> getPrimaryLocation(String userId) async {
    final response = await _supabaseClient
        .from('user_locations')
        .select()
        .eq('user_id', userId)
        .eq('is_primary', true)
        .maybeSingle();

    if (response == null) return null;
    return UserLocationModel.fromJson(response);
  }

  @override
  Future<UserLocationModel> createLocation(UserLocationModel location) async {
    final response = await _supabaseClient
        .from('user_locations')
        .insert(location.toInsertJson())
        .select()
        .single();

    return UserLocationModel.fromJson(response);
  }

  @override
  Future<UserLocationModel> updateLocation(UserLocationModel location) async {
    final response = await _supabaseClient
        .from('user_locations')
        .update(location.toUpdateJson())
        .eq('id', location.id)
        .select()
        .single();

    return UserLocationModel.fromJson(response);
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    await _supabaseClient.from('user_locations').delete().eq('id', locationId);
  }

  @override
  Future<void> setPrimaryLocation(String locationId) async {
    // El trigger en BD se encarga de desmarcar las demás
    await _supabaseClient
        .from('user_locations')
        .update({'is_primary': true}).eq('id', locationId);
  }
}
