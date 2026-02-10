import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../navigation/route_observer.dart';
import '../network/connectivity_provider.dart';
import '../widgets/kino_mascot.dart';
import '../widgets/offline_banner.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/media_list_screen.dart';
import '../../features/search/presentation/screens/intelligent_discovery_screen.dart';
import '../../features/ai/presentation/screens/ai_assistant_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/library/presentation/screens/list_detail_screen.dart';
import '../../features/movie_details/presentation/screens/movie_details_screen.dart';
import '../../features/movie_details/presentation/screens/movie_detail_mock_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_mock_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/smart_collection_detail_screen.dart';
import '../../features/stories/presentation/screens/stories_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// =====================================================
// RUTAS
// =====================================================

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String search = '/search';
  static const String ai = '/ai';
  static const String library = '/library';
  static const String profile = '/profile';
  static const String details = '/details/:type/:id';
  static const String mediaList = '/list/:type';
  static const String stories = '/stories';

  // Rutas públicas (no requieren autenticación)
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    login,
    home,
    search,
  ];

  // Rutas que requieren autenticación
  static const List<String> protectedRoutes = [
    ai,
    library,
  ];
}

// =====================================================
// AUTH NOTIFIER - Escucha cambios de sesión
// =====================================================

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        _session = data.session;
        notifyListeners();
      },
    );
    _session = Supabase.instance.client.auth.currentSession;
  }

  Session? _session;
  late final StreamSubscription<AuthState> _subscription;

  bool get isAuthenticated => _session != null;
  Session? get session => _session;
  User? get user => _session?.user;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provider del notifier de auth
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});

/// Provider de estado de autenticación (reactivo)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Provider del usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

// =====================================================
// NAVIGATION KEYS (para preservar estado)
// Deben ser estáticos para no recrearse con el router
// =====================================================

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final GlobalKey<NavigatorState> _shellNavigatorAiKey = GlobalKey<NavigatorState>(debugLabel: 'ai');
final GlobalKey<NavigatorState> _shellNavigatorLibraryKey = GlobalKey<NavigatorState>(debugLabel: 'library');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// =====================================================
// ROUTER CON STATEFUL SHELL (preserva estado por tab)
// =====================================================

final routerProvider = Provider<GoRouter>((ref) {
  // Usar read en lugar de watch para evitar reconstrucciones del router
  final authNotifier = ref.read(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    observers: [kineonRouteObserver],
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isAuthenticated;
      final currentPath = state.matchedLocation;

      final isGoingToLogin = currentPath == AppRoutes.login;

      // Si está autenticado y va a login → redirigir a home
      if (isLoggedIn && isGoingToLogin) {
        return AppRoutes.home;
      }

      // Si NO está autenticado y va a ruta protegida → redirigir a login
      final isProtectedRoute = AppRoutes.protectedRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      if (!isLoggedIn && isProtectedRoute) {
        return '${AppRoutes.login}?redirect=${Uri.encodeComponent(currentPath)}';
      }

      return null;
    },
    routes: [
      // =====================================================
      // SPLASH
      // =====================================================
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // =====================================================
      // ONBOARDING
      // =====================================================
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // =====================================================
      // AUTH ROUTES
      // =====================================================
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(redirectUrl: redirect);
        },
      ),

      // =====================================================
      // STATEFUL SHELL - Bottom Navigation con estado preservado
      // =====================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // ─────────────────────────────────────────────────
          // TAB 0: Home
          // ─────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),

          // ─────────────────────────────────────────────────
          // TAB 1: Search (Intelligent Discovery)
          // ─────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: IntelligentDiscoveryScreen(),
                ),
              ),
            ],
          ),

          // ─────────────────────────────────────────────────
          // TAB 2: AI Assistant
          // ─────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAiKey,
            routes: [
              GoRoute(
                path: AppRoutes.ai,
                name: 'ai',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AiAssistantScreen(),
                ),
              ),
            ],
          ),

          // ─────────────────────────────────────────────────
          // TAB 3: Library
          // ─────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLibraryKey,
            routes: [
              GoRoute(
                path: AppRoutes.library,
                name: 'library',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LibraryScreen(),
                ),
              ),
            ],
          ),

          // ─────────────────────────────────────────────────
          // TAB 4: Profile
          // ─────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileMockScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // =====================================================
      // DETAIL ROUTES (Pantalla completa, fuera del shell)
      // =====================================================

      // Ruta para mock screen (desde Home con mock data)
      GoRoute(
        path: '/movie/:id',
        name: 'movie-detail',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MaterialPage(
            fullscreenDialog: true,
            child: MovieDetailMockScreen(movieId: id),
          );
        },
      ),

      // Ruta principal de detalles (diseño Stitch con datos TMDB reales)
      GoRoute(
        path: AppRoutes.details,
        name: 'details',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final type = state.pathParameters['type']!;
          final id = int.parse(state.pathParameters['id']!);
          final isMovie = type == 'movie';
          return MaterialPage(
            fullscreenDialog: true,
            child: MovieDetailMockScreen(movieId: id, isMovie: isMovie),
          );
        },
      ),

      // Ruta para lista de medios (Ver todo)
      GoRoute(
        path: AppRoutes.mediaList,
        name: 'media-list',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final typeParam = state.pathParameters['type']!;
          final listType = MediaListType.fromString(typeParam);
          return MaterialPage(
            child: MediaListScreen(listType: listType),
          );
        },
      ),

      // Ruta para Smart Collection detail
      GoRoute(
        path: '/collection/:slug',
        name: 'collection-detail',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return MaterialPage(
            child: SmartCollectionDetailScreen(slug: slug),
          );
        },
      ),

      // Ruta para Stories (fullscreen modal)
      GoRoute(
        path: AppRoutes.stories,
        name: 'stories',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: StoriesScreen(),
          );
        },
      ),

      // Ruta para suscripción Pro
      GoRoute(
        path: '/profile/subscription',
        name: 'subscription',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          return const MaterialPage(
            fullscreenDialog: true,
            child: SubscriptionScreen(),
          );
        },
      ),

      // Ruta para detalle de lista personalizada
      GoRoute(
        path: '/library/list/:id',
        name: 'list-detail',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final name = state.uri.queryParameters['name'] ?? 'Lista';
          final icon = state.uri.queryParameters['icon'] ?? 'icon_0';
          return MaterialPage(
            child: ListDetailScreen(
              listId: id,
              listName: name,
              listIcon: icon,
            ),
          );
        },
      ),
    ],

    // =====================================================
    // ERROR HANDLER
    // =====================================================
    errorBuilder: (context, state) => _ErrorScreen(
      error: state.error?.message ?? 'Página no encontrada',
    ),
  );
});

