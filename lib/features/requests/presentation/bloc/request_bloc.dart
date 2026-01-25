import 'package:bloc/bloc.dart';
import '../../domain/entities/listing_request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestRepository repository;

  RequestBloc({required this.repository}) : super(RequestInitial()) {
    on<SendRequest>(_onSendRequest);
    on<LoadReceivedRequests>(_onLoadReceivedRequests);
    on<LoadSentRequests>(_onLoadSentRequests);
    on<UpdateRequestStatus>(_onUpdateRequestStatus);
    on<CheckRequestStatus>(_onCheckRequestStatus);
  }

  Future<void> _onSendRequest(
      SendRequest event, Emitter<RequestState> emit) async {
    emit(RequestLoading());
    final result = await repository.sendRequest(
      listingId: event.listingId,
      hostId: event.hostId,
      message: event.message,
    );
    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (request) {
        emit(RequestOperationSuccess(
            message: 'Solicitud enviada con éxito', request: request));
        // Update local status check if needed
        add(CheckRequestStatus(listingId: event.listingId));
      },
    );
  }

  Future<void> _onLoadReceivedRequests(
      LoadReceivedRequests event, Emitter<RequestState> emit) async {
    emit(RequestLoading());
    final result = await repository.getReceivedRequests();
    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (requests) => emit(RequestsLoaded(requests: requests)),
    );
  }

  Future<void> _onLoadSentRequests(
      LoadSentRequests event, Emitter<RequestState> emit) async {
    emit(RequestLoading());
    final result = await repository.getSentRequests();
    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (requests) => emit(RequestsLoaded(requests: requests)),
    );
  }

  Future<void> _onUpdateRequestStatus(
      UpdateRequestStatus event, Emitter<RequestState> emit) async {
    // Optimistic update or loading? Let's show loading for safety
    // Ideally we would copy the current state if it's RequestsLoaded
    final currentState = state;
    List<ListingRequestEntity>? previousRequests;

    if (currentState is RequestsLoaded) {
      previousRequests = currentState.requests;
    }

    emit(RequestLoading());

    final result = await repository.updateRequestStatus(
      requestId: event.requestId,
      status: event.status,
    );

    result.fold(
      (failure) {
        emit(RequestError(message: failure.message));
        // Restore list if possible
        if (previousRequests != null)
          emit(RequestsLoaded(requests: previousRequests));
      },
      (updatedRequest) {
        // Emit success message
        emit(RequestOperationSuccess(
            message:
                'Solicitud ${event.status == 'approved' ? 'aprobada' : 'rechazada'}',
            request: updatedRequest));
        // Reload list to refresh UI correctly
        add(LoadReceivedRequests());
      },
    );
  }

  Future<void> _onCheckRequestStatus(
      CheckRequestStatus event, Emitter<RequestState> emit) async {
    // Don't emit generic loading to avoid full screen loaders, maybe separate state or just careful handling in UI?
    // Using RequestLoading might be too aggressive if used on page load.
    // Let's assume the UI handles null/loading gracefully for this specific check.

    final result = await repository.getRequestForListing(event.listingId);
    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (request) => emit(RequestStatusLoaded(request: request)),
    );
  }
}
