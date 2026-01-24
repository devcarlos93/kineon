import 'package:flutter/widgets.dart';

/// RouteObserver global para detectar navegación entre pantallas.
/// Usado para refrescar estados cuando se vuelve de Detail a Home.
final RouteObserver<ModalRoute<void>> kineonRouteObserver =
    RouteObserver<ModalRoute<void>>();