// =====================================================
// MAIN SCAFFOLD CON BOTTOM NAVIGATION
// =====================================================

class _MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _MainScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(connectivityProvider).isOffline;

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          // Banner de offline en la parte superior
          if (isOffline) const OfflineBanner(),
          // Contenido principal
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: KineonBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    // goBranch navega al branch preservando su estado
    navigationShell.goBranch(
      index,
      // Si toca el tab actual, vuelve al inicio del branch
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

// =====================================================
// PREMIUM BOTTOM NAVIGATION BAR - Floating Pill Design
// =====================================================

class KineonBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KineonBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding + 16,
      ),
      child: SizedBox(
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background bar con blur
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.navBarBackground.withValues(alpha: isDark ? 0.85 : 0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: colors.navBarBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation items - positioned to fill the bar
            Positioned.fill(
              child: Row(
                children: [
                Expanded(
                  child: _KineonNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: l10n.navHome,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                Expanded(
                  child: _KineonNavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search_rounded,
                    label: l10n.navSearch,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                // AI Button - Special design with circle
                Expanded(
                  child: _KineonAINavItem(
                    label: l10n.navAI,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                ),
                Expanded(
                  child: _KineonNavItem(
                    icon: Icons.video_library_outlined,
                    activeIcon: Icons.video_library_rounded,
                    label: l10n.navLibrary,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                Expanded(
                  child: _KineonNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: l10n.strings.navProfile,
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NAV ITEMS — tabs normales con más presencia visual (#4)
// ─────────────────────────────────────────────────────────────

class _KineonNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _KineonNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isSelected ? colors.accent : colors.navIconInactive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: isSelected
                ? BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  )
                : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey('${label}_$isSelected'),
                color: color,
                size: 22, // +2px vs antes (20) — más presencia (#4)
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected
                  ? colors.accent
                  : colors.navIconInactive.withValues(alpha: 0.85), // más contraste (#4)
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.1,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI NAV ITEM — Kino con bounce, haptic y glow contextual
// ─────────────────────────────────────────────────────────────

class _KineonAINavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _KineonAINavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_KineonAINavItem> createState() => _KineonAINavItemState();
}

class _KineonAINavItemState extends State<_KineonAINavItem>
    with SingleTickerProviderStateMixin {
  static const _cyanColor = Color(0xFF5EEAD4);

  // Bounce animation (#5)
  late final AnimationController _bounceController;
  late final Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _bounceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.88), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.04), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact(); // haptic feedback (#5)
    _bounceController.forward(from: 0); // bounce (#5)
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Kino circle — 46px (#1: reducido ~12% desde 52)
            Positioned(
              top: -2, // menos flotante (#2)
              child: AnimatedBuilder(
                animation: _bounceScale,
                builder: (context, child) => Transform.scale(
                  scale: _bounceScale.value,
                  child: child,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyanColor,
                    boxShadow: [
                      BoxShadow(
                        color: _cyanColor.withValues(
                          alpha: widget.isSelected ? 0.35 : 0.18, // glow contextual (#3)
                        ),
                        blurRadius: widget.isSelected ? 10 : 6, // shadow reducido 25% (#2)
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: KinoIcon(size: 28, color: Colors.white),
                  ),
                ),
              ),
            ),
            // Label — Kino como nombre
            Positioned(
              bottom: 8,
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? _cyanColor : colors.navIconInactive,
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// ERROR SCREEN
// =====================================================

class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// HELPER: Navegación después de login exitoso
// =====================================================

extension GoRouterAuthExtension on GoRouter {
  void goAfterLogin(String? redirectUrl) {
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      go(Uri.decodeComponent(redirectUrl));
    } else {
      go(AppRoutes.home);
    }
  }
}

// =====================================================
// HELPER: Navegación a detalles
// =====================================================

extension GoRouterDetailsExtension on BuildContext {
  /// Navega a los detalles de una película
  void goToMovieDetails(int id) {
    push('/details/movie/$id');
  }

  /// Navega a los detalles de una serie
  void goToTvDetails(int id) {
    push('/details/tv/$id');
  }

  /// Navega a detalles genérico
  void goToDetails(String type, int id) {
    push('/details/$type/$id');
  }

  /// Navega al perfil (tab)
  void goToProfile() {
    go(AppRoutes.profile);
  }

  /// Navega a lista de medios (Ver todo)
  void goToMediaList(MediaListType listType) {
    push('/list/${listType.value}');
  }
}
