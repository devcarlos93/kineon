import '../app_localizations.dart';

/// Traducciones en Español
class StringsEs implements AppStrings {
  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String onboardingStep(int current, int total) =>
      'PASO ${current.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}';

  @override
  String get onboardingTitle1 => 'Decide qué ver';

  @override
  String get onboardingAccent1 => 'sin perder tiempo.';

  @override
  String get onboardingDesc1 =>
      'La inteligencia artificial que entiende tus gustos cinematográficos para ofrecerte solo lo que te apasiona.';

  @override
  String get onboardingTitle2 => 'Recomendaciones por';

  @override
  String get onboardingAccent2 => 'mood y tiempo.';

  @override
  String get onboardingDesc2 =>
      '¿Tienes 90 minutos y quieres algo ligero? ¿O una noche épica de 3 horas? Kineon se adapta a ti.';

  @override
  String get onboardingTitle3 => 'Guarda, marca y';

  @override
  String get onboardingAccent3 => 'crea tus listas.';

  @override
  String get onboardingDesc3 =>
      'Organiza tu universo cinematográfico. Watchlist, favoritos, vistas y listas personalizadas.';

  @override
  String get onboardingPrefsTitle => '¿Qué géneros te gustan?';

  @override
  String get onboardingPrefsSubtitle =>
      'Selecciona al menos 3 para personalizar tus recomendaciones';

  @override
  String get moodHappy => 'Feliz';
  @override
  String get moodEpic => 'Épico';
  @override
  String get moodReflective => 'Reflexivo';
  @override
  String get moodIntense => 'Intenso';
  @override
  String get moodRelaxed => 'Relajado';
  @override
  String get moodNostalgic => 'Nostálgico';

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get loginHeadline1 => 'Descubre tu';

  @override
  String get loginHeadline2 => 'próxima';

  @override
  String get loginHeadline3 => 'obsesión.';

  @override
  String get loginTagline => 'Cine, curado por IA.';

  @override
  String get loginContinueApple => 'Continuar con Apple';

  @override
  String get loginContinueGoogle => 'Continuar con Google';

  @override
  String get loginSocialProof => 'Únete a 50k+ cinéfilos hoy.';

  @override
  String get loginTermsPrefix => 'Al continuar, aceptas los';

  @override
  String get loginTermsOfService => 'Términos de Servicio';

  @override
  String get loginPrivacyPolicy => 'Política de Privacidad';

  @override
  String get loginErrorGoogle => 'Error al iniciar sesión con Google';

  @override
  String get loginErrorApple => 'Error al iniciar sesión con Apple';

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get navHome => 'Inicio';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navAI => 'Kino';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navProfile => 'Perfil';

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get appName => 'Kineon';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  // ═══════════════════════════════════════════════════════════════════════════
  // MOVIE DETAIL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get detailWatchlist => 'WATCHLIST';

  @override
  String get detailFavorite => 'FAVORITO';

  @override
  String get detailSeen => 'VISTO';

  @override
  String get detailShare => 'COMPARTIR';

  @override
  String get detailSynopsis => 'SINOPSIS';

  @override
  String get detailTrailers => 'TRAILERS Y EXTRAS';

  @override
  String get detailCast => 'REPARTO';

  @override
  String get detailAiTitle => '¿Te conviene verla?';

  @override
  String get detailWatchNow => 'Ver ahora en 4K';

  @override
  String get detailSeeAll => 'Ver todos';

  @override
  String get detailNoCast => 'Sin información de reparto';

  @override
  String get detailNoTrailers => 'Sin trailers disponibles';

  @override
  String get detailErrorLoading => 'Error al cargar los detalles';

  @override
  String get detailRetry => 'Reintentar';

  @override
  String get detailTapToReveal => 'Toca para revelar';

  @override
  String get detailShowMore => 'Ver más';

  @override
  String get detailShowLess => 'Ver menos';

  @override
  String get detailAddToList => 'LISTA';

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get homeWelcome => 'BIENVENIDO';

