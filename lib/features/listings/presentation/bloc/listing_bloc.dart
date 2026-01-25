import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_listing.dart';
import '../../domain/usecases/delete_listing.dart';
import '../../domain/usecases/get_listings.dart';
import '../../domain/usecases/get_listings_stream.dart';
import '../../domain/usecases/get_my_listings_stream.dart';
import '../../domain/usecases/update_listing.dart';
import '../../domain/entities/listing_entity.dart';
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

  List<ListingEntity> _allListings = [];
  ListingFilter _currentFilter = const ListingFilter();

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
    on<UpdateFiltersEvent>(_onUpdateFilters);
  }

  Future<void> _onLoadListings(
      LoadListingsEvent event, Emitter<ListingState> emit) async {
    emit(ListingLoading());

    await emit.forEach(
      getListingsStream(NoParams()),
      onData: (result) => result.fold(
        (failure) => ListingError(message: failure.message),
        (listings) {
          _allListings = listings;
          return ListingsLoaded(listings: _applyFilter(listings));
        },
      ),
      onError: (_, __) => const ListingError(message: 'Error en tiempo real'),
    );
  }

  void _onUpdateFilters(UpdateFiltersEvent event, Emitter<ListingState> emit) {
    _currentFilter = event.filter;
    // Emitir nuevo estado con lista filtrada basado en _allListings cacheada
    emit(ListingsLoaded(listings: _applyFilter(_allListings)));
  }

  List<ListingEntity> _applyFilter(List<ListingEntity> listings) {
    if (_currentFilter.isEmpty) return listings;

    return listings.where((listing) {
      // Precio
      if (_currentFilter.minPrice != null &&
          listing.price < _currentFilter.minPrice!) return false;
      if (_currentFilter.maxPrice != null &&
          listing.price > _currentFilter.maxPrice!) return false;

      // Tipo (ignorar mayúsculas)
      if (_currentFilter.housingType != null &&
          listing.housingType.toLowerCase() !=
              _currentFilter.housingType!.toLowerCase()) {
        return false;
      }

      // Ciudad
      if (_currentFilter.city != null && listing.city != _currentFilter.city)
        return false;

      // Amenities (debe contener TODOS los seleccionados)
      if (_currentFilter.amenities.isNotEmpty) {
        final listingAmenities =
            listing.amenities.map((e) => e.toLowerCase()).toList();
        for (var filterAmenity in _currentFilter.amenities) {
          if (!listingAmenities.contains(filterAmenity.toLowerCase())) {
            return false;
          }
        }
      }

      // Busqueda de texto (Titulo, Descripcion, Direccion)
      if (_currentFilter.searchQuery != null &&
          _currentFilter.searchQuery!.isNotEmpty) {
        final query = _currentFilter.searchQuery!.toLowerCase();
        final content =
            '${listing.title} ${listing.description} ${listing.address} ${listing.neighborhood} ${listing.city}'
                .toLowerCase();
        if (!content.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
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
      },
    );
  }
}
