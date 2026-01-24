// Mock data para pantalla de Biblioteca

/// Item de la biblioteca (película/serie guardada)
class LibraryItem {
  final int id;
  final String title;
  final String posterUrl;
  final int year;
  final String genre;
  final int matchPercentage;
  final String type; // 'Movie' or 'Series'
  final DateTime? addedAt;
  final DateTime? watchedAt;
  final bool isFavorite;
  final bool isInWatchlist;
  final bool isWatched;

  const LibraryItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.year,
    required this.genre,
    required this.matchPercentage,
    required this.type,
    this.addedAt,
    this.watchedAt,
    this.isFavorite = false,
    this.isInWatchlist = false,
    this.isWatched = false,
  });

  LibraryItem copyWith({
    bool? isFavorite,
    bool? isInWatchlist,
    bool? isWatched,
    DateTime? watchedAt,
  }) {
    return LibraryItem(
      id: id,
      title: title,
      posterUrl: posterUrl,
      year: year,
      genre: genre,
      matchPercentage: matchPercentage,
      type: type,
      addedAt: addedAt,
      watchedAt: watchedAt ?? this.watchedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isWatched: isWatched ?? this.isWatched,
    );
  }
}

/// Lista personalizada del usuario
class UserList {
  final String id;
  final String name;
  final String icon;
  final List<LibraryItem> items;
  final DateTime createdAt;

  const UserList({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
    required this.createdAt,
  });
}

/// Datos del heatmap de visualización
class ViewingHeatmapData {
  final List<int> activityLevels; // 0-4 para cada celda
  final double changePercentage;
  final String period;

  const ViewingHeatmapData({
    required this.activityLevels,
    required this.changePercentage,
    required this.period,
  });
}

// LibraryTab enum movido a library_tabs.dart

// ═══════════════════════════════════════════════════════════════════════════
// MOCK DATA
// ═══════════════════════════════════════════════════════════════════════════

// Watchlist items
final List<LibraryItem> mockWatchlistItems = [
  LibraryItem(
    id: 1,
    title: 'Red Horizon',
    posterUrl: 'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ber9.jpg',
    year: 2024,
    genre: 'Sci-Fi',
    matchPercentage: 98,
    type: 'Movie',
    isInWatchlist: true,
    addedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  LibraryItem(
    id: 2,
    title: 'Neon Nights',
    posterUrl: 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    year: 2023,
    genre: 'Drama',
    matchPercentage: 92,
    type: 'Movie',
    isInWatchlist: true,
    addedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  LibraryItem(
    id: 3,
    title: 'Digital Soul',
    posterUrl: 'https://image.tmdb.org/t/p/w500/sv1xJUazXeYqALzczSZ3O6nkH75.jpg',
    year: 2024,
    genre: 'Action',
    matchPercentage: 85,
    type: 'Movie',
    isInWatchlist: true,
    addedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  LibraryItem(
    id: 4,
    title: 'Silent Valley',
    posterUrl: 'https://image.tmdb.org/t/p/w500/wXqWR7dHncNRbxoEGybEy7QTe9h.jpg',
    year: 2022,
    genre: 'Nature',
    matchPercentage: 95,
    type: 'Movie',
    isInWatchlist: true,
    addedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  LibraryItem(
    id: 5,
    title: 'The Void',
    posterUrl: 'https://image.tmdb.org/t/p/w500/rktDFPbfHfUbArZ6OOOKsXcv0Bm.jpg',
    year: 2023,
    genre: 'Thriller',
    matchPercentage: 88,
    type: 'Movie',
    isInWatchlist: true,
    addedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  LibraryItem(
    id: 6,
    title: 'Dreamscape',
    posterUrl: 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
    year: 2024,
    genre: 'Animation',
    matchPercentage: 91,
    type: 'Movie',
    isInWatchlist: true,
    addedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// Favorites items
final List<LibraryItem> mockFavoritesItems = [
  LibraryItem(
    id: 10,
    title: 'Interstellar',
    posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    year: 2014,
    genre: 'Sci-Fi',
    matchPercentage: 99,
    type: 'Movie',
    isFavorite: true,
    isWatched: true,
  ),
  LibraryItem(
    id: 11,
    title: 'Blade Runner 2049',
    posterUrl: 'https://image.tmdb.org/t/p/w500/gajva2L0rPYkEWjzgFlBXCAVBE5.jpg',
    year: 2017,
    genre: 'Sci-Fi',
    matchPercentage: 97,
    type: 'Movie',
    isFavorite: true,
    isWatched: true,
  ),
  LibraryItem(
    id: 12,
    title: 'Dune',
    posterUrl: 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
    year: 2021,
    genre: 'Sci-Fi',
    matchPercentage: 96,
    type: 'Movie',
    isFavorite: true,
    isWatched: true,
  ),
  LibraryItem(
    id: 13,
    title: 'The Matrix',
    posterUrl: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
    year: 1999,
    genre: 'Action',
    matchPercentage: 95,
    type: 'Movie',
    isFavorite: true,
    isWatched: true,
  ),
];

// Watched items
final List<LibraryItem> mockWatchedItems = [
  ...mockFavoritesItems,
  LibraryItem(
    id: 20,
    title: 'Oppenheimer',
    posterUrl: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    year: 2023,
    genre: 'Drama',
    matchPercentage: 94,
    type: 'Movie',
    isWatched: true,
    watchedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  LibraryItem(
    id: 21,
    title: 'Poor Things',
    posterUrl: 'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg',
    year: 2023,
    genre: 'Comedy',
    matchPercentage: 89,
    type: 'Movie',
    isWatched: true,
    watchedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  LibraryItem(
    id: 22,
    title: 'Severance',
    posterUrl: 'https://image.tmdb.org/t/p/w500/lFf6LLrQjYldcZItzOkGmMMigP7.jpg',
    year: 2022,
    genre: 'Thriller',
    matchPercentage: 98,
    type: 'Series',
    isWatched: true,
    watchedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
];

// User lists
final List<UserList> mockUserLists = [
  UserList(
    id: 'list-1',
    name: 'Noche de cine',
    icon: '🎬',
    items: mockWatchlistItems.take(3).toList(),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  UserList(
    id: 'list-2',
    name: 'Sci-Fi épico',
    icon: '🚀',
    items: mockFavoritesItems.take(3).toList(),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
  ),
  UserList(
    id: 'list-3',
    name: 'Para ver en pareja',
    icon: '❤️',
    items: mockWatchlistItems.skip(2).take(2).toList(),
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
];

// Heatmap data (últimos 6 meses, ~24 celdas)
const ViewingHeatmapData mockHeatmapData = ViewingHeatmapData(
  activityLevels: [
    1, 2, 1, 0, 2, 3, // Mes 1
    1, 1, 2, 2, 3, 2, // Mes 2
    2, 3, 2, 1, 2, 4, // Mes 3
    3, 2, 3, 4, 3, 4, // Mes 4
  ],
  changePercentage: 12,
  period: 'Last 6 Months',
);

// List icons disponibles para crear listas
const List<String> availableListIcons = [
  '🎬', '🍿', '🎭', '🎪', '🎨', '🎯',
  '⭐', '❤️', '🔥', '💎', '🌟', '✨',
  '🚀', '🌙', '🎮', '📺', '🎵', '📚',
  '🏆', '👑', '💫', '🎁', '🔮', '🌈',
];
