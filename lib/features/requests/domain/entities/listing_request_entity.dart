import 'package:equatable/equatable.dart';

class ListingRequestEntity extends Equatable {
  final String id;
  final String listingId;
  final String requesterId;
  final String hostId;
  final String status;
  final String? message;
  final DateTime createdAt;

  // Optional: details for UI display (joined via queries or additional fetches)
  final String? listingTitle;
  final String? requesterName;
  final String? requesterAvatarUrl;

  const ListingRequestEntity({
    required this.id,
    required this.listingId,
    required this.requesterId,
    required this.hostId,
    required this.status,
    this.message,
    required this.createdAt,
    this.listingTitle,
    this.requesterName,
    this.requesterAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        requesterId,
        hostId,
        status,
        message,
        createdAt,
        listingTitle,
        requesterName,
        requesterAvatarUrl,
      ];

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
