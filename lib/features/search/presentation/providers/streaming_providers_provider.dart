import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/datasources/tmdb_remote_datasource.dart';
import '../../../movie_details/presentation/providers/watch_providers_provider.dart';

/// Provider que obtiene los proveedores de streaming disponibles en la región del usuario.
/// Filtra los top 15 por displayPriority para mostrar en el bottom sheet.
final streamingProvidersProvider =
    FutureProvider<List<WatchProvider>>((ref) async {
  final datasource = ref.watch(tmdbRemoteDataSourceProvider);
  final providers = await datasource.getAvailableWatchProviders();

  // Ordenar por displayPriority y tomar top 15
  providers.sort((a, b) => a.displayPriority.compareTo(b.displayPriority));
  return providers.take(15).toList();
});
