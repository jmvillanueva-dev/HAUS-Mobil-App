import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationModel>> getMyLocations(String userId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final SupabaseClient supabaseClient;

  LocationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<LocationModel>> getMyLocations(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_locations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LocationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