  @override
  String homeGreeting(String name) => 'Hola, $name';

  @override
  String get homeForYouToday => 'Para ti hoy';

  @override
  String get homeAiCurated => 'IA CURATED';

  @override
  String get homeQuickDecide => 'Un toque y decides';

  @override
  String get homeMyList => 'Mi Lista';

  @override
  String get homeNotInterested => 'No me\ninteresa';

  @override
  String get homeViewDetails => 'Ver\ndetalles';

  @override
  String get homeTrending => 'Tendencias';

  @override
  String get homeNewReleases => 'Estrenos';

  @override
  String get homeTopRated => 'Mejor valoradas';

  @override
  String get homeQuickWatch => 'Cine rápido';

  @override
  String get homeQuickWatchBadge => 'MENOS DE 90 MIN';

  @override
  String get homeBingeWorthy => 'Series para maratón';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeInList => 'EN LISTA';

  @override
  String get homePopular => 'Populares';

  @override
  String get homeTrendingTv => 'Series en tendencia';

  @override
  String get homeUpcoming => 'Proximos estrenos';

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIA LIST
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get listCuratedDiscovery => 'DESCUBRIMIENTO CURADO';

  @override
  String get listTrendingMovies => 'Tendencias';

  @override
  String get listTrendingTv => 'Series en tendencia';

  @override
  String get listPopular => 'Populares';

  @override
  String get listTopRated => 'Mejor valoradas';

  @override
  String get listUpcoming => 'Proximos estrenos';

  @override
  String get listNowPlaying => 'Estrenos';

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get searchIntelligent => 'Inteligente';

  @override
  String get searchDiscovery => 'Descubre';

  @override
  String get searchHint => 'Algo como Interstellar...';

  @override
  String get searchFilterGenre => 'Género';

  @override
  String get searchFilterMood => 'Ambiente';

  @override
  String get searchFilterRuntime => 'Duración';

  @override
  String get searchFilterYear => 'Año';

  @override
  String get searchFilterStreaming => 'Plataforma';

  @override
  String searchFilterStreamingCount(int count) => '$count plataformas';

  @override
  String get searchFilterStreamingApply => 'Aplicar';

  @override
  String get searchFilterRating => 'Rating';

  @override
  String get searchAiRecommended => 'IA Recomendado';

  @override
  String get searchMatch => 'Match';

  @override
  String get searchEmptyTitle => 'Busca con IA';

  @override
  String get searchEmptySubtitle => 'Describe lo que quieres ver y la IA encontrará la película perfecta para ti';

  @override
  String get searchNoResultsTitle => 'Sin resultados';

  @override
  String get searchNoResultsSubtitle => 'No encontramos nada, prueba con otro mood o descripción';

  @override
  String get searchAddedFavorite => 'Añadido a favoritos';

  @override
  String get searchRemovedFavorite => 'Eliminado de favoritos';

  @override
  String get searchAddedWatchlist => 'Añadido a watchlist';

  @override
  String get searchRemovedWatchlist => 'Eliminado de watchlist';

  @override
  String get searchMarkedSeen => 'Marcado como visto';

  @override
  String get searchUnmarkedSeen => 'Desmarcado';

  @override
  String get searchClear => 'Limpiar';

  @override
  String get searchFilterMaxRuntime => 'Duración máx.';

  @override
  String get searchFilterMinRating => 'Rating mín.';

  @override
  String get searchDiscoveryPlaceholder => 'Algo como Interstellar...';

  @override
  String get searchDiscoveryListening => 'Escuchando...';

  @override
  String get searchDiscoveryTryPrefix => 'Prueba';

  @override
  String get searchDiscoveryEmptyTitle => 'Búsqueda Inteligente';

  @override
  String get searchDiscoveryEmptySubtitle => 'Describe lo que quieres ver y nuestra IA encontrará las mejores opciones para ti';

  @override
  String get searchDiscoveryLoading => 'Buscando contenido perfecto...';

  @override
  String get searchDiscoveryAiRecommended => 'Recomendado por IA';

