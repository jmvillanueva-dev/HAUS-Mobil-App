/// Datos de ciudades y barrios de Ecuador
/// Usado para selectores de ubicación en la app

class EcuadorLocations {
  /// Lista de ciudades principales de Ecuador
  static const List<String> cities = [
    'Quito',
    'Guayaquil',
    'Cuenca',
    'Santo Domingo',
    'Machala',
    'Durán',
    'Manta',
    'Portoviejo',
    'Loja',
    'Ambato',
    'Esmeraldas',
    'Quevedo',
    'Riobamba',
    'Milagro',
    'Ibarra',
    'La Libertad',
    'Babahoyo',
    'Sangolquí',
    'Latacunga',
    'Tulcán',
  ];

  /// Barrios/sectores por ciudad
  static const Map<String, List<String>> neighborhoodsByCity = {
    'Quito': [
      'La Carolina',
      'La Floresta',
      'La Mariscal',
      'Iñaquito',
      'Cumbayá',
      'Tumbaco',
      'El Batán',
      'González Suárez',
      'Bellavista',
      'La Paz',
      'El Bosque',
      'Quito Tenis',
      'Plaza de las Américas',
      'El Inca',
      'Cotocollao',
      'Carcelén',
      'Calderón',
      'Carapungo',
      'Conocoto',
      'Valle de los Chillos',
      'San Rafael',
      'Centro Histórico',
      'La Vicentina',
      'La Gasca',
      'La Magdalena',
      'Chillogallo',
      'Quitumbe',
      'Solanda',
      'La Argelia',
      'Otro',
    ],
    'Guayaquil': [
      'Samborondón',
      'Urdesa',
      'Ceibos',
      'Kennedy',
      'Alborada',
      'Sauces',
      'Centro',
      'Malecón',
      'Puerto Santa Ana',
      'Miraflores',
      'Bellavista',
      'Ciudadela Universitaria',
      'La Garzota',
      'Los Ceibos',
      'Atarazana',
      'La Aurora',
      'Vía a la Costa',
      'Guayacanes',
      'Mucho Lote',
      'Vergeles',
      'Otro',
    ],
    'Cuenca': [
      'Centro Histórico',
      'El Vergel',
      'Yanuncay',
      'Totoracocha',
      'El Batán',
      'Miraflores',
      'Puertas del Sol',
      'Don Bosco',
      'Ricaurte',
      'Baños',
      'San Sebastián',
      'El Vecino',
      'Monay',
      'Misicata',
      'Sayausí',
      'Otro',
    ],
    'Santo Domingo': [
      'Centro',
      'Urbanización del Toachi',
      'Cooperativa 30 de Julio',
      'Chiguilpe',
      'Abraham Calazacón',
      'Bombolí',
      'Las Palmas',
      'Nuevo Israel',
      'Otro',
    ],
    'Machala': [
      'Centro',
      'La Providencia',
      'Las Brisas',
      'El Bosque',
      'La Florida',
      '9 de Mayo',
      'Urseza',
      'Puerto Bolívar',
      'Otro',
    ],
    'Durán': [
      'Centro',
      'Abel Gilbert',
      'El Recreo',
      'Panorama',
      'Las Orquídeas',
      'Primavera',
      'Otro',
    ],
    'Manta': [
      'Centro',
      'Barrio Lindo',
      'Umiña',
      'Tarqui',
      'Los Esteros',
      'La Aurora',
      'El Murcielago',
      'Otro',
    ],
    'Portoviejo': [
      'Centro',
      'Los Tamarindos',
      '12 de Marzo',
      'Andrés de Vera',
      'Picoazá',
      'San Pablo',
      'Otro',
    ],
    'Loja': [
      'Centro',
      'El Valle',
      'San Sebastián',
      'La Tebaida',
      'Zamora Huayco',
      'Ciudadela Universitaria',
      'Otro',
    ],
    'Ambato': [
      'Centro',
      'Ficoa',
      'Miraflores',
      'Huachi Chico',
      'La Matriz',
      'Atocha',
      'Ingahurco',
      'Otro',
    ],
    'Esmeraldas': [
      'Centro',
      'Aire Libre',
      '15 de Marzo',
      'Las Palmas',
      'Propicia',
      'Otro',
    ],
    'Quevedo': [
      'Centro',
      'San Camilo',
      'Venus del Río',
      '7 de Octubre',
      'San Cristóbal',
      'Otro',
    ],
    'Riobamba': [
      'Centro',
      'La Estación',
      'Bellavista',
      'El Batán',
      'La Politécnica',
      'San Alfonso',
      'Otro',
    ],
    'Milagro': [
      'Centro',
      'Las Piñas',
      'Los Chirijos',
      'Rosa María',
      'Otro',
    ],
    'Ibarra': [
      'Centro',
      'El Sagrario',
      'Caranqui',
      'Yacucalle',
      'La Victoria',
      'Priorato',
      'Otro',
    ],
    'La Libertad': [
      'Centro',
      'Ballenita',
      'Punta Carnero',
      'Costa de Oro',
      'Otro',
    ],
    'Babahoyo': [
      'Centro',
      'El Salto',
      'Barreiro',
      'Clemente Baquerizo',
      'Otro',
    ],
    'Sangolquí': [
      'Centro',
      'San Rafael',
      'Santa Rosa',
      'Selva Alegre',
      'San Pedro de Taboada',
      'Otro',
    ],
    'Latacunga': [
      'Centro',
      'La Matriz',
      'San Buenaventura',
      'Eloy Alfaro',
      'Ignacio Flores',
      'Otro',
    ],
    'Tulcán': [
      'Centro',
      'González Suárez',
      'Julio Andrade',
      'Rumichaca',
      'Otro',
    ],
  };

  /// Obtener barrios de una ciudad
  static List<String> getNeighborhoods(String city) {
    return neighborhoodsByCity[city] ?? ['Centro', 'Otro'];
  }

  /// Buscar ciudades que coincidan con un texto
  static List<String> searchCities(String query) {
    if (query.isEmpty) return cities;
    final lowerQuery = query.toLowerCase();
    return cities
        .where((city) => city.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Buscar barrios que coincidan con un texto
  static List<String> searchNeighborhoods(String city, String query) {
    final neighborhoods = getNeighborhoods(city);
    if (query.isEmpty) return neighborhoods;
    final lowerQuery = query.toLowerCase();
    return neighborhoods
        .where((n) => n.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
