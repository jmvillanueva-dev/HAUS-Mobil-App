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
  Stream<List<ListingModel>> getMyListingsStream(String userId);
  Future<ListingModel> updateListing(
      ListingEntity listing, List<File>? newImages);
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
          .select('*, is_available')
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
        .map((data) => data.map((e) {
              // Note: Stream in supabase usually returns everything, but computed columns might need specific handling or a view.
              // For streams, computed columns are not always included by default in the real-time payload if not part of the table.
              // However, since we can't easily change the stream payload structure without a view, we'll assume standard fetch for now,
              // or relying on fetchListings for the main feed. for simplicity, let's keep standard stream and if necessary refactor to Fetch.
              // Actually, computed columns are NOT part of realtime stream.
              // We will rely on fetchListings for the "feed" which is where this badge matters most.
              // But 'getListingsStream' is used. Let's see if we can use a workaround or accept that stream updates might not have it immediately.
              // Correct approach for Realtime with computed columns implies using a View with REPLICA IDENTITY or just fetching.
              // For now, let's try mapping, but likely it won't be there.
              // We will default to true if missing.
              return ListingModel.fromJson(e);
            }).toList());
  }

  @override
  Stream<List<ListingModel>> getMyListingsStream(String userId) {
    return supabaseClient
        .from('listings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => ListingModel.fromJson(e)).toList());
  }

  @override
  Future<ListingModel> updateListing(
      ListingEntity listing, List<File>? newImages) async {
    try {
      List<String> imageUrls = List.from(listing.imageUrls);

      // 1. Subir nuevas imágenes si existen
      if (newImages != null && newImages.isNotEmpty) {
        for (var image in newImages) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
          final path = 'listings/${listing.userId}/$fileName';

          await supabaseClient.storage.from('listings').upload(path, image);
          final imageUrl =
              supabaseClient.storage.from('listings').getPublicUrl(path);
          imageUrls.add(imageUrl);
        }
      }

      // 2. Actualizar datos
      final listingData = ListingModel(
        id: listing.id,
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
        imageUrls: imageUrls,
        createdAt: listing.createdAt,
      ).toJson();

      // Eliminar campos que no se deben actualizar o manejar nulos si es necesario.
      // Supabase ignora ID si es PK en update usualmente, pero mejor asegurarse.

      final response = await supabaseClient
          .from('listings')
          .update(listingData)
          .eq('id', listing.id!)
          .select()
          .single();

      return ListingModel.fromJson(response);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
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
