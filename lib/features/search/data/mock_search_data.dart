// Mock data para pantalla de búsqueda

class MockSearchResult {
  final int id;
  final String title;
  final String posterUrl;
  final String director;
  final String genre;
  final int runtime;
  final int year;
  final double rating;
  final int matchPercentage;
  final bool isFavorite;
  final bool inWatchlist;
  final bool isSeen;

  const MockSearchResult({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.director,
    required this.genre,
    required this.runtime,
    required this.year,
    required this.rating,
    this.matchPercentage = 0,
    this.isFavorite = false,
    this.inWatchlist = false,
    this.isSeen = false,
  });

  String get formattedRuntime {
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes}m';
  }

  MockSearchResult copyWith({
    bool? isFavorite,
    bool? inWatchlist,
    bool? isSeen,
  }) {
    return MockSearchResult(
      id: id,
      title: title,
      posterUrl: posterUrl,
      director: director,
      genre: genre,
      runtime: runtime,
      year: year,
      rating: rating,
      matchPercentage: matchPercentage,
      isFavorite: isFavorite ?? this.isFavorite,
      inWatchlist: inWatchlist ?? this.inWatchlist,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}

class SearchFilter {
  final String? genre;
  final int? yearFrom;
  final int? yearTo;
  final double? minRating;
  final int? maxRuntime;
  final String? mood;

  const SearchFilter({
    this.genre,
    this.yearFrom,
    this.yearTo,
    this.minRating,
    this.maxRuntime,
    this.mood,
  });

  bool get hasFilters =>
      genre != null ||
      yearFrom != null ||
      yearTo != null ||
      minRating != null ||
      maxRuntime != null ||
      mood != null;

  SearchFilter copyWith({
    String? genre,
    int? yearFrom,
    int? yearTo,
    double? minRating,
    int? maxRuntime,
    String? mood,
    bool clearGenre = false,
    bool clearYear = false,
    bool clearRating = false,
    bool clearRuntime = false,
    bool clearMood = false,
  }) {
    return SearchFilter(
      genre: clearGenre ? null : (genre ?? this.genre),
      yearFrom: clearYear ? null : (yearFrom ?? this.yearFrom),
      yearTo: clearYear ? null : (yearTo ?? this.yearTo),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      maxRuntime: clearRuntime ? null : (maxRuntime ?? this.maxRuntime),
      mood: clearMood ? null : (mood ?? this.mood),
    );
  }
}

// Géneros disponibles
const List<String> availableGenres = [
  'Sci-Fi',
  'Thriller',
  'Drama',
  'Action',
  'Comedy',
  'Horror',
  'Romance',
  'Mystery',
  'Animation',
  'Documentary',
];

// Moods disponibles
const List<String> availableMoods = [
  'Mind-bending',
  'Feel-good',
  'Intense',
  'Relaxing',
  'Inspiring',
  'Dark',
  'Funny',
  'Romantic',
  'Thrilling',
  'Epic',
];

// Sugerencias de búsqueda natural
const List<String> searchSuggestions = [
  'A mind-bending sci-fi about time travel but with a happy ending',
  'Something like Interstellar but shorter',
  'A thriller that will keep me on the edge of my seat',
  'Feel-good movies for a rainy Sunday',
  'Epic adventures with stunning visuals',
  'Dark mysteries that make you think',
];

// Mock results para búsqueda "Interstellar"
const List<MockSearchResult> mockAIRecommendedResults = [
  MockSearchResult(
    id: 1,
    title: 'Interstellar',
    posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    director: 'Christopher Nolan',
    genre: 'SCI-FI',
    runtime: 169,
    year: 2014,
    rating: 8.6,
    matchPercentage: 98,
    isFavorite: true,
  ),
  MockSearchResult(
    id: 2,
    title: 'Inception',
    posterUrl: 'https://image.tmdb.org/t/p/w500/edv5CZvWj09upOsy2Y6IwDhK8bt.jpg',
    director: 'Christopher Nolan',
    genre: 'THRILLER',
    runtime: 148,
    year: 2010,
    rating: 8.8,
    matchPercentage: 95,
    isSeen: true,
  ),
  MockSearchResult(
    id: 3,
    title: 'Arrival',
    posterUrl: 'https://image.tmdb.org/t/p/w500/x2FJsf1ElAgr63Y3PNPtJrcmpoe.jpg',
    director: 'Denis Villeneuve',
    genre: 'MYSTERY',
    runtime: 116,
    year: 2016,
    rating: 7.9,
    matchPercentage: 92,
  ),
  MockSearchResult(
    id: 4,
    title: 'The Martian',
    posterUrl: 'https://image.tmdb.org/t/p/w500/5BHuvQ6p9kfc091Z8RiFNhCwL4b.jpg',
    director: 'Ridley Scott',
    genre: 'DRAMA',
    runtime: 144,
    year: 2015,
    rating: 8.0,
    matchPercentage: 89,
    inWatchlist: true,
  ),
  MockSearchResult(
    id: 5,
    title: 'Gravity',
    posterUrl: 'https://image.tmdb.org/t/p/w500/uPxtxhB2Fy9ihVqtBtNGHmknJqV.jpg',
    director: 'Alfonso Cuarón',
    genre: 'SCI-FI',
    runtime: 91,
    year: 2013,
    rating: 7.7,
    matchPercentage: 87,
  ),
  MockSearchResult(
    id: 6,
    title: 'Ad Astra',
    posterUrl: 'https://image.tmdb.org/t/p/w500/xBHvZcjRiWyobQ9kxBhO6B2dtRI.jpg',
    director: 'James Gray',
    genre: 'DRAMA',
    runtime: 123,
    year: 2019,
    rating: 6.6,
    matchPercentage: 84,
  ),
];

// Trending searches
const List<String> trendingSearches = [
  'Dune',
  'Oppenheimer',
  'Barbie',
  'The Batman',
  'Top Gun Maverick',
];
