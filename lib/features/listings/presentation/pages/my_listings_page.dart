import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../bloc/listing_bloc.dart';
import '../bloc/listing_event.dart';
import '../bloc/listing_state.dart';
import '../../domain/entities/listing_entity.dart';
import 'create_listing_page.dart'; // For editing

class MyListingsPage extends StatefulWidget {
  final String userId;
  const MyListingsPage({super.key, required this.userId});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  late ListingBloc _listingBloc;

  @override
  void initState() {
    super.initState();
    _listingBloc = sl<ListingBloc>()
      ..add(LoadMyListingsEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    _listingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _listingBloc,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Mis Publicaciones'),
          backgroundColor: AppTheme.backgroundDark,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<ListingBloc>(),
                  child: CreateListingPage(userId: widget.userId),
                ),
              ),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocBuilder<ListingBloc, ListingState>(
          builder: (context, state) {
            if (state is ListingsLoaded) {
              if (state.listings.isEmpty) {
                return Center(
                  child: Text(
                    'No tienes publicaciones aún',
                    style: TextStyle(color: AppTheme.textSecondaryDark),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.listings.length,
                itemBuilder: (context, index) {
                  final listing = state.listings[index];
                  return _buildListingCard(context, listing);
                },
              );
            } else if (state is ListingError) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, ListingEntity listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: listing.imageUrls.isNotEmpty
                  ? Image.network(
                      listing.imageUrls.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey, width: 60, height: 60),
                    )
                  : Container(color: Colors.grey, width: 60, height: 60),
            ),
            title: Text(
              listing.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${listing.housingType} • \$${listing.price.toStringAsFixed(0)}',
              style: TextStyle(color: AppTheme.textSecondaryDark),
            ),
          ),
          const Divider(color: AppTheme.borderDark, height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<ListingBloc>(),
                        child: CreateListingPage(
                            userId: widget.userId, listingToEdit: listing),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                label: const Text('Editar',
                    style: TextStyle(color: AppTheme.primaryColor)),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, listing),
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text('Eliminar',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ListingEntity listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Eliminar publicación',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta publicación? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _listingBloc.add(DeleteListingEvent(listingId: listing.id!));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
