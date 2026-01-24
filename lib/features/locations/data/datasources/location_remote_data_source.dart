import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<UserLocationModel>> getUserLocations(String userId);
  Future<UserLocationModel> createLocation(UserLocationModel location);
  Future<UserLocationModel> updateLocation(UserLocationModel location);
  Future<void> deleteLocation(String locationId);
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
}
