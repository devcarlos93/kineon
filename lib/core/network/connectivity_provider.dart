import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de conectividad de la app
enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

/// Provider que monitorea el estado de conectividad
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier(this._connectivity) : super(ConnectivityStatus.unknown) {
    _init();
  }

  Future<void> _init() async {
    // Verificar estado inicial
    final results = await _connectivity.checkConnectivity();
    state = _mapResultsToStatus(results);

    // Escuchar cambios
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      state = _mapResultsToStatus(results);
    });
  }

  ConnectivityStatus _mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }

  /// Verifica manualmente el estado de conectividad
  Future<void> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    state = _mapResultsToStatus(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider de conectividad
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier(Connectivity());
});

/// Helper para verificar si está online
extension ConnectivityStatusX on ConnectivityStatus {
  bool get isOnline => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;
}
