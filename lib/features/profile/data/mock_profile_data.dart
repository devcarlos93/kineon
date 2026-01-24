// Mock data para pantalla de Perfil/Ajustes

/// Datos del usuario
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? memberSince;
  final bool isPro;
  final DateTime? proExpiresAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.memberSince,
    this.isPro = false,
    this.proExpiresAt,
  });
}

/// Plan de suscripción
class SubscriptionPlan {
  final String id;
  final String name;
  final double monthlyPrice;
  final double annualPrice;
  final int annualDiscount;
  final List<ProFeature> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.annualDiscount,
    required this.features,
  });
}

/// Feature de Kineon Pro
class ProFeature {
  final String id;
  final String title;
  final String? description;
  final String iconName; // Nombre del CupertinoIcon

  const ProFeature({
    required this.id,
    required this.title,
    this.description,
    required this.iconName,
  });
}

/// Preferencia de la app
enum PreferenceType {
  toggle,
  select,
  navigation,
}

class AppPreference {
  final String id;
  final String title;
  final String iconName;
  final PreferenceType type;
  final String? currentValue;
  final List<String>? options;

  const AppPreference({
    required this.id,
    required this.title,
    required this.iconName,
    required this.type,
    this.currentValue,
    this.options,
  });
}

/// Región de streaming
class StreamingRegion {
  final String code;
  final String name;
  final String flag;

  const StreamingRegion({
    required this.code,
    required this.name,
    required this.flag,
  });
}

/// Periodo de facturación
enum BillingPeriod {
  monthly,
  annual,
}

// ═══════════════════════════════════════════════════════════════════════════
// MOCK DATA
// ═══════════════════════════════════════════════════════════════════════════

// Usuario mock
final UserProfile mockUserProfile = UserProfile(
  id: 'user-1',
  name: 'Alex Rivers',
  email: 'alex.rivers@kineon.ai',
  avatarUrl: null, // Usaremos placeholder
  memberSince: DateTime(2023, 6, 15),
  isPro: false,
);

// Plan de suscripción
const SubscriptionPlan kineonProPlan = SubscriptionPlan(
  id: 'kineon-pro',
  name: 'Kineon Pro',
  monthlyPrice: 2.99,
  annualPrice: 24.99,
  annualDiscount: 30,
  features: [
    ProFeature(
      id: 'unlimited-ai',
      title: 'Unlimited AI Recommendations',
      iconName: 'sparkles',
    ),
    ProFeature(
      id: 'offline-sync',
      title: 'Offline Collection Sync',
      iconName: 'cloud_download',
    ),
    ProFeature(
      id: 'early-access',
      title: 'Early Access to New Features',
      iconName: 'checkmark_seal',
    ),
    ProFeature(
      id: 'auto-lists',
      title: 'AI Auto-Generated Lists',
      iconName: 'list_bullet_rectangle',
    ),
    ProFeature(
      id: 'weekly-route',
      title: 'Weekly Watch Route',
      iconName: 'calendar',
    ),
    ProFeature(
      id: 'platform-filters',
      title: 'Filter by Streaming Platforms',
      iconName: 'tv',
    ),
  ],
);

// Regiones de streaming disponibles
const List<StreamingRegion> availableRegions = [
  StreamingRegion(code: 'US', name: 'United States', flag: '🇺🇸'),
  StreamingRegion(code: 'ES', name: 'España', flag: '🇪🇸'),
  StreamingRegion(code: 'MX', name: 'México', flag: '🇲🇽'),
  StreamingRegion(code: 'AR', name: 'Argentina', flag: '🇦🇷'),
  StreamingRegion(code: 'CO', name: 'Colombia', flag: '🇨🇴'),
  StreamingRegion(code: 'GB', name: 'United Kingdom', flag: '🇬🇧'),
  StreamingRegion(code: 'FR', name: 'France', flag: '🇫🇷'),
  StreamingRegion(code: 'DE', name: 'Germany', flag: '🇩🇪'),
  StreamingRegion(code: 'IT', name: 'Italy', flag: '🇮🇹'),
  StreamingRegion(code: 'BR', name: 'Brasil', flag: '🇧🇷'),
];

// Opciones de apariencia
const List<String> appearanceOptions = [
  'Dark Mode',
  'Light Mode',
  'System',
];

// Idiomas disponibles
const List<String> availableLanguages = [
  'Español',
  'English',
];

// Versión de la app
const String appVersion = '2.4.0';
