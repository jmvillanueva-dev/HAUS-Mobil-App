import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_listing.dart';
import '../../domain/usecases/delete_listing.dart';
import '../../domain/usecases/get_listings.dart';
import '../../domain/usecases/get_listings_stream.dart';
import '../../domain/usecases/get_my_listings_stream.dart';
import '../../domain/usecases/update_listing.dart';
import 'listing_event.dart';
import 'listing_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final CreateListing createListing;
  final GetListings getListings;
  final GetListingsStream getListingsStream;
  final GetMyListingsStream getMyListingsStream;
  final UpdateListing updateListing;
  final DeleteListing deleteListing;

  ListingBloc({
    required this.createListing,
    required this.getListings,
    required this.getListingsStream,
    required this.getMyListingsStream,
    required this.updateListing,
    required this.deleteListing,
  }) : super(ListingInitial()) {
    on<LoadListingsEvent>(_onLoadListings);
    on<LoadMyListingsEvent>(_onLoadMyListings);
    on<CreateListingEvent>(_onCreateListing);
    on<UpdateListingEvent>(_onUpdateListing);
    on<DeleteListingEvent>(_onDeleteListing);
  }

  Future<void> _onLoadListings(
      LoadListingsEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());

    await emit.forEach(
      getListingsStream(NoParams()),
      onData: (result) => result.fold(
        (failure) => ListingError(message: failure.message),
        (listings) => ListingsLoaded(listings: listings),
      ),
      onError: (_, __) => const ListingError(message: 'Error en tiempo real'),
    );
  }

  Future<void> _onLoadMyListings(
      LoadMyListingsEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());

    await emit.forEach(
      getMyListingsStream(event.userId),
      onData: (result) => result.fold(
        (failure) => ListingError(message: failure.message),
        (listings) => ListingsLoaded(listings: listings),
      ),
      onError: (_, __) => const ListingError(message: 'Error en tiempo real'),
    );
  }

  Future<void> _onCreateListing(
      CreateListingEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());
    final result = await createListing(
      CreateListingParams(listing: event.listing, images: event.images),
    );
    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (listing) => emit(const ListingOperationSuccess(
          message: 'Publicación creada exitosamente')),
    );
  }

  Future<void> _onUpdateListing(
      UpdateListingEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());
    final result = await updateListing(
      UpdateListingParams(listing: event.listing, newImages: event.newImages),
    );
    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (listing) => emit(const ListingOperationSuccess(
          message: 'Publicación actualizada exitosamente')),
    );
  }

  Future<void> _onDeleteListing(
      DeleteListingEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());
    final result = await deleteListing(event.listingId);
    result.fold(
      (failure) => emit(ListingError(message: failure.message)),
      (_) {
        emit(const ListingOperationSuccess(message: 'Publicación eliminada'));
        // add(LoadListingsEvent()); // Recargar la lista después de borrar - REMOVIDO: El stream se actualiza solo
      },
    );
  }
}
