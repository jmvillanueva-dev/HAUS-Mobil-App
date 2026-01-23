import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_listing.dart';
import '../../domain/usecases/delete_listing.dart';
import '../../domain/usecases/get_listings.dart';
import 'listing_event.dart';
import 'listing_state.dart';
import 'package:injectable/injectable.dart';


@injectable
class ListingBloc extends Bloc<ListingEvent, ListingState> {
  final CreateListing createListing;
  final GetListings getListings;
  final DeleteListing deleteListing;

  ListingBloc({
    required this.createListing,
    required this.getListings,
    required this.deleteListing,
  }) : super(ListingInitial()) {
    on<LoadListingsEvent>(_onLoadListings);
    on<CreateListingEvent>(_onCreateListing);
    on<DeleteListingEvent>(_onDeleteListing);
  }

  Future<void> _onLoadListings(
      LoadListingsEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());
    final result = await getListings(NoParams());
    result.fold(
      (failure) => emit(ListingError(message: failure.message)), // Asume que Failure tiene propiedad message, sino usa toString()
      (listings) => emit(ListingsLoaded(listings: listings)),
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
      (listing) => emit(const ListingOperationSuccess(message: 'Publicación creada exitosamente')),
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
        add(LoadListingsEvent()); // Recargar la lista después de borrar
      },
    );
  }
}