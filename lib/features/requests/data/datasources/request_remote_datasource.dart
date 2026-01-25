import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/listing_request_model.dart';

abstract class RequestRemoteDataSource {
  Future<ListingRequestModel> sendRequest(
      String listingId, String hostId, String? message);
  Future<List<ListingRequestModel>> getReceivedRequests();
  Future<List<ListingRequestModel>> getSentRequests();
  Future<ListingRequestModel> updateRequestStatus(
      String requestId, String status);
  Future<ListingRequestModel?> getRequestForListing(String listingId);
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final SupabaseClient supabaseClient;

  RequestRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ListingRequestModel> sendRequest(
      String listingId, String hostId, String? message) async {
    final userId = supabaseClient.auth.currentUser!.id;

    final response = await supabaseClient
        .from('listing_requests')
        .insert({
          'listing_id': listingId,
          'host_id': hostId,
          'requester_id': userId,
          'message': message,
          'status': 'pending',
        })
        .select()
        .single();

    return ListingRequestModel.fromJson(response);
  }

  @override
  Future<List<ListingRequestModel>> getReceivedRequests() async {
    final userId = supabaseClient.auth.currentUser!.id;

    // Select with joins to get listing title and requester profile info
    final response = await supabaseClient
        .from('listing_requests')
        .select(
            '*, listings(title), profiles!listing_requests_requester_id_fkey_profiles(first_name, last_name, avatar_url)')
        .eq('host_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ListingRequestModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ListingRequestModel>> getSentRequests() async {
    final userId = supabaseClient.auth.currentUser!.id;

    final response = await supabaseClient
        .from('listing_requests')
        .select('*, listings(title)')
        .eq('requester_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ListingRequestModel.fromJson(json))
        .toList();
  }

  @override
  Future<ListingRequestModel> updateRequestStatus(
      String requestId, String status) async {
    final response = await supabaseClient
        .from('listing_requests')
        .update({'status': status})
        .eq('id', requestId)
        .select(
            '*, listings(title), profiles!listing_requests_requester_id_fkey_profiles(first_name, last_name, avatar_url)')
        .single();

    return ListingRequestModel.fromJson(response);
  }

  @override
  Future<ListingRequestModel?> getRequestForListing(String listingId) async {
    final userId = supabaseClient.auth.currentUser!.id;

    final response = await supabaseClient
        .from('listing_requests')
        .select()
        .eq('listing_id', listingId)
        .eq('requester_id', userId)
        .maybeSingle(); // Returns null if not found

    if (response == null) return null;
    return ListingRequestModel.fromJson(response);
  }
}
