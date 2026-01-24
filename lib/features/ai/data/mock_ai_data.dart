// Mock data para pantalla de IA

/// Mensaje en el chat de IA
class AiMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<AiMovieRecommendation>? recommendations;

  const AiMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.recommendations,
  });
}

/// Recomendación de película de la IA
class AiMovieRecommendation {
  final int id;
  final String title;
  final String backdropUrl;
  final String posterUrl;
  final String reason;
  final int matchPercentage;
  final List<String> tags;
  final int year;
  final String? director;
  bool inWatchlist;
  bool isFavorite;

  AiMovieRecommendation({
    required this.id,
    required this.title,
    required this.backdropUrl,
    required this.posterUrl,
    required this.reason,
    required this.matchPercentage,
    required this.tags,
    required this.year,
    this.director,
    this.inWatchlist = false,
    this.isFavorite = false,
  });

  AiMovieRecommendation copyWith({
    bool? inWatchlist,
    bool? isFavorite,
  }) {
    return AiMovieRecommendation(
      id: id,
      title: title,
      backdropUrl: backdropUrl,
      posterUrl: posterUrl,
      reason: reason,
      matchPercentage: matchPercentage,
      tags: tags,
      year: year,
      director: director,
      inWatchlist: inWatchlist ?? this.inWatchlist,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Item para decisión rápida (swipe)
class QuickDecisionItem {
  final int id;
  final String title;
  final String posterUrl;
  final String type; // 'Movie' or 'Series'
  final int year;

  const QuickDecisionItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.type,
    required this.year,
  });
}

/// Quick prompt sugerido
class QuickPrompt {
  final String id;
  final String text;
  final String? icon;

  const QuickPrompt({
    required this.id,
    required this.text,
    this.icon,
  });
}

// Quick prompts predefinidos
const List<QuickPrompt> defaultQuickPrompts = [
  QuickPrompt(id: '1', text: 'Quiero algo como...', icon: '🎬'),
  QuickPrompt(id: '2', text: 'Algo corto y bueno', icon: '⏱️'),
  QuickPrompt(id: '3', text: 'Para ver en pareja', icon: '❤️'),
  QuickPrompt(id: '4', text: 'Sorpréndeme', icon: '✨'),
];

// Mock AI response para "mind-bending like Interstellar"
final mockAiResponse = AiMessage(
  id: 'ai-1',
  content: 'Based on your love for high-concept sci-fi and Christopher Nolan\'s style, I\'ve curated these three gems. They explore reality and physics in ways you\'ll appreciate:',
  isUser: false,
  timestamp: DateTime.now(),
  recommendations: [
    AiMovieRecommendation(
      id: 1,
      title: 'Tenet',
      backdropUrl: 'https://image.tmdb.org/t/p/w780/wzJRB4MKi3yK138bJyuL9nx47y6.jpg',
      posterUrl: 'https://image.tmdb.org/t/p/w500/k68nPLbIST6NP96JmTxmZijEvCA.jpg',
      reason: 'The cinematography and temporal inversion match your Nolan preference perfectly.',
      matchPercentage: 98,
      tags: ['Mind-bending', 'Sci-Fi', 'Action'],
      year: 2020,
      director: 'Christopher Nolan',
    ),
    AiMovieRecommendation(
      id: 2,
      title: 'Arrival',
      backdropUrl: 'https://image.tmdb.org/t/p/w780/yIZ1xendyqKvY3FGeeUYUd5X9Mm.jpg',
      posterUrl: 'https://image.tmdb.org/t/p/w500/x2FJsf1ElAgr63Y3PNPtJrcmpoe.jpg',
      reason: 'Focuses on linguistics and time perception, mirroring the intellectual depth of Interstellar.',
      matchPercentage: 95,
      tags: ['Cerebral', 'Sci-Fi', 'Drama'],
      year: 2016,
      director: 'Denis Villeneuve',
    ),
    AiMovieRecommendation(
      id: 3,
      title: 'Coherence',
      backdropUrl: 'https://image.tmdb.org/t/p/w780/9EBPsnRBKMLbhQNcgimmnphrbRO.jpg',
      posterUrl: 'https://image.tmdb.org/t/p/w500/qwAFeEuWHzBD0Gl7R0aMnwsz9Bp.jpg',
      reason: 'A low-budget masterpiece of quantum uncertainty that keeps you guessing until the end.',
      matchPercentage: 92,
      tags: ['Mystery', 'Sci-Fi', 'Indie'],
      year: 2013,
      director: 'James Ward Byrkit',
    ),
  ],
);

// Mock items para decisión rápida
const List<QuickDecisionItem> mockQuickDecisionItems = [
  QuickDecisionItem(
    id: 101,
    title: 'Dark',
    posterUrl: 'https://image.tmdb.org/t/p/w500/apbrbWs8M9lyOpJYU5WXrpFbk1Z.jpg',
    type: 'Series',
    year: 2017,
  ),
  QuickDecisionItem(
    id: 102,
    title: 'Severance',
    posterUrl: 'https://image.tmdb.org/t/p/w500/lFf6LLrQjYldcZItzOkGmMMigP7.jpg',
    type: 'Series',
    year: 2022,
  ),
  QuickDecisionItem(
    id: 103,
    title: 'The Prestige',
    posterUrl: 'https://image.tmdb.org/t/p/w500/5MXyQfz8xUP3dIFPTubhTsbFY6N.jpg',
    type: 'Movie',
    year: 2006,
  ),
];
