import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/cache/cache_service.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/l10n.dart';
import 'core/l10n/locale_provider.dart';
import 'core/network/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

// Sentry DSN - configurar en dart-define o dejar vacío para deshabilitar
const String _sentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue: '',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar UI del sistema (se actualizará según el tema en el builder)

  // Inicializar Supabase
  await SupabaseConfig.initialize();

  // Inicializar caché local
  await CacheService().initialize();

  // Inicializar notificaciones
  await NotificationService().initialize();

  // Inicializar Analytics/Sentry
  await AnalyticsService.instance.initialize(sentryDsn: _sentryDsn);

  // Configurar usuario si ya está autenticado
  final currentUser = Supabase.instance.client.auth.currentUser;
  if (currentUser != null) {
    AnalyticsService.instance.setUser(
      currentUser.id,
      email: currentUser.email,
    );
  }

  runApp(
    // Envolver con SentryWidget para capturar errores de UI
    SentryWidget(
      child: const ProviderScope(
        child: KineonApp(),
      ),
    ),
  );
}

class KineonApp extends ConsumerWidget {
  const KineonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kineon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      // Localización
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Configurar UI del sistema según el tema
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colors = Theme.of(context).extension<KineonColors>()!;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: colors.background,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        // Aplicar escala de texto máxima para accesibilidad
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
