import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/data/ecuador_locations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../listings/presentation/bloc/listing_bloc.dart';
import '../../../listings/presentation/bloc/listing_event.dart';
import '../../../listings/presentation/bloc/listing_state.dart';
import '../../../listings/presentation/widgets/listing_card.dart';
import '../../../matching/presentation/pages/discover_page.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ListingBloc>()..add(LoadListingsEvent()),
      child: const _ExploreContentView(),
    );
  }
}

class _ExploreContentView extends StatefulWidget {
  const _ExploreContentView();

  @override
  State<_ExploreContentView> createState() => _ExploreContentViewState();
}

class _ExploreContentViewState extends State<_ExploreContentView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Estado local del filtro para mantener sincronía
  ListingFilter _currentFilter = const ListingFilter();

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        // Actualizar query manteniendo otros filtros
        _updateFilter(searchQuery: query);
      });
    });
  }

  void _updateFilter({
    double? minPrice,
    double? maxPrice,
    String? housingType,
    String? city,
    List<String>? amenities,
    String? searchQuery,
    bool reset = false,
  }) {
    if (reset) {
      _currentFilter = const ListingFilter();
      _searchController.clear();
    } else {
      // Si se pasa un valor explícito (incluso null), actualizar.
      // Si no se pasa, mantener el actual.
      // Para saber si se quiso pasar null o no, usamos lógica condicional simple:
      // Aquí simplificaré: Reconstruimos el filtro con los nuevos valores o los viejos.
      // Nota: ListingFilter es inmutable.

      _currentFilter = ListingFilter(
        minPrice: minPrice ?? _currentFilter.minPrice,
        maxPrice: maxPrice ?? _currentFilter.maxPrice,
        housingType: housingType ?? _currentFilter.housingType,
        city: city ?? _currentFilter.city,
        amenities: amenities ?? _currentFilter.amenities,
        searchQuery: searchQuery ?? _currentFilter.searchQuery,
      );
    }
    context.read<ListingBloc>().add(UpdateFiltersEvent(filter: _currentFilter));
  }

  // Método auxiliar para actualizar todo el filtro desde el modal
  void _applyModalFilter(ListingFilter newFilter) {
    setState(() {
      // Mantener el query actual, ya que el modal no lo maneja
      _currentFilter = ListingFilter(
        minPrice: newFilter.minPrice,
        maxPrice: newFilter.maxPrice,
        housingType: newFilter.housingType,
        city: newFilter.city,
        amenities: newFilter.amenities,
        searchQuery: _currentFilter.searchQuery,
      );
      context
          .read<ListingBloc>()
          .add(UpdateFiltersEvent(filter: _currentFilter));
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _FilterModalContent(
            scrollController: scrollController,
            initialFilter: _currentFilter,
            onApply: (filter) {
              _applyModalFilter(filter);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header y Buscador
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por zona, precio...',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryDark),
                      prefixIcon:
                          Icon(Icons.search, color: AppTheme.textSecondaryDark),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 16),

                  // Filtros
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(context, 'Filtros', Icons.tune,
                            isPrimary: true),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            context, 'Precio', Icons.keyboard_arrow_down),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            context, 'Ubicación', Icons.keyboard_arrow_down),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            context, 'Tipo', Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lista Vertical
            Expanded(
              child: BlocBuilder<ListingBloc, ListingState>(
                builder: (context, state) {
                  if (state is ListingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ListingsLoaded) {
                    if (state.listings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 64, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text(
                              "No se encontraron resultados",
                              style: TextStyle(
                                  color: AppTheme.textSecondaryDark,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      itemCount: state.listings.length,
                      itemBuilder: (context, index) {
                        return ListingCard(listing: state.listings[index]);
                      },
                    );
                  } else if (state is ListingError) {
                    return Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red)));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DiscoverPage(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.people_rounded, color: Colors.black),
        label: const Text(
          'Descubrir Roomies',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon,
      {bool isPrimary = false}) {
    return GestureDetector(
      onTap: () => _showFilterModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryColor : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isPrimary ? AppTheme.primaryColor : AppTheme.borderDark),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isPrimary ? Colors.black : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontSize: 14,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterModalContent extends StatefulWidget {
  final ScrollController scrollController;
  final ListingFilter initialFilter;
  final Function(ListingFilter) onApply;

  const _FilterModalContent(
      {required this.scrollController,
      required this.initialFilter,
      required this.onApply});

  @override
  State<_FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<_FilterModalContent> {
  late RangeValues _priceRange;
  String? _selectedCity;
  String? _selectedType;
  final List<String> _selectedAmenities = [];

  final List<String> _housingTypes = [
    'Departamento',
    'Casa',
    'Suite',
    'Habitación',
    'Oficina',
    'Local Comercial',
    'Terreno',
    'Otro'
  ];

  final List<String> _amenities = [
    'Wifi',
    'Cocina',
    'Lavadora',
    'TV',
    'Aire Acondicionado',
    'Baño Privado',
    'Gimnasio',
    'Estacionamiento',
    'Pet Friendly'
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar estado con los filtros actuales
    final min = widget.initialFilter.minPrice ?? 0;
    final max = widget.initialFilter.maxPrice ??
        5000; // Asumiendo 5000 como max default ui
    _priceRange = RangeValues(min, max > 5000 ? 5000 : max);

    _selectedCity = widget.initialFilter.city;
    _selectedType = widget.initialFilter.housingType;
    _selectedAmenities.addAll(widget.initialFilter.amenities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: widget.scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = const RangeValues(0, 5000);
                    _selectedCity = null;
                    _selectedType = null;
                    _selectedAmenities.clear();
                  });
                },
                child: const Text('Limpiar Todo',
                    style: TextStyle(color: AppTheme.primaryColor)),
              )
            ],
          ),

          const SizedBox(height: 24),

          // Rango de Precio
          Text(
            'Rango de Precio: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}+',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000,
            divisions: 100,
            activeColor: AppTheme.primaryColor,
            inactiveColor: AppTheme.borderDark,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          const SizedBox(height: 24),

          // Ciudad
          const Text('Ciudad',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            items: EcuadorLocations.cities.map((city) {
              return DropdownMenuItem(
                  value: city,
                  child:
                      Text(city, style: const TextStyle(color: Colors.white)));
            }).toList(),
            onChanged: (val) => setState(() => _selectedCity = val),
            dropdownColor: AppTheme.surfaceDark,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceDark,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              hintText: 'Seleccionar ciudad',
              hintStyle: TextStyle(color: AppTheme.textSecondaryDark),
            ),
          ),
          const SizedBox(height: 24),

          // Tipo de Inmueble
          const Text('Tipo de Inmueble',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _housingTypes.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                },
                backgroundColor: AppTheme.surfaceDark,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Amenities
          const Text('Servicios',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.map((amenity) {
              final isSelected = _selectedAmenities.contains(amenity);
              return FilterChip(
                label: Text(amenity),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAmenities.add(amenity);
                    } else {
                      _selectedAmenities.remove(amenity);
                    }
                  });
                },
                backgroundColor: AppTheme.surfaceDark,
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.white),
                side: BorderSide(
                  color:
                      isSelected ? AppTheme.primaryColor : AppTheme.borderDark,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // Botón Aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final filter = ListingFilter(
                  minPrice: _priceRange.start > 0 ? _priceRange.start : null,
                  maxPrice: _priceRange.end < 5000 ? _priceRange.end : null,
                  city: _selectedCity,
                  housingType: _selectedType,
                  amenities: _selectedAmenities,
                );
                widget.onApply(filter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Aplicar Filtros',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
