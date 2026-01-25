import 'package:equatable/equatable.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object> get props => [];
}

class SendRequest extends RequestEvent {
  final String listingId;
  final String hostId;
  final String? message;

  const SendRequest({
    required this.listingId,
    required this.hostId,
    this.message,
  });

  @override
  List<Object> get props => [listingId, hostId, message ?? ''];
}

class LoadReceivedRequests extends RequestEvent {}

class LoadSentRequests extends RequestEvent {}

class UpdateRequestStatus extends RequestEvent {
  final String requestId;
  final String status;

  const UpdateRequestStatus({
    required this.requestId,
    required this.status,
  });

  @override
  List<Object> get props => [requestId, status];
}

class CheckRequestStatus extends RequestEvent {
  final String listingId;

  const CheckRequestStatus({required this.listingId});

  @override
  List<Object> get props => [listingId];
}
