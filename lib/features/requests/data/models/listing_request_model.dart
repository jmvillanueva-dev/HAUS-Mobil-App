import '../../domain/entities/listing_request_entity.dart';

class ListingRequestModel extends ListingRequestEntity {
  const ListingRequestModel({
    required super.id,
    required super.listingId,
    required super.requesterId,
    required super.hostId,
    required super.status,
    super.message,
    required super.createdAt,
    super.listingTitle,
    super.requesterName,
    super.requesterAvatarUrl,
  });

  factory ListingRequestModel.fromJson(Map<String, dynamic> json) {
    return ListingRequestModel(
      id: json['id'],
      listingId: json['listing_id'],
      requesterId: json['requester_id'],
      hostId: json['host_id'],
      status: json['status'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      // Handling joined data if available
      listingTitle: json['listings'] != null ? json['listings']['title'] : null,
      requesterName: json['profiles'] != null
          ? '${json['profiles']['first_name']} ${json['profiles']['last_name']}'
          : null,
      requesterAvatarUrl:
          json['profiles'] != null ? json['profiles']['avatar_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'requester_id': requesterId,
      'host_id': hostId,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
