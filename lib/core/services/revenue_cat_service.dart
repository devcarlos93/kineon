import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONFIGURACIÓN DE REVENUECAT
// ═══════════════════════════════════════════════════════════════════════════

class RevenueCatConfig {
  RevenueCatConfig._();

  /// API Key para iOS (de RevenueCat Dashboard)
  static const String appleApiKey = 'appl_ZtoAyanlZUgnTBZFZspKYSbxxrc';

  /// API Key para Android (agregar cuando tengas)
  static const String googleApiKey = '';

  /// Entitlement ID configurado en RevenueCat
  static const String proEntitlementId = 'Kineon Pro';

  /// Product IDs
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';
  static const String lifetimeProductId = 'lifetime';
}

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO DE SUSCRIPCIÓN
// ═══════════════════════════════════════════════════════════════════════════

@immutable
class SubscriptionStatus {
  final bool isPro;
  final bool isTrialing;
  final DateTime? expirationDate;
  final String? activeProductId;
  final String? managementUrl;
  final List<StoreProduct> availableProducts;
  final Offerings? offerings;
  final bool isLoading;
  final String? error;

  const SubscriptionStatus({
    this.isPro = false,
    this.isTrialing = false,
    this.expirationDate,
    this.activeProductId,
    this.managementUrl,
    this.availableProducts = const [],
    this.offerings,
    this.isLoading = true,
    this.error,
  });

