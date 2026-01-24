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
  String get navAI => 'IA';

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
  // GENERAL FALLBACKS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get noTitle => 'Sin título';
}
