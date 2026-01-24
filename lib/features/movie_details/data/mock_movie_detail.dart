// Mock data para pantalla de detalle de película

class MockMovieDetail {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final int year;
  final int runtime;
  final double rating;
  final String synopsis;
  final List<String> genres;
  final List<MockCastMember> cast;
  final List<MockTrailer> trailers;
  final MockAIRecommendation aiRecommendation;
  final bool inWatchlist;
  final bool isFavorite;
  final bool isSeen;

  const MockMovieDetail({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.year,
    required this.runtime,
    required this.rating,
    required this.synopsis,
    required this.genres,
    required this.cast,
    required this.trailers,
    required this.aiRecommendation,
    this.inWatchlist = false,
    this.isFavorite = false,
    this.isSeen = false,
  });

  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }
}

class MockCastMember {
  final int id;
  final String name;
  final String character;
  final String? profileUrl;

  const MockCastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profileUrl,
  });
}

class MockTrailer {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String quality;
  final String? youtubeKey;

  const MockTrailer({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.quality,
    this.youtubeKey,
  });
}

class MockAIRecommendation {
  final List<String> bullets;
  final List<String> tags;

  const MockAIRecommendation({
    required this.bullets,
    required this.tags,
  });
}

/// Ejemplo: Dune Part Two
const mockDuneDetail = MockMovieDetail(
  id: 1,
  title: 'Dune: Part Two',
  posterUrl: 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
  backdropUrl: 'https://image.tmdb.org/t/p/original/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
  year: 2024,
  runtime: 166,
  rating: 8.9,
  synopsis: 'Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia. Al enfrentarse a una elección entre el amor de su vida y el destino del universo conocido, debe evitar un futuro terrible que solo él puede prever.',
  genres: ['Sci-Fi', 'Aventura', 'Drama'],
  cast: [
    MockCastMember(
      id: 1,
      name: 'Timothée Chalamet',
      character: 'Paul Atreides',
      profileUrl: 'https://image.tmdb.org/t/p/w185/BE2sdjpgsa2rNTFa66f7upkaOP.jpg',
    ),
    MockCastMember(
      id: 2,
      name: 'Zendaya',
      character: 'Chani',
      profileUrl: 'https://image.tmdb.org/t/p/w185/tylFh98WBYBmJtm9tAU9zbbRANT.jpg',
    ),
    MockCastMember(
      id: 3,
      name: 'Rebecca Ferguson',
      character: 'Lady Jessica',
      profileUrl: 'https://image.tmdb.org/t/p/w185/lJloTOheuQSirSLXNA3JHsrMNfH.jpg',
    ),
    MockCastMember(
      id: 4,
      name: 'Josh Brolin',
      character: 'Gurney Halleck',
      profileUrl: 'https://image.tmdb.org/t/p/w185/sX2aS5F7LxYzJlAPrq5WVrwFHN9.jpg',
    ),
    MockCastMember(
      id: 5,
      name: 'Austin Butler',
      character: 'Feyd-Rautha',
      profileUrl: 'https://image.tmdb.org/t/p/w185/bVUsM4aYiHbeSYE1xAw2H5Z1ANU.jpg',
    ),
    MockCastMember(
      id: 6,
      name: 'Florence Pugh',
      character: 'Princess Irulan',
      profileUrl: 'https://image.tmdb.org/t/p/w185/fhEsn35uAwUZy37M2YcHfVL6Y7N.jpg',
    ),
  ],
  trailers: [
    MockTrailer(
      id: '1',
      title: 'Official Trailer #3',
      thumbnailUrl: 'https://image.tmdb.org/t/p/w500/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
      duration: '2:14',
      quality: '4K Dolby Atmos',
      youtubeKey: 'Way9Dexny3w',
    ),
    MockTrailer(
      id: '2',
      title: 'Behind the Scenes',
      thumbnailUrl: 'https://image.tmdb.org/t/p/w500/gorGtOIOFg0T1MnGrFZKTU0LhFY.jpg',
      duration: '5:45',
      quality: 'HD',
      youtubeKey: 'U2Qp5pL3ovA',
    ),
    MockTrailer(
      id: '3',
      title: 'Final Trailer',
      thumbnailUrl: 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
      duration: '3:02',
      quality: '4K HDR',
      youtubeKey: 'Way9Dexny3w',
    ),
  ],
  aiRecommendation: MockAIRecommendation(
    bullets: [
      'Experiencia visual inmersiva de ritmo pausado, ideal si buscas una narrativa épica y densa.',
      'Requiere haber visto la primera entrega para entender el contexto completo.',
      'Recomendada si te gustaron "Blade Runner 2049" o "Interstellar".',
    ],
    tags: ['MIND-BENDING', 'GRITTY', 'LARGA DURACIÓN'],
  ),
  inWatchlist: true,
  isFavorite: true,
  isSeen: true,
);

/// Ejemplo alternativo para testing
const mockInceptionDetail = MockMovieDetail(
  id: 2,
  title: 'Inception',
  posterUrl: 'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
  backdropUrl: 'https://image.tmdb.org/t/p/original/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
  year: 2010,
  runtime: 148,
  rating: 8.8,
  synopsis: 'Dom Cobb es un ladrón con una extraña habilidad para entrar en los sueños de la gente y robarles los secretos de sus subconscientes. Su capacidad lo ha convertido en muy solicitado en el mundo del espionaje corporativo, pero también le ha costado todo lo que ama.',
  genres: ['Sci-Fi', 'Acción', 'Thriller'],
  cast: [
    MockCastMember(
      id: 10,
      name: 'Leonardo DiCaprio',
      character: 'Dom Cobb',
      profileUrl: 'https://image.tmdb.org/t/p/w185/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
    ),
    MockCastMember(
      id: 11,
      name: 'Joseph Gordon-Levitt',
      character: 'Arthur',
      profileUrl: 'https://image.tmdb.org/t/p/w185/dhv9p8bEr9Mj7kDne7HNmIX3v0e.jpg',
    ),
    MockCastMember(
      id: 12,
      name: 'Elliot Page',
      character: 'Ariadne',
      profileUrl: 'https://image.tmdb.org/t/p/w185/xNWJNftBR6FWJWJpNdjvJvJlFpx.jpg',
    ),
  ],
  trailers: [
    MockTrailer(
      id: '10',
      title: 'Official Trailer',
      thumbnailUrl: 'https://image.tmdb.org/t/p/w500/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg',
      duration: '2:28',
      quality: 'HD',
      youtubeKey: 'YoHD9XEInc0',
    ),
  ],
  aiRecommendation: MockAIRecommendation(
    bullets: [
      'Película que requiere atención total - no apta para ver distraído.',
      'Múltiples capas narrativas que recompensan los rewatches.',
      'Si te gustan los puzzles cinematográficos, esta es imprescindible.',
    ],
    tags: ['MIND-BENDING', 'COMPLEJA', 'REWATCHABLE'],
  ),
  inWatchlist: false,
  isFavorite: false,
  isSeen: false,
);

/// Función para obtener mock detail por ID
MockMovieDetail getMockMovieDetail(int id) {
  switch (id) {
    case 1:
      return mockDuneDetail;
    case 2:
      return mockInceptionDetail;
    default:
      return mockDuneDetail;
  }
}
