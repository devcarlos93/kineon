import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/regional_prefs_provider.dart';
import '../../../../core/network/supabase_client.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODELOS
// ═══════════════════════════════════════════════════════════════════════════

/// Proveedor de streaming (Netflix, Prime, etc.)
class WatchProvider {
  final int providerId;
  final String providerName;
  final String logoPath;
  final int displayPriority;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
    required this.displayPriority,
  });

  String get logoUrl => 'https://image.tmdb.org/t/p/w92$logoPath';

  factory WatchProvider.fromJson(Map<String, dynamic> json) {
    return WatchProvider(
      providerId: json['provider_id'] as int? ?? 0,
      providerName: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String? ?? '',
      displayPriority: json['display_priority'] as int? ?? 999,
    );
  }
}

/// Resultado de watch providers por país
class WatchProvidersResult {
  final String? link; // Deep link a JustWatch
  final List<WatchProvider> flatrate; // Streaming incluido (Netflix, etc.)
  final List<WatchProvider> rent; // Alquiler
  final List<WatchProvider> buy; // Compra
  final List<WatchProvider> free; // Gratis con anuncios
  final String countryCode;

  const WatchProvidersResult({
    this.link,
    this.flatrate = const [],
    this.rent = const [],
    this.buy = const [],
    this.free = const [],
    required this.countryCode,
  });

  /// Todos los proveedores de streaming (flatrate + free)
  List<WatchProvider> get streaming => [...flatrate, ...free];

  /// Tiene proveedores disponibles
  bool get hasProviders =>
      flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty || free.isNotEmpty;

  /// Tiene streaming disponible
  bool get hasStreaming => flatrate.isNotEmpty || free.isNotEmpty;

  factory WatchProvidersResult.fromJson(
    Map<String, dynamic> json,
    String countryCode,
  ) {
    final countryData = json['results']?[countryCode] as Map<String, dynamic>?;

    if (countryData == null) {
      return WatchProvidersResult(countryCode: countryCode);
    }

    return WatchProvidersResult(
      link: countryData['link'] as String?,
      flatrate: (countryData['flatrate'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      rent: (countryData['rent'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      buy: (countryData['buy'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      free: (countryData['free'] as List<dynamic>?)
              ?.map((p) => WatchProvider.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      countryCode: countryCode,
    );
  }

  factory WatchProvidersResult.empty(String countryCode) {
    return WatchProvidersResult(countryCode: countryCode);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PARAMS
// ═══════════════════════════════════════════════════════════════════════════

class WatchProvidersParams {
  final int tmdbId;
  final bool isMovie;

  const WatchProvidersParams({
    required this.tmdbId,
    required this.isMovie,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProvidersParams &&
          runtimeType == other.runtimeType &&
          tmdbId == other.tmdbId &&
          isMovie == other.isMovie;

  @override
  int get hashCode => tmdbId.hashCode ^ isMovie.hashCode;
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para obtener watch providers de una película/serie
final watchProvidersProvider = FutureProvider.family
    .autoDispose<WatchProvidersResult, WatchProvidersParams>((ref, params) async {
  final client = ref.watch(supabaseClientProvider);
  final regionalPrefs = ref.watch(regionalPrefsProvider);
  final region = regionalPrefs.tmdbRegion;

  try {
    final contentType = params.isMovie ? 'movie' : 'tv';
    final path = '$contentType/${params.tmdbId}/watch/providers';

    final response = await client.functions.invoke(
      'tmdb-proxy',
      body: {
        'path': path,
        'region': region,
      },
    );

    final data = response.data as Map<String, dynamic>?;
    if (data == null) {
      return WatchProvidersResult.empty(region);
    }

    return WatchProvidersResult.fromJson(data, region);
  } catch (e) {
    // ignore: avoid_print
    print('Error fetching watch providers: $e');
    return WatchProvidersResult.empty(region);
  }
});