  SubscriptionStatus copyWith({
    bool? isPro,
    bool? isTrialing,
    DateTime? expirationDate,
    String? activeProductId,
    String? managementUrl,
    List<StoreProduct>? availableProducts,
    Offerings? offerings,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionStatus(
      isPro: isPro ?? this.isPro,
      isTrialing: isTrialing ?? this.isTrialing,
      expirationDate: expirationDate ?? this.expirationDate,
      activeProductId: activeProductId ?? this.activeProductId,
      managementUrl: managementUrl ?? this.managementUrl,
      availableProducts: availableProducts ?? this.availableProducts,
      offerings: offerings ?? this.offerings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Obtiene el producto mensual
  StoreProduct? get monthlyProduct {
    try {
      return availableProducts.firstWhere(
        (p) => p.identifier == RevenueCatConfig.monthlyProductId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el producto anual
  StoreProduct? get yearlyProduct {
    try {
      return availableProducts.firstWhere(
        (p) => p.identifier == RevenueCatConfig.yearlyProductId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el producto lifetime
  StoreProduct? get lifetimeProduct {
    try {
      return availableProducts.firstWhere(
        (p) => p.identifier == RevenueCatConfig.lifetimeProductId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Precio mensual formateado
  String? get monthlyPrice => monthlyProduct?.priceString;

  /// Precio anual formateado
  String? get yearlyPrice => yearlyProduct?.priceString;

  /// Precio lifetime formateado
  String? get lifetimePrice => lifetimeProduct?.priceString;

  /// Calcula el ahorro del plan anual
  int get yearlySavingsPercent {
    if (monthlyProduct == null || yearlyProduct == null) return 0;
    final monthlyTotal = monthlyProduct!.price * 12;
    final yearlyTotal = yearlyProduct!.price;
    if (monthlyTotal <= 0) return 0;
    return ((1 - (yearlyTotal / monthlyTotal)) * 100).round();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVICIO DE REVENUECAT
// ═══════════════════════════════════════════════════════════════════════════

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  final _statusController = StreamController<SubscriptionStatus>.broadcast();
  SubscriptionStatus _currentStatus = const SubscriptionStatus();

  Stream<SubscriptionStatus> get statusStream => _statusController.stream;
  SubscriptionStatus get currentStatus => _currentStatus;
  bool get isInitialized => _isInitialized;

  /// Inicializa RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configurar nivel de log (debug en desarrollo, error en producción)
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.error,
      );

      // Configurar según plataforma
      late PurchasesConfiguration configuration;

      if (Platform.isIOS || Platform.isMacOS) {
        configuration = PurchasesConfiguration(RevenueCatConfig.appleApiKey);
      } else if (Platform.isAndroid) {
        if (RevenueCatConfig.googleApiKey.isEmpty) {
          debugPrint('RevenueCat: Google API key not configured');
          _emitError('Google Play no configurado');
          return;
        }
        configuration = PurchasesConfiguration(RevenueCatConfig.googleApiKey);
      } else {
        debugPrint('RevenueCat: Platform not supported');
        return;
      }

      await Purchases.configure(configuration);

      // Escuchar cambios de customer info
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      _isInitialized = true;
      debugPrint('RevenueCat: Initialized successfully');
      debugPrint('RevenueCat: API Key = ${RevenueCatConfig.appleApiKey}');

      // Debug: verificar offerings
      try {
        final offerings = await Purchases.getOfferings();
        debugPrint('RevenueCat: Current offering = ${offerings.current?.identifier}');
        debugPrint('RevenueCat: All offerings = ${offerings.all.keys.toList()}');
        if (offerings.current != null) {
          debugPrint('RevenueCat: Packages = ${offerings.current!.availablePackages.map((p) => "${p.identifier}: ${p.storeProduct.identifier}").toList()}');
        } else {
          debugPrint('RevenueCat: No current offering found!');
        }
      } catch (e) {
        debugPrint('RevenueCat: Error checking offerings: $e');
      }

      // Cargar estado inicial
      await refreshStatus();
    } catch (e, stack) {
      debugPrint('RevenueCat init error: $e');
      debugPrint('Stack: $stack');
      _emitError('Error al inicializar pagos: $e');
    }
  }

  /// Emite un error
  void _emitError(String message) {
    _currentStatus = SubscriptionStatus(isLoading: false, error: message);
    _statusController.add(_currentStatus);
  }

  /// Callback cuando cambia el customer info
  void _onCustomerInfoUpdated(CustomerInfo info) {
    debugPrint('RevenueCat: Customer info updated');
    _updateStatusFromCustomerInfo(info);
  }

  /// Actualiza el estado desde CustomerInfo
  Future<void> _updateStatusFromCustomerInfo(CustomerInfo info) async {
    final entitlement = info.entitlements.all[RevenueCatConfig.proEntitlementId];
    final isPro = entitlement?.isActive ?? false;

    debugPrint('RevenueCat: isPro = $isPro');
    debugPrint('RevenueCat: entitlements = ${info.entitlements.all.keys}');

    // Obtener offerings
    Offerings? offerings;
    List<StoreProduct> products = [];

    try {
      offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        products = offerings.current!.availablePackages
            .map((p) => p.storeProduct)
            .toList();
        debugPrint('RevenueCat: Found ${products.length} products');
      }
    } catch (e) {
      debugPrint('RevenueCat: Error getting offerings: $e');
    }

    _currentStatus = SubscriptionStatus(
      isPro: isPro,
      isTrialing: entitlement?.periodType == PeriodType.trial,
      expirationDate: entitlement?.expirationDate != null
          ? DateTime.tryParse(entitlement!.expirationDate!)
          : null,
      activeProductId: entitlement?.productIdentifier,
      managementUrl: info.managementURL,
      availableProducts: products,
      offerings: offerings,
      isLoading: false,
    );

    _statusController.add(_currentStatus);
  }

  /// Refresca el estado de suscripción
  Future<SubscriptionStatus> refreshStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      await _updateStatusFromCustomerInfo(info);
      return _currentStatus;
    } catch (e) {
      debugPrint('RevenueCat: Error refreshing status: $e');
      _emitError('Error al verificar suscripción');
      return _currentStatus;
    }
  }

  /// Obtiene los paquetes disponibles
  Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('RevenueCat: Error getting packages: $e');
      return [];
    }
  }

  /// Compra un paquete específico
  Future<PurchaseResult> purchasePackage(Package package) async {
    try {
      _currentStatus = _currentStatus.copyWith(isLoading: true);
      _statusController.add(_currentStatus);

      final result = await Purchases.purchasePackage(package);
      final entitlement = result.entitlements.all[RevenueCatConfig.proEntitlementId];
      final isPro = entitlement?.isActive ?? false;

      debugPrint('RevenueCat: Purchase completed, isPro = $isPro');

      return PurchaseResult(
        success: isPro,
        customerInfo: result,
      );
    } on PurchasesErrorCode catch (e) {
      debugPrint('RevenueCat: Purchase error code: $e');
      return PurchaseResult(
        success: false,
        error: _mapPurchaseError(e),
      );
    } catch (e) {
      debugPrint('RevenueCat: Purchase error: $e');
      return PurchaseResult(
        success: false,
        error: 'Error al procesar el pago',
      );
    } finally {
      await refreshStatus();
    }
  }

  /// Compra un producto por ID
  Future<PurchaseResult> purchaseProduct(String productId) async {
    try {
      final packages = await getPackages();
      final package = packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
        orElse: () => throw Exception('Product not found'),
      );
      return purchasePackage(package);
    } catch (e) {
      return PurchaseResult(
        success: false,
        error: 'Producto no encontrado',
      );
    }
  }

  /// Muestra el paywall de RevenueCat
  Future<PaywallResult> presentPaywall() async {
    try {
      final result = await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );

      debugPrint('RevenueCat: Paywall result = $result');

      // Refrescar estado después del paywall
      await refreshStatus();

      return result;
    } catch (e) {
      debugPrint('RevenueCat: Paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Muestra el paywall con un offering específico
  Future<PaywallResult> presentPaywallIfNeeded({
    String? requiredEntitlementIdentifier,
  }) async {
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlementIdentifier ?? RevenueCatConfig.proEntitlementId,
        displayCloseButton: true,
      );

      await refreshStatus();
      return result;
    } catch (e) {
      debugPrint('RevenueCat: PaywallIfNeeded error: $e');
      return PaywallResult.error;
    }
  }

  /// Muestra el Customer Center para gestionar suscripción
  /// Permite al usuario ver, modificar o cancelar su suscripción
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
      debugPrint('RevenueCat: Customer Center presented');
      // Refrescar estado después de cerrar Customer Center
      await refreshStatus();
    } catch (e) {
      debugPrint('RevenueCat: Customer Center error: $e');
    }
  }

  /// Restaura compras anteriores
  Future<RestoreResult> restorePurchases() async {
    try {
      _currentStatus = _currentStatus.copyWith(isLoading: true);
      _statusController.add(_currentStatus);

      final info = await Purchases.restorePurchases();
      final entitlement = info.entitlements.all[RevenueCatConfig.proEntitlementId];
      final isPro = entitlement?.isActive ?? false;

      debugPrint('RevenueCat: Restore completed, isPro = $isPro');

      await _updateStatusFromCustomerInfo(info);

      return RestoreResult(
        success: true,
        isPro: isPro,
        message: isPro ? 'Compras restauradas' : 'No se encontraron compras',
      );
    } catch (e) {
      debugPrint('RevenueCat: Restore error: $e');
      _emitError('Error al restaurar compras');
      return RestoreResult(
        success: false,
        isPro: false,
        message: 'Error al restaurar compras',
      );
    }
  }

  /// Vincula usuario de Supabase con RevenueCat
  Future<void> loginUser(String userId) async {
    if (!_isInitialized) return;

    try {
      final result = await Purchases.logIn(userId);
      debugPrint('RevenueCat: User logged in: $userId');
      await _updateStatusFromCustomerInfo(result.customerInfo);
    } catch (e) {
      debugPrint('RevenueCat: Login error: $e');
    }
  }

  /// Desvincula usuario (logout)
  Future<void> logoutUser() async {
    if (!_isInitialized) return;

    try {
      final info = await Purchases.logOut();
      debugPrint('RevenueCat: User logged out');
      await _updateStatusFromCustomerInfo(info);
    } catch (e) {
      debugPrint('RevenueCat: Logout error: $e');
    }
  }

  /// Obtiene la URL de gestión de suscripción
  String? get managementUrl => _currentStatus.managementUrl;

  /// Mapea errores de compra a mensajes legibles
  String _mapPurchaseError(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Compra cancelada';
      case PurchasesErrorCode.paymentPendingError:
        return 'Pago pendiente de aprobación';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Producto no disponible';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Compras no permitidas en este dispositivo';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Compra inválida';
      case PurchasesErrorCode.networkError:
        return 'Error de conexión';
      case PurchasesErrorCode.storeProblemError:
        return 'Error en la tienda';
      default:
        return 'Error al procesar el pago';
    }
  }

  void dispose() {
    _statusController.close();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULTADOS
// ═══════════════════════════════════════════════════════════════════════════

class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  PurchaseResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}

class RestoreResult {
  final bool success;
  final bool isPro;
  final String message;

  RestoreResult({
    required this.success,
    required this.isPro,
    required this.message,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider del servicio de RevenueCat
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Provider del estado de suscripción (stream)
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.statusStream;
});

/// Provider simple para verificar si es Pro
final isProProvider = Provider<bool>((ref) {
  // Verificar estado actual sincrónico primero
  final currentPro = RevenueCatService().currentStatus.isPro;
  if (currentPro) return true;

  // Luego verificar el stream
  final status = ref.watch(subscriptionStatusProvider);
  return status.valueOrNull?.isPro ?? false;
});

/// Provider del estado actual (no stream)
final currentSubscriptionProvider = Provider<SubscriptionStatus>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.currentStatus;
});

/// Provider de paquetes disponibles
final availablePackagesProvider = FutureProvider<List<Package>>((ref) async {
  final service = ref.read(revenueCatServiceProvider);
  return service.getPackages();
});

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET HELPER PARA MOSTRAR PAYWALL
// ═══════════════════════════════════════════════════════════════════════════

/// Widget que muestra el paywall de RevenueCat si el usuario no es Pro
class RevenueCatPaywallGate extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;

  const RevenueCatPaywallGate({
    super.key,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(subscriptionStatusProvider);

    return status.when(
      data: (sub) {
        if (sub.isPro) {
          return child;
        }
        // Mostrar paywall automáticamente
        WidgetsBinding.instance.addPostFrameCallback((_) {
          RevenueCatService().presentPaywall();
        });
        return loadingWidget ?? const Center(child: CircularProgressIndicator());
      },
      loading: () => loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (_, __) => child, // En caso de error, mostrar contenido
    );
  }
}

/// Extensión para mostrar paywall fácilmente desde cualquier contexto
extension RevenueCatExtensions on BuildContext {
  /// Muestra el paywall de RevenueCat
  Future<PaywallResult> showRevenueCatPaywall() async {
    return RevenueCatService().presentPaywall();
  }

  /// Muestra el paywall solo si no es Pro
  Future<PaywallResult> showPaywallIfNeeded() async {
    return RevenueCatService().presentPaywallIfNeeded();
  }

  /// Muestra el Customer Center para gestionar suscripción
  Future<void> showCustomerCenter() async {
    return RevenueCatService().presentCustomerCenter();
  }
}
