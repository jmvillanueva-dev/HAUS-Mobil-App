import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../models/listing_model.dart';
import '../../domain/entities/listing_entity.dart';
import 'package:injectable/injectable.dart';

abstract class ListingRemoteDataSource {
  Future<ListingModel> uploadListing(ListingEntity listing, List<File> images);
  Future<List<ListingModel>> fetchListings();
  Stream<List<ListingModel>> getListingsStream();
  Future<void> deleteListing(String id);
}

@LazySingleton(as: ListingRemoteDataSource)
class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  final SupabaseClient supabaseClient;

  ListingRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ListingModel> uploadListing(
      ListingEntity listing, List<File> images) async {
    try {
      // 1. Subir imágenes
      List<String> uploadedUrls = [];
      for (var image in images) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final path = 'listings/${listing.userId}/$fileName';

        await supabaseClient.storage.from('listings').upload(path, image);
        final imageUrl =
            supabaseClient.storage.from('listings').getPublicUrl(path);
        uploadedUrls.add(imageUrl);
      }

      // 2. Guardar datos en tabla
      final listingData = ListingModel(
        userId: listing.userId,
        title: listing.title,
        description: listing.description,
        price: listing.price,
        housingType: listing.housingType,
        city: listing.city,
        neighborhood: listing.neighborhood,
        address: listing.address,
        latitude: listing.latitude,
        longitude: listing.longitude,
        amenities: listing.amenities,
        houseRules: listing.houseRules,
        imageUrls: uploadedUrls,
      ).toJson();

      final response = await supabaseClient
          .from('listings')
          .insert(listingData)
          .select()
          .single();
      return ListingModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ListingModel>> fetchListings() async {
    try {
      final response = await supabaseClient
          .from('listings')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((e) => ListingModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Stream<List<ListingModel>> getListingsStream() {
    return supabaseClient
        .from('listings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => ListingModel.fromJson(e)).toList());
  }

  @override
  Future<void> deleteListing(String id) async {
    try {
      await supabaseClient.from('listings').delete().eq('id', id);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