  @override
  String get searchDiscoveryMatch => 'COINCIDENCIA';

  @override
  String get searchDiscoveryErrorTitle => 'Algo salió mal';

  @override
  String get searchDiscoveryNoResultsTitle => 'Sin resultados';

  @override
  String get searchDiscoveryNoResultsSubtitle => 'Intenta con otra descripción';

  @override
  Map<int, String> get genreBadgeNames => const {
    28: 'ACCIÓN', 12: 'AVENTURA', 16: 'ANIMACIÓN', 35: 'COMEDIA',
    80: 'CRIMEN', 99: 'DOCUMENTAL', 18: 'DRAMA', 10751: 'FAMILIA',
    14: 'FANTASÍA', 36: 'HISTORIA', 27: 'TERROR', 10402: 'MÚSICA',
    9648: 'MISTERIO', 10749: 'ROMANCE', 878: 'SCI-FI', 53: 'THRILLER',
    10752: 'GUERRA', 37: 'WESTERN', 10759: 'ACCIÓN', 10765: 'SCI-FI',
  };

  @override
  List<String> get searchFilterMoodOptions => const [
    'Emocionante', 'Relajante', 'Intenso', 'Divertido',
    'Romántico', 'Oscuro', 'Inspirador', 'Épico',
    'Misterioso', 'Nostálgico',
  ];

