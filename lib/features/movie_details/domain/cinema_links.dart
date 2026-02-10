import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../home/domain/entities/movie_details.dart';

/// Cadena de cine regional
class CinemaChain {
  final String name;
  final String url;
  final IconData icon;

  const CinemaChain({
    required this.name,
    required this.url,
    this.icon = Icons.movie_outlined,
  });
}

/// Mapeo de cadenas de cine por código de país
/// URLs apuntan a Google Maps para buscar sucursales cercanas
const Map<String, List<CinemaChain>> _cinemaChainsByRegion = {
  'MX': [
    CinemaChain(name: 'Cinépolis', url: 'https://www.google.com/maps/search/Cinépolis'),
    CinemaChain(name: 'Cinemex', url: 'https://www.google.com/maps/search/Cinemex'),
  ],
  'ES': [
    CinemaChain(name: 'Yelmo Cines', url: 'https://www.google.com/maps/search/Yelmo+Cines'),
    CinemaChain(name: 'Cinesa', url: 'https://www.google.com/maps/search/Cinesa'),
  ],
  'CO': [
    CinemaChain(name: 'Cine Colombia', url: 'https://www.google.com/maps/search/Cine+Colombia'),
    CinemaChain(name: 'Cinépolis', url: 'https://www.google.com/maps/search/Cinépolis'),
  ],
  'AR': [
    CinemaChain(name: 'Hoyts', url: 'https://www.google.com/maps/search/Hoyts+cine'),
    CinemaChain(name: 'Cinemark', url: 'https://www.google.com/maps/search/Cinemark'),
  ],
  'CL': [
    CinemaChain(name: 'CineHoyts', url: 'https://www.google.com/maps/search/CineHoyts'),
    CinemaChain(name: 'Cinemark', url: 'https://www.google.com/maps/search/Cinemark'),
  ],
  'PE': [
    CinemaChain(name: 'Cineplanet', url: 'https://www.google.com/maps/search/Cineplanet'),
    CinemaChain(name: 'Cinemark', url: 'https://www.google.com/maps/search/Cinemark'),
  ],
  'US': [
    CinemaChain(name: 'AMC', url: 'https://www.google.com/maps/search/AMC+Theatres'),
    CinemaChain(name: 'Regal', url: 'https://www.google.com/maps/search/Regal+Cinemas'),
  ],
};

/// Obtiene las cadenas de cine para un país
List<CinemaChain> getCinemaChains(String countryCode) {
  return _cinemaChainsByRegion[countryCode.toUpperCase()] ??
      const [
        CinemaChain(
          name: 'Google Maps',
          url: 'https://www.google.com/maps/search/cinemas+near+me',
          icon: Icons.location_on_outlined,
        ),
      ];
}

/// Determina si una película está actualmente en cines.
/// Basado puramente en la fecha de estreno:
/// - releaseDate fue hace menos de 90 días, O
/// - releaseDate es en el futuro (próximo estreno)
bool isInTheaters(MovieDetails details) {
  final releaseDateStr = details.releaseDate;

  debugPrint('🎬 isInTheaters: "${details.title}" '
      'status=${details.status}, releaseDate=$releaseDateStr');

  if (releaseDateStr == null || releaseDateStr.isEmpty) return false;

  final releaseDate = DateTime.tryParse(releaseDateStr);
  if (releaseDate == null) return false;

  final now = DateTime.now();
  final daysSinceRelease = now.difference(releaseDate).inDays;

  debugPrint('🎬 isInTheaters: daysSinceRelease=$daysSinceRelease');

  // Película en cines si:
  // 1. Aún no se ha estrenado (próximo estreno)
  // 2. Se estrenó hace menos de 90 días
  return daysSinceRelease <= 90;
}
