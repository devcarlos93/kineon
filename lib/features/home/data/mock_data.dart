/// Mock data para la pantalla Home
/// Usar hasta que se integre con TMDB API

class MockMovie {
  final int id;
  final String title;
  final String posterUrl;
  final String? backdropUrl;
  final String genre;
  final int year;
  final double rating;
  final int? runtime;
  final String? aiReason;
  final bool inWatchlist;

  const MockMovie({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.backdropUrl,
    required this.genre,
    required this.year,
    this.rating = 0.0,
    this.runtime,
    this.aiReason,
    this.inWatchlist = false,
  });
}

/// Películas para "Para ti hoy" (recomendaciones IA)
const List<MockMovie> mockTodayPicks = [
  MockMovie(
    id: 1,
    title: 'Voyager Prime',
    posterUrl: 'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ber.jpg',
    backdropUrl: 'https://image.tmdb.org/t/p/w1280/qNBAXBIQlnOThrVvA6mA2B5ber.jpg',
    genre: 'Sci-Fi',
    year: 2024,
    rating: 8.5,
    aiReason: 'Porque te encantó Interstellar y Arrival',
    inWatchlist: true,
  ),
  MockMovie(
    id: 2,
    title: 'Neon Echoes',
    posterUrl: 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    backdropUrl: 'https://image.tmdb.org/t/p/w1280/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    genre: 'Thriller',
    year: 2024,
    rating: 8.2,
    aiReason: 'Basado en tu interés por thrillers psicológicos',
    inWatchlist: false,
  ),
  MockMovie(
    id: 3,
    title: 'The Last Signal',
    posterUrl: 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
    backdropUrl: 'https://image.tmdb.org/t/p/w1280/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
    genre: 'Drama',
    year: 2024,
    rating: 8.8,
    aiReason: 'Similar a tus favoritos de A24',
    inWatchlist: false,
  ),
];

/// Películas en tendencia
const List<MockMovie> mockTrending = [
  MockMovie(
    id: 10,
    title: 'The Last Frontier',
    posterUrl: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    genre: 'Drama',
    year: 2024,
    rating: 7.8,
    inWatchlist: true,
  ),
  MockMovie(
    id: 11,
    title: 'Coded Reality',
    posterUrl: 'https://image.tmdb.org/t/p/w500/z1p34vh7dEOnLDmyCrlUVLuoDzd.jpg',
    genre: 'Sci-Fi',
    year: 2024,
    rating: 8.1,
  ),
  MockMovie(
    id: 12,
    title: 'Midnight Run',
    posterUrl: 'https://image.tmdb.org/t/p/w500/qW4crfED8mpNDadSmMdi7ZDzhXF.jpg',
    genre: 'Thriller',
    year: 2024,
    rating: 7.5,
  ),
  MockMovie(
    id: 13,
    title: 'Ocean Dreams',
    posterUrl: 'https://image.tmdb.org/t/p/w500/gPbM0MK8CP8A174rmUwGsADNYKD.jpg',
    genre: 'Adventure',
    year: 2024,
    rating: 7.9,
  ),
  MockMovie(
    id: 14,
    title: 'Silent Echo',
    posterUrl: 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
    genre: 'Horror',
    year: 2024,
    rating: 6.8,
  ),
];

/// Estrenos
const List<MockMovie> mockNewReleases = [
  MockMovie(
    id: 20,
    title: 'Aurora Rising',
    posterUrl: 'https://image.tmdb.org/t/p/w500/wTnV3PCVW5O92JMrFvvrRcV39RU.jpg',
    genre: 'Sci-Fi',
    year: 2024,
    rating: 8.3,
  ),
  MockMovie(
    id: 21,
    title: 'The Witness',
    posterUrl: 'https://image.tmdb.org/t/p/w500/oYuLEt3zVCKq57qu2F8dT7NIa6f.jpg',
    genre: 'Crime',
    year: 2024,
    rating: 7.7,
  ),
  MockMovie(
    id: 22,
    title: 'Quantum Break',
    posterUrl: 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
    genre: 'Action',
    year: 2024,
    rating: 7.2,
    inWatchlist: true,
  ),
  MockMovie(
    id: 23,
    title: 'Lost in Time',
    posterUrl: 'https://image.tmdb.org/t/p/w500/hZkgoQYus5vegHoetLkCJzb17zJ.jpg',
    genre: 'Drama',
    year: 2024,
    rating: 8.0,
  ),
];

/// Mejor valoradas
const List<MockMovie> mockTopRated = [
  MockMovie(
    id: 30,
    title: 'Eternal Light',
    posterUrl: 'https://image.tmdb.org/t/p/w500/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg',
    genre: 'Drama',
    year: 2023,
    rating: 9.2,
  ),
  MockMovie(
    id: 31,
    title: 'The Departed II',
    posterUrl: 'https://image.tmdb.org/t/p/w500/nMKdUUepR0i5zn0y1T4CsSB5chy.jpg',
    genre: 'Crime',
    year: 2024,
    rating: 9.0,
  ),
  MockMovie(
    id: 32,
    title: 'Moonlight Sonata',
    posterUrl: 'https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg',
    genre: 'Romance',
    year: 2024,
    rating: 8.9,
    inWatchlist: true,
  ),
  MockMovie(
    id: 33,
    title: 'Iron Will',
    posterUrl: 'https://image.tmdb.org/t/p/w500/6CoRTJTmijhBLJTUNoVSUNxZMEI.jpg',
    genre: 'Action',
    year: 2024,
    rating: 8.7,
  ),
];

/// Cine rápido (menos de 90 min)
const List<MockMovie> mockQuickWatch = [
  MockMovie(
    id: 40,
    title: 'Fragments of Light',
    posterUrl: 'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',
    genre: 'Drama',
    year: 2024,
    rating: 7.8,
    runtime: 72,
    aiReason: 'Ideal para ver algo rápido',
  ),
  MockMovie(
    id: 41,
    title: 'The Short Story',
    posterUrl: 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    genre: 'Comedy',
    year: 2024,
    rating: 7.5,
    runtime: 85,
    aiReason: 'Breve e impactante',
  ),
  MockMovie(
    id: 42,
    title: 'Quick Silver',
    posterUrl: 'https://image.tmdb.org/t/p/w500/rktDFPbfHfUbArZ6OOOKsXcv0Bm.jpg',
    genre: 'Thriller',
    year: 2024,
    rating: 7.2,
    runtime: 78,
    aiReason: 'Perfecto para una noche corta',
  ),
];

/// Series para maratón
const List<MockMovie> mockBingeWorthy = [
  MockMovie(
    id: 50,
    title: 'Dark Horizons',
    posterUrl: 'https://image.tmdb.org/t/p/w500/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
    genre: 'Sci-Fi',
    year: 2024,
    rating: 8.9,
    aiReason: '8 episodios adictivos',
  ),
  MockMovie(
    id: 51,
    title: 'The Crown Legacy',
    posterUrl: 'https://image.tmdb.org/t/p/w500/1M876KPjulVwppEpldhdc8V4o68.jpg',
    genre: 'Drama',
    year: 2024,
    rating: 9.1,
    aiReason: 'Perfecto para el fin de semana',
    inWatchlist: true,
  ),
  MockMovie(
    id: 52,
    title: 'Cyber Punk 2099',
    posterUrl: 'https://image.tmdb.org/t/p/w500/7O4iVfOMQmdCSxhOg1WnzG1AgYT.jpg',
    genre: 'Action',
    year: 2024,
    rating: 8.5,
    aiReason: '10 episodios intensos',
  ),
];