  @override
  List<String> get searchDiscoverySuggestions => const [
    'Algo como Interstellar pero más corto',
    'Comedia romántica para ver en pareja',
    'Serie de terror psicológico',
    'Película de los 80s de acción',
    'Algo relajante para el domingo',
    'Drama con final feliz',
    'Ciencia ficción con viajes en el tiempo',
    'Thriller de suspenso sin violencia',
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // AI SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get aiTitle => 'Kineon AI';

  @override
  String get aiSubtitle => 'Tu asistente cinematográfico';

  @override
  String get aiAskKineon => 'Pregúntame qué ver...';

  @override
  String get aiMatch => 'Match';

  @override
  String get aiAddToList => 'Añadir a lista';

  @override
  String get aiThinking => 'Pensando...';

  @override
  String get aiWelcomeTitle => '¿Qué te apetece ver?';

  @override
  String get aiWelcomeSubtitle => 'Describe lo que buscas y te recomendaré películas y series perfectas para ti';

  @override
  String get aiErrorTitle => 'Algo salió mal';

  @override
  String get aiErrorMessage => 'No pudimos procesar tu solicitud. Inténtalo de nuevo.';

  @override
  String get aiRetry => 'Reintentar';

  @override
  String get aiQuickDecision => 'Decisión rápida';

  @override
  String get aiQuickDecisionSubtitle => 'Desliza para entrenar tus gustos';

  @override
  String get aiQuickDecisionComplete => '¡Listo!';

  @override
  String get aiQuickDecisionCompleteSubtitle => 'Has completado todas las decisiones rápidas';

  @override
  String get aiIntelligence => 'KINEON INTELLIGENCE';

  @override
  String get aiWelcomeMessage => 'Cuéntame qué quieres ver hoy. Puedo recomendarte películas o series basadas en tu estado de ánimo, género favorito o algo similar a lo que ya te gustó.';

  @override
  String get aiAddedToList => 'Agregado a tu lista';

  @override
  String get aiErrorRetry => 'Lo siento, hubo un problema al procesar tu mensaje. ¿Intentamos de nuevo?';

  @override
  String get aiQuickReplyRelax => 'Algo para relajarme';

  @override
  String get aiQuickReplySciFi => 'Sci-fi mind-bending';

  @override
  String get aiQuickReplyCouple => 'Para ver en pareja';

  @override
  String get aiQuickReplySurprise => 'Sorpréndeme';

  @override
  String get aiQuickReplyRetry => 'Reintentar';

  @override
  String get aiQuickReplyPopular => 'Algo popular';

  @override
  String get aiListening => 'Escuchando...';

  @override
  String get aiSpeechNotAvailable => 'Reconocimiento de voz no disponible';

  // ═══════════════════════════════════════════════════════════════════════════
  // LIBRARY SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get libraryTitle => 'Mi Biblioteca';

  @override
  String get librarySearchHint => 'Buscar en tu biblioteca...';

  @override
  String get libraryCancel => 'Cancelar';

  @override
  String get libraryViewingHeatmap => 'Historial de vistas';

  @override
  String get libraryActiveActivity => 'Actividad activa';

  @override
  String get libraryLast6Months => 'Últimos 6 meses';

  @override
  String get libraryLess => 'Menos';

  @override
  String get libraryMore => 'Más';

  @override
  String get libraryWatchlist => 'Watchlist';

  @override
  String get libraryFavorites => 'Favoritos';

  @override
  String get libraryWatched => 'Vistas';

  @override
  String get libraryMyLists => 'Mis listas';

  @override
  String get libraryCreateList => 'Crear lista';

  @override
  String get libraryChooseIcon => 'Elige un icono';

  @override
  String get libraryListName => 'Nombre de la lista';

  @override
  String get libraryListNameHint => 'Ej: Películas de terror';

  @override
  String get libraryCreate => 'Crear';

  @override
  String get libraryCreateNewList => 'Crear nueva lista';

  @override
  String get libraryEmptyWatchlistTitle => 'Aún no tienes watchlist';

  @override
  String get libraryEmptyWatchlistSubtitle => 'Nuestra IA te ayudará a encontrar películas perfectas para ti';

  @override
  String get libraryEmptyFavoritesTitle => 'Sin favoritos aún';

  @override
  String get libraryEmptyFavoritesSubtitle => 'Marca tus películas favoritas para encontrarlas fácilmente';

  @override
  String get libraryEmptyWatchedTitle => 'Nada visto todavía';

  @override
  String get libraryEmptyWatchedSubtitle => 'Lleva un registro de todo lo que ves';

  @override
  String get libraryEmptyListsTitle => 'Sin listas personalizadas';

  @override
  String get libraryEmptyListsSubtitle => 'Crea listas para organizar tu contenido favorito';

  @override
  String get libraryExplore => 'Explorar';

  @override
  String get librarySaveFirstMovie => 'Guardar mi primera película';

  @override
  String get libraryDiscover => 'Descubrir';

  @override
  String get libraryStartWatching => 'Empezar a ver';

  @override
  String get libraryCreateFirst => 'Crear mi primera lista';

  @override
  String get libraryNoResults => 'Sin resultados';

  @override
  String get libraryNoResultsFor => 'No encontramos nada para';

  @override
  String get libraryRenameList => 'Renombrar lista';

  @override
  String get libraryDeleteList => 'Eliminar lista';

  @override
  String libraryDeleteListConfirm(String listName) =>
      '¿Estás seguro de que quieres eliminar "$listName"? Esta acción no se puede deshacer.';

  @override
  String get libraryNewList => 'Nueva lista';

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST DETAIL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get listDetailEmpty => 'Lista vacía';

  @override
  String get listDetailEmptySubtitle => 'Añade películas o series desde sus detalles';

  @override
  String get listDetailExplore => 'Explorar';

  @override
  String get listDetailViewDetails => 'Ver detalles';

  @override
  String get listDetailRemoveFromList => 'Quitar de la lista';

  @override
  String get listDetailErrorLoading => 'Error al cargar la lista';

  @override
  String get listDetailNoTitle => 'Sin título';

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST LIMITS (Free vs Pro)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get listLimitMaxListsTitle => 'Límite de listas alcanzado';

  @override
  String listLimitMaxListsDesc(int limit) =>
      'Con la versión gratuita puedes crear hasta $limit lista. Hazte Pro para crear listas ilimitadas.';

  @override
  String get listLimitMaxItemsTitle => 'Lista llena';

  @override
  String listLimitMaxItemsDesc(int limit) =>
      'Con la versión gratuita puedes añadir hasta $limit items por lista. Hazte Pro para añadir ilimitados.';

  @override
  String get listLimitProBenefit => 'Pro: Listas y items ilimitados';

  @override
  String get listLimitUpgrade => 'Hazte Pro';

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOBAL STATES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get stateEmptySearchTitle => 'Sin resultados';
  @override
  String get stateEmptySearchSubtitle => 'Prueba con otra búsqueda';
  @override
  String get stateEmptySearchAction => 'Limpiar filtros';
  @override
  String get stateEmptyWatchlistTitle => 'Watchlist vacía';
  @override
  String get stateEmptyWatchlistSubtitle => 'Guarda lo que quieras ver después';
  @override
  String get stateEmptyWatchlistAction => 'Explorar';
  @override
  String get stateEmptyFavoritesTitle => 'Sin favoritos';
  @override
  String get stateEmptyFavoritesSubtitle => 'Marca tus películas favoritas';
  @override
  String get stateEmptyFavoritesAction => 'Descubrir';
  @override
  String get stateEmptyWatchedTitle => 'Nada visto aún';
  @override
  String get stateEmptyWatchedSubtitle => 'Tu historial aparecerá aquí';
  @override
  String get stateEmptyWatchedAction => 'Ver ahora';
  @override
  String get stateEmptyListsTitle => 'Sin listas';
  @override
  String get stateEmptyListsSubtitle => 'Organiza tu contenido favorito';
  @override
  String get stateEmptyListsAction => 'Crear lista';
  @override
  String get stateEmptyNotificationsTitle => 'Sin notificaciones';
  @override
  String get stateEmptyNotificationsSubtitle => 'Todo al día por aquí';
  @override
  String get stateEmptyDownloadsTitle => 'Sin descargas';
  @override
  String get stateEmptyDownloadsSubtitle => 'Descarga para ver offline';
  @override
  String get stateEmptyDownloadsAction => 'Explorar';
  @override
  String get stateEmptyHistoryTitle => 'Sin historial';
  @override
  String get stateEmptyHistorySubtitle => 'Tu actividad reciente aparecerá aquí';
  @override
  String get stateEmptyGenericTitle => 'Nada por aquí';
  @override
  String get stateEmptyGenericSubtitle => 'Este espacio está vacío';
  @override
  String get stateErrorNetworkTitle => 'Sin conexión';
  @override
  String get stateErrorNetworkMessage => 'Revisa tu conexión a internet';
  @override
  String get stateErrorServerTitle => 'Error del servidor';
  @override
  String get stateErrorServerMessage => 'Estamos trabajando en ello';
  @override
  String get stateErrorNotFoundTitle => 'No encontrado';
  @override
  String get stateErrorNotFoundMessage => 'El contenido no existe o fue eliminado';
  @override
  String get stateErrorUnauthorizedTitle => 'Sesión expirada';
  @override
  String get stateErrorUnauthorizedMessage => 'Inicia sesión de nuevo';
  @override
  String get stateErrorTimeoutTitle => 'Tiempo agotado';
  @override
  String get stateErrorTimeoutMessage => 'La solicitud tardó demasiado';
  @override
  String get stateErrorMaintenanceTitle => 'En mantenimiento';
  @override
  String get stateErrorMaintenanceMessage => 'Volveremos pronto, lo prometemos';
  @override
  String get stateErrorGenericTitle => 'Algo salió mal';
  @override
  String get stateErrorGenericMessage => 'Inténtalo de nuevo';
  @override
  String get stateActionRetry => 'Reintentar';
  @override
  String get stateActionBack => 'Volver';
  @override
  String get stateActionLogin => 'Iniciar sesión';
  @override
  String get stateActionRefresh => 'Actualizar';
  @override
  String get stateActionExplore => 'Explorar';
  @override
  String get stateActionDiscover => 'Descubrir';
  @override
  String get stateActionCreate => 'Crear';
  @override
  String get stateActionWatch => 'Ver ahora';
  @override
  String get stateActionClearFilters => 'Limpiar filtros';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileMemberSince => 'Miembro desde';

  @override
  String get profileProSubtitle => 'Desbloquea todo el potencial de Kineon';

  @override
  String get profileMonthly => 'Mensual';

  @override
  String get profileAnnual => 'Anual';

  @override
  String get profilePerMonth => '/mes';

  @override
  String get profileUpgradeFor => 'Mejorar por';

  @override
  String get profileManageSubscription => 'Gestionar suscripción';

  @override
  String get profileProActive => 'Kineon Pro Activo';

  @override
  String get profileRenews => 'Se renueva el';

  @override
  String get profileManage => 'Gestionar';

  @override
  String get profileAppPreferences => 'Preferencias de la app';

  @override
  String get profileHideSpoilers => 'Ocultar spoilers';

  @override
  String get profileStreamingRegion => 'Región de streaming';

  @override
  String get profileAppearance => 'Apariencia';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get profileSelectRegion => 'Seleccionar región';

  @override
  String get profileDarkMode => 'Modo oscuro';

  @override
  String get profileLightMode => 'Modo claro';

  @override
  String get profileSystemMode => 'Sistema';

  @override
  String get profileDataProvidedBy => 'Datos proporcionados por';

  @override
  String get profilePrivacyPolicy => 'Política de privacidad';

  @override
  String get profileTermsOfService => 'Términos de servicio';

  @override
  String get profileMadeWith => 'Hecho con';

  @override
  String get profileForCinephiles => 'para cinéfilos';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountWarning => 'Esta acción es irreversible. Se eliminarán todos tus datos, listas, preferencias e historial.';

  @override
  String get profileDeleteAccountError => 'No se pudo eliminar la cuenta. Inténtalo de nuevo más tarde.';

  @override
  String get profileKineonPro => 'Kineon Pro';

  @override
  String get profileFeatureUnlimitedAI => 'Recomendaciones IA ilimitadas';

  @override
  String get profileFeatureUnlimitedChat => 'Chat de IA ilimitado';

  @override
  String get profileFeatureOfflineSync => 'Sincronización offline';

  @override
  String get profileFeatureEarlyAccess => 'Acceso anticipado a nuevas funciones';

  @override
  String get profileFeatureUnlimitedLists => 'Listas personalizadas sin límites';

  @override
  String get profileFeatureStories => 'Historias basadas en tus gustos';

  @override
  String get profileFeatureSmartCollections => 'Colecciones inteligentes semanales';

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYWALL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get paywallTitle => 'Has alcanzado tu límite diario';

  @override
  String paywallDescription(int limit, String feature) =>
      'Tu plan gratuito incluye $limit usos diarios de $feature. Actualiza a Pro para disfrutar de IA ilimitada.';

  @override
  String get paywallUpgrade => 'Actualizar a Pro';

  @override
  String get paywallComeback => 'Vuelve mañana';

  @override
  String get paywallResetTime => 'Tu límite se renueva a medianoche';

  @override
  String get paywallProIncludes => 'Incluye:';

  @override
  String get paywallFeatureChat => 'Chat IA ilimitado';

  @override
  String get paywallFeatureSearch => 'Búsqueda inteligente sin límites';

  @override
  String get paywallFeatureRecommendations => 'Recomendaciones IA ilimitadas';

  @override
  String get paywallFeatureLists => 'Listas personalizadas sin límites';

  @override
  String get paywallFeatureEarlyAccess => 'Acceso adelantado a nuevas funciones';

  @override
  String get paywallFeatureAIChat => 'Chat IA';

  @override
  String get paywallFeatureAISearch => 'Búsqueda IA';

  @override
  String get paywallFeatureAIInsight => 'Insights IA';

  @override
  String get paywallFeatureAIPicks => 'Recomendaciones IA';

  // ═══════════════════════════════════════════════════════════════════════════
  // PREFERENCES SELECTOR (ONBOARDING)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get prefsTellUs => 'Cuéntanos';

  @override
  String get prefsYourPreferences => 'tus preferencias.';

  @override
  String get prefsSelectDescription => 'Selecciona lo que más te gusta para personalizar tus recomendaciones.';

  @override
  String get prefsFavoriteGenres => 'GÉNEROS FAVORITOS';

  @override
  String get prefsMoodQuestion => '¿QUÉ HUMOR TE DEFINE?';

  @override
  String get prefsMoodHint => 'Describe tu humor preferido...';

  @override
  String get prefsSaving => 'Guardando...';

  // Genre names
  @override
  String get genreAction => 'Acción';

  @override
  String get genreComedy => 'Comedia';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreSciFi => 'Sci-Fi';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreAnimation => 'Animación';

  @override
  String get genreDocumentary => 'Documental';

  @override
  String get genreFantasy => 'Fantasía';

  // ═══════════════════════════════════════════════════════════════════════════
  // AI PICKS PERSONALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get aiPicksBasedOnPreferences => 'Basado en tus gustos y mood';

  @override
  String get aiPicksBasedOnHistory => 'Basado en tu historial';

  @override
  String get aiPicksTrending => 'Trending ahora';

  @override
  String get aiPicksColdStart => 'Top picks para empezar';

  @override
  String get aiPicksRefresh => 'Refrescar';

  @override
  String get aiPicksRefine => 'Refinar';

  @override
  String get aiPicksPersonalize => 'Personalizar';

  @override
  String get aiPicksContentMovie => 'PELÍCULA';

  @override
  String get aiPicksContentSeries => 'SERIE';

  @override
  String get aiPicksMatchBadge => '98% MATCH';

  @override
  String get aiPicksTrendingBadge => 'TRENDING';

  // Quick Preferences Bottom Sheet
  @override
  String get quickPrefsTitle => 'Ajusta tus preferencias';

  @override
  String get quickPrefsSubtitle => 'Personaliza tus recomendaciones';

  @override
  String get quickPrefsMoodLabel => 'Tu mood actual';

  @override
  String get quickPrefsMoodHint => 'Ej: Algo ligero para relajarme...';

  @override
  String get quickPrefsGenresLabel => 'Géneros favoritos';

  @override
  String get quickPrefsSave => 'Guardar';

  @override
  String get quickPrefsCancel => 'Cancelar';

  // ═══════════════════════════════════════════════════════════════════════════
  // WATCH PROVIDERS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get whereToWatch => 'Dónde verla';

  @override
  String get watchProviderStreaming => 'Streaming';

  @override
  String get watchProviderRent => 'Alquilar';

  @override
  String get watchProviderBuy => 'Comprar';

  @override
  String get watchProviderPoweredBy => 'Datos de JustWatch';

  @override
  String get watchProviderNotAvailable => 'No disponible en tu país';

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART COLLECTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get smartCollections => 'Colecciones Inteligentes';

  @override
  String get smartCollectionsSubtitle => 'Selecciones curadas por IA';

  @override
  String collectionItems(int count) => '$count títulos';

  @override
  String get collectionWhyIncluded => 'Por qué está incluido';

  @override
  String get collectionShare => 'Compartir colección';

  @override
  String get collectionEmpty => 'No hay colecciones esta semana';

  @override
  String get collectionLoading => 'Cargando colecciones...';

  // ═══════════════════════════════════════════════════════════════════════════
  // EN CINES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get inTheaters => 'En cines';

  @override
  String get inTheatersKinoMessage => 'Te ayudo a encontrar cines';

  @override
  String get inTheatersFindCinemas => 'Buscar cines';

  @override
  String get inTheatersRegionalChain => 'Cadenas de cine';

  @override
  String get inTheatersShowtimes => 'Ver horarios';

  @override
  String get inTheatersRemindMe => 'Recordarme';

  @override
  String get inTheatersInviteFriends => 'Invitar amigos';

  @override
  String get inTheatersReminderSet => 'Recordatorio programado';

  @override
  String inTheatersShareText(String title) =>
      'Vamos a ver $title al cine! Mira detalles en Kineon';

  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING PRO TEASER (Slide 4)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get onboardingTitle4 => 'Lleva tu experiencia';

  @override
  String get onboardingAccent4 => 'al siguiente nivel.';

  @override
  String get onboardingDesc4 =>
      'Con Pro desbloqueas todo el poder de la IA para encontrar exactamente lo que quieres ver.';

  @override
  String get onboardingProFeature1 => 'Chat IA ilimitado';

  @override
  String get onboardingProFeature2 => 'Búsqueda inteligente sin límites';

  @override
  String get onboardingProFeature3 => 'Recomendaciones personalizadas';

  @override
  String get onboardingProFeature4 => 'Acceso anticipado a nuevas funciones';

  @override
  String get onboardingProFeature5 => 'Colecciones inteligentes semanales';

  @override
  String get onboardingProFeature6 => 'Historias cinematográficas con IA';

  @override
  String get onboardingProBadge => 'PRO';

  // ═══════════════════════════════════════════════════════════════════════════
  // USAGE PROGRESS BAR
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String usageRemaining(int used, int total) => '$used / $total usos hoy';

  @override
  String get usageUnlimited => 'Ilimitado';

  @override
  String get usageUpgradeCta => 'Desbloquear todo';

  @override
  String get usageAiCredits => 'Créditos IA';

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART PAYWALL (Positive moments)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get smartPaywallTitle => 'Te encanta, verdad?';

  @override
  String get smartPaywallSubtitle =>
      'Con Pro puedes disfrutar de esto sin límites, todos los días.';

  @override
  String get smartPaywallCta => 'Probar Pro gratis';

  @override
  String get smartPaywallDismiss => 'Ahora no';

  @override
  String get smartPaywallTrialHint => 'Cancela cuando quieras';

  // ═══════════════════════════════════════════════════════════════════════════
  // STORIES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get storiesTitle => 'Historias AI';

  @override
  String get storiesDescription => 'Descubre contenido con IA en pantalla completa';

  @override
  String get storiesCta => 'Ver ahora';

  @override
  String get storiesLoading => 'Preparando historias...';

  @override
  String get storiesEmpty => 'No hay historias disponibles';

  @override
  String get storiesError => 'Error al cargar historias';

  @override
  String get storiesSwipeHint => 'Desliza para descubrir';

  @override
  String get storiesTapToDetails => 'Toca para ver detalles';

  @override
  String get storiesEndTitle => 'Has visto todas las historias';

  @override
  String get storiesEndSubtitle => 'Vuelve más tarde para nuevas recomendaciones';

  @override
  String get storiesEndAction => 'Volver al inicio';

  @override
  String get storiesSessionCount => 'sesiones hoy';

  @override
  String get storiesProTitle => '¡Te encanta lo que ves!';

  @override
  String get storiesProSubtitle =>
      'Hay muchas más historias esperándote. Desbloquea acceso ilimitado y descubre películas que te van a encantar.';

  @override
  String get storiesProCta => 'Desbloquear con Pro';

  @override
  String get storiesProFreeLabel => '3 gratis';

  // ═══════════════════════════════════════════════════════════════════════════
  // AI WELCOME SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get aiWelcomeHello => 'Hola, soy ';

  @override
  String get aiWelcomeGreeting => 'Estoy aquí para ayudarte a descubrir películas y series perfectas para ti.';

  @override
  String get aiViewHistory => 'Ver historial';

  @override
  String get aiNewChat => 'Nuevo chat';

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL FALLBACKS
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // KINO MASCOT / AI STATES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get kinoTagline => 'Tu asistente de cine con IA';

  @override
  String get kinoLoadingPicks => 'Cargando recomendaciones...';

  @override
  String get kinoLoadingPicksHint => 'Desliza hacia abajo para actualizar';

  @override
  String get kinoRefiningPicks => 'Refinando recomendaciones...';

  @override
  String get kinoErrorTitle => 'Algo salió mal';

  @override
  String get kinoRetry => 'Reintentar';

  @override
  String get noTitle => 'Sin título';
}
