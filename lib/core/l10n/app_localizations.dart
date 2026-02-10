import 'package:flutter/material.dart';

import 'strings/strings_en.dart';
import 'strings/strings_es.dart';

/// Clase principal de localización
///
/// Uso: AppLocalizations.of(context).welcomeTitle
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Obtener instancia desde el contexto
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Delegate para MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Mapa de traducciones por idioma
  static final Map<String, AppStrings> _localizedStrings = {
    'es': StringsEs(),
    'en': StringsEn(),
  };

  /// Obtener las strings del idioma actual
  AppStrings get strings =>
      _localizedStrings[locale.languageCode] ?? _localizedStrings['es']!;

  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING
  // ═══════════════════════════════════════════════════════════════════════════

  String get onboardingSkip => strings.onboardingSkip;
  String get onboardingNext => strings.onboardingNext;
  String get onboardingStart => strings.onboardingStart;
  String onboardingStep(int current, int total) =>
      strings.onboardingStep(current, total);

  // Slide 1
  String get onboardingTitle1 => strings.onboardingTitle1;
  String get onboardingAccent1 => strings.onboardingAccent1;
  String get onboardingDesc1 => strings.onboardingDesc1;

  // Slide 2
  String get onboardingTitle2 => strings.onboardingTitle2;
  String get onboardingAccent2 => strings.onboardingAccent2;
  String get onboardingDesc2 => strings.onboardingDesc2;

  // Slide 3
  String get onboardingTitle3 => strings.onboardingTitle3;
  String get onboardingAccent3 => strings.onboardingAccent3;
  String get onboardingDesc3 => strings.onboardingDesc3;

  // Preferences
  String get onboardingPrefsTitle => strings.onboardingPrefsTitle;
  String get onboardingPrefsSubtitle => strings.onboardingPrefsSubtitle;

  // Moods
  String get moodHappy => strings.moodHappy;
  String get moodEpic => strings.moodEpic;
  String get moodReflective => strings.moodReflective;
  String get moodIntense => strings.moodIntense;
  String get moodRelaxed => strings.moodRelaxed;
  String get moodNostalgic => strings.moodNostalgic;

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════════════════

  String get loginHeadline1 => strings.loginHeadline1;
  String get loginHeadline2 => strings.loginHeadline2;
  String get loginHeadline3 => strings.loginHeadline3;
  String get loginTagline => strings.loginTagline;
  String get loginContinueApple => strings.loginContinueApple;
  String get loginContinueGoogle => strings.loginContinueGoogle;
  String get loginSocialProof => strings.loginSocialProof;
  String get loginTermsPrefix => strings.loginTermsPrefix;
  String get loginTermsOfService => strings.loginTermsOfService;
  String get loginPrivacyPolicy => strings.loginPrivacyPolicy;
  String get loginErrorGoogle => strings.loginErrorGoogle;
  String get loginErrorApple => strings.loginErrorApple;

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  String get navHome => strings.navHome;
  String get navSearch => strings.navSearch;
  String get navAI => strings.navAI;
  String get navLibrary => strings.navLibrary;

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL
  // ═══════════════════════════════════════════════════════════════════════════

  String get appName => strings.appName;
  String get language => strings.language;
  String get selectLanguage => strings.selectLanguage;

  // ═══════════════════════════════════════════════════════════════════════════
  // MOVIE DETAIL
  // ═══════════════════════════════════════════════════════════════════════════

  String get detailWatchlist => strings.detailWatchlist;
  String get detailFavorite => strings.detailFavorite;
  String get detailSeen => strings.detailSeen;
  String get detailShare => strings.detailShare;
  String get detailSynopsis => strings.detailSynopsis;
  String get detailTrailers => strings.detailTrailers;
  String get detailCast => strings.detailCast;
  String get detailAiTitle => strings.detailAiTitle;
  String get detailWatchNow => strings.detailWatchNow;
  String get detailSeeAll => strings.detailSeeAll;
  String get detailNoCast => strings.detailNoCast;
  String get detailNoTrailers => strings.detailNoTrailers;
  String get detailErrorLoading => strings.detailErrorLoading;
  String get detailRetry => strings.detailRetry;

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME
  // ═══════════════════════════════════════════════════════════════════════════

  String get homeWelcome => strings.homeWelcome;
  String homeGreeting(String name) => strings.homeGreeting(name);
  String get homeForYouToday => strings.homeForYouToday;
  String get homeAiCurated => strings.homeAiCurated;
  String get homeQuickDecide => strings.homeQuickDecide;
  String get homeMyList => strings.homeMyList;
  String get homeNotInterested => strings.homeNotInterested;
  String get homeViewDetails => strings.homeViewDetails;
  String get homeTrending => strings.homeTrending;
  String get homeNewReleases => strings.homeNewReleases;
  String get homeTopRated => strings.homeTopRated;
  String get homeQuickWatch => strings.homeQuickWatch;
  String get homeQuickWatchBadge => strings.homeQuickWatchBadge;
  String get homeBingeWorthy => strings.homeBingeWorthy;
  String get homeSeeAll => strings.homeSeeAll;
  String get homeInList => strings.homeInList;
  String get homePopular => strings.homePopular;
  String get homeTrendingTv => strings.homeTrendingTv;
  String get homeUpcoming => strings.homeUpcoming;

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIA LIST
  // ═══════════════════════════════════════════════════════════════════════════

  String get listCuratedDiscovery => strings.listCuratedDiscovery;
  String get listTrendingMovies => strings.listTrendingMovies;
  String get listTrendingTv => strings.listTrendingTv;
  String get listPopular => strings.listPopular;
  String get listTopRated => strings.listTopRated;
  String get listUpcoming => strings.listUpcoming;
  String get listNowPlaying => strings.listNowPlaying;

  // ═══════════════════════════════════════════════════════════════════════════
  // PREFERENCES SELECTOR (ONBOARDING)
  // ═══════════════════════════════════════════════════════════════════════════

  String get prefsTellUs => strings.prefsTellUs;
  String get prefsYourPreferences => strings.prefsYourPreferences;
  String get prefsSelectDescription => strings.prefsSelectDescription;
  String get prefsFavoriteGenres => strings.prefsFavoriteGenres;
  String get prefsMoodQuestion => strings.prefsMoodQuestion;
  String get prefsMoodHint => strings.prefsMoodHint;
  String get prefsSaving => strings.prefsSaving;

  // Genre names
  String get genreAction => strings.genreAction;
  String get genreComedy => strings.genreComedy;
  String get genreDrama => strings.genreDrama;
  String get genreSciFi => strings.genreSciFi;
  String get genreHorror => strings.genreHorror;
  String get genreRomance => strings.genreRomance;
  String get genreThriller => strings.genreThriller;
  String get genreAnimation => strings.genreAnimation;
  String get genreDocumentary => strings.genreDocumentary;
  String get genreFantasy => strings.genreFantasy;

  // AI Picks Personalization
  String get aiPicksBasedOnPreferences => strings.aiPicksBasedOnPreferences;
  String get aiPicksBasedOnHistory => strings.aiPicksBasedOnHistory;
  String get aiPicksTrending => strings.aiPicksTrending;
  String get aiPicksColdStart => strings.aiPicksColdStart;
  String get aiPicksRefresh => strings.aiPicksRefresh;
  String get aiPicksRefine => strings.aiPicksRefine;
  String get aiPicksPersonalize => strings.aiPicksPersonalize;
  String get aiPicksContentMovie => strings.aiPicksContentMovie;
  String get aiPicksContentSeries => strings.aiPicksContentSeries;
  String get aiPicksMatchBadge => strings.aiPicksMatchBadge;
  String get aiPicksTrendingBadge => strings.aiPicksTrendingBadge;

  // Quick Preferences Bottom Sheet
  String get quickPrefsTitle => strings.quickPrefsTitle;
  String get quickPrefsSubtitle => strings.quickPrefsSubtitle;
  String get quickPrefsMoodLabel => strings.quickPrefsMoodLabel;
  String get quickPrefsMoodHint => strings.quickPrefsMoodHint;
  String get quickPrefsGenresLabel => strings.quickPrefsGenresLabel;
  String get quickPrefsSave => strings.quickPrefsSave;
  String get quickPrefsCancel => strings.quickPrefsCancel;

  // AI Chat
  String get aiTitle => strings.aiTitle;
  String get aiAskKineon => strings.aiAskKineon;
  String get aiMatch => strings.aiMatch;
  String get aiAddToList => strings.aiAddToList;
  String get aiThinking => strings.aiThinking;
  String get aiIntelligence => strings.aiIntelligence;
  String get aiWelcomeMessage => strings.aiWelcomeMessage;
  String get aiAddedToList => strings.aiAddedToList;
  String get aiErrorMessage => strings.aiErrorMessage;
  String get aiErrorRetry => strings.aiErrorRetry;
  String get aiQuickReplyRelax => strings.aiQuickReplyRelax;
  String get aiQuickReplySciFi => strings.aiQuickReplySciFi;
  String get aiQuickReplyCouple => strings.aiQuickReplyCouple;
  String get aiQuickReplySurprise => strings.aiQuickReplySurprise;
  String get aiQuickReplyRetry => strings.aiQuickReplyRetry;
  String get aiQuickReplyPopular => strings.aiQuickReplyPopular;
  String get aiListening => strings.aiListening;
  String get aiSpeechNotAvailable => strings.aiSpeechNotAvailable;
  // AI Welcome Screen
  String get aiWelcomeHello => strings.aiWelcomeHello;
  String get aiWelcomeGreeting => strings.aiWelcomeGreeting;
  String get aiViewHistory => strings.aiViewHistory;
  String get aiNewChat => strings.aiNewChat;

  // Kino Mascot
  String get kinoTagline => strings.kinoTagline;
  String get kinoLoadingPicks => strings.kinoLoadingPicks;
  String get kinoLoadingPicksHint => strings.kinoLoadingPicksHint;
  String get kinoRefiningPicks => strings.kinoRefiningPicks;
  String get kinoErrorTitle => strings.kinoErrorTitle;
  String get kinoRetry => strings.kinoRetry;

  String get noTitle => strings.noTitle;

  // Watch Providers
  String get whereToWatch => strings.whereToWatch;
  String get watchProviderStreaming => strings.watchProviderStreaming;
  String get watchProviderRent => strings.watchProviderRent;
  String get watchProviderBuy => strings.watchProviderBuy;
  String get watchProviderPoweredBy => strings.watchProviderPoweredBy;
  String get watchProviderNotAvailable => strings.watchProviderNotAvailable;

  // Streaming Filter
  String get searchFilterStreaming => strings.searchFilterStreaming;
  String searchFilterStreamingCount(int count) => strings.searchFilterStreamingCount(count);
  String get searchFilterStreamingApply => strings.searchFilterStreamingApply;

  // Smart Collections
  String get smartCollections => strings.smartCollections;
  String get smartCollectionsSubtitle => strings.smartCollectionsSubtitle;
  String collectionItems(int count) => strings.collectionItems(count);
  String get collectionWhyIncluded => strings.collectionWhyIncluded;
  String get collectionShare => strings.collectionShare;
  String get collectionEmpty => strings.collectionEmpty;
  String get collectionLoading => strings.collectionLoading;

  // In Theaters
  String get inTheaters => strings.inTheaters;
  String get inTheatersKinoMessage => strings.inTheatersKinoMessage;
  String get inTheatersFindCinemas => strings.inTheatersFindCinemas;
  String get inTheatersRegionalChain => strings.inTheatersRegionalChain;
  String get inTheatersShowtimes => strings.inTheatersShowtimes;
  String get inTheatersRemindMe => strings.inTheatersRemindMe;
  String get inTheatersInviteFriends => strings.inTheatersInviteFriends;
  String get inTheatersReminderSet => strings.inTheatersReminderSet;
  String inTheatersShareText(String title) => strings.inTheatersShareText(title);

  // Onboarding Pro Teaser (Slide 4)
  String get onboardingTitle4 => strings.onboardingTitle4;
  String get onboardingAccent4 => strings.onboardingAccent4;
  String get onboardingDesc4 => strings.onboardingDesc4;
  String get onboardingProFeature1 => strings.onboardingProFeature1;
  String get onboardingProFeature2 => strings.onboardingProFeature2;
  String get onboardingProFeature3 => strings.onboardingProFeature3;
  String get onboardingProFeature4 => strings.onboardingProFeature4;
  String get onboardingProFeature5 => strings.onboardingProFeature5;
  String get onboardingProFeature6 => strings.onboardingProFeature6;
  String get onboardingProBadge => strings.onboardingProBadge;

  // Usage Progress Bar
  String usageRemaining(int used, int total) => strings.usageRemaining(used, total);
  String get usageUnlimited => strings.usageUnlimited;
  String get usageUpgradeCta => strings.usageUpgradeCta;
  String get usageAiCredits => strings.usageAiCredits;

  // Smart Paywall (Positive moments)
  String get smartPaywallTitle => strings.smartPaywallTitle;
  String get smartPaywallSubtitle => strings.smartPaywallSubtitle;
  String get smartPaywallCta => strings.smartPaywallCta;
  String get smartPaywallDismiss => strings.smartPaywallDismiss;
  String get smartPaywallTrialHint => strings.smartPaywallTrialHint;

  // Stories
  String get storiesTitle => strings.storiesTitle;
  String get storiesDescription => strings.storiesDescription;
  String get storiesCta => strings.storiesCta;
  String get storiesLoading => strings.storiesLoading;
  String get storiesEmpty => strings.storiesEmpty;
  String get storiesError => strings.storiesError;
  String get storiesSwipeHint => strings.storiesSwipeHint;
  String get storiesTapToDetails => strings.storiesTapToDetails;
  String get storiesEndTitle => strings.storiesEndTitle;
  String get storiesEndSubtitle => strings.storiesEndSubtitle;
  String get storiesEndAction => strings.storiesEndAction;
  String get storiesSessionCount => strings.storiesSessionCount;
  String get storiesProTitle => strings.storiesProTitle;
  String get storiesProSubtitle => strings.storiesProSubtitle;
  String get storiesProCta => strings.storiesProCta;
  String get storiesProFreeLabel => strings.storiesProFreeLabel;
}

/// Delegate para cargar las localizaciones
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Clase abstracta con todas las strings
abstract class AppStrings {
  // Onboarding
  String get onboardingSkip;
  String get onboardingNext;
  String get onboardingStart;
  String onboardingStep(int current, int total);

  String get onboardingTitle1;
  String get onboardingAccent1;
  String get onboardingDesc1;

  String get onboardingTitle2;
  String get onboardingAccent2;
  String get onboardingDesc2;

  String get onboardingTitle3;
  String get onboardingAccent3;
  String get onboardingDesc3;

  String get onboardingPrefsTitle;
  String get onboardingPrefsSubtitle;

  // Moods
  String get moodHappy;
  String get moodEpic;
  String get moodReflective;
  String get moodIntense;
  String get moodRelaxed;
  String get moodNostalgic;

  // Login
  String get loginHeadline1;
  String get loginHeadline2;
  String get loginHeadline3;
  String get loginTagline;
  String get loginContinueApple;
  String get loginContinueGoogle;
  String get loginSocialProof;
  String get loginTermsPrefix;
  String get loginTermsOfService;
  String get loginPrivacyPolicy;
  String get loginErrorGoogle;
  String get loginErrorApple;

  // Navigation
  String get navHome;
  String get navSearch;
  String get navAI;
  String get navLibrary;
  String get navProfile;

  // General
  String get appName;
  String get language;
  String get selectLanguage;

  // Movie Detail
  String get detailWatchlist;
  String get detailFavorite;
  String get detailSeen;
  String get detailShare;
  String get detailSynopsis;
  String get detailTrailers;
  String get detailCast;
  String get detailAiTitle;
  String get detailWatchNow;
  String get detailSeeAll;
  String get detailNoCast;
  String get detailNoTrailers;
  String get detailErrorLoading;
  String get detailRetry;
  String get detailTapToReveal;
  String get detailShowMore;
  String get detailShowLess;
  String get detailAddToList;

  // Home
  String get homeWelcome;
  String homeGreeting(String name);
  String get homeForYouToday;
  String get homeAiCurated;
  String get homeQuickDecide;
  String get homeMyList;
  String get homeNotInterested;
  String get homeViewDetails;
  String get homeTrending;
  String get homeNewReleases;
  String get homeTopRated;
  String get homeQuickWatch;
  String get homeQuickWatchBadge;
  String get homeBingeWorthy;
  String get homeSeeAll;
  String get homeInList;
  String get homePopular;
  String get homeTrendingTv;
  String get homeUpcoming;

  // Media List Screen
  String get listCuratedDiscovery;
  String get listTrendingMovies;
  String get listTrendingTv;
  String get listPopular;
  String get listTopRated;
  String get listUpcoming;
  String get listNowPlaying;

  // Search
  String get searchIntelligent;
  String get searchDiscovery;
  String get searchHint;
  String get searchFilterGenre;
  String get searchFilterMood;
  String get searchFilterRuntime;
  String get searchFilterYear;
  String get searchFilterStreaming;
  String searchFilterStreamingCount(int count);
  String get searchFilterStreamingApply;
  String get searchFilterRating;
  String get searchAiRecommended;
  String get searchMatch;
  String get searchEmptyTitle;
  String get searchEmptySubtitle;
  String get searchNoResultsTitle;
  String get searchNoResultsSubtitle;
  String get searchAddedFavorite;
  String get searchRemovedFavorite;
  String get searchAddedWatchlist;
  String get searchRemovedWatchlist;
  String get searchMarkedSeen;
  String get searchUnmarkedSeen;
  String get searchClear;
  String get searchFilterMaxRuntime;
  String get searchFilterMinRating;
  String get searchDiscoveryPlaceholder;
  String get searchDiscoveryListening;
  String get searchDiscoveryTryPrefix;
  String get searchDiscoveryEmptyTitle;
  String get searchDiscoveryEmptySubtitle;
  List<String> get searchDiscoverySuggestions;
  String get searchDiscoveryLoading;
  String get searchDiscoveryAiRecommended;
  String get searchDiscoveryMatch;
  String get searchDiscoveryErrorTitle;
  String get searchDiscoveryNoResultsTitle;
  String get searchDiscoveryNoResultsSubtitle;
  Map<int, String> get genreBadgeNames;
  List<String> get searchFilterMoodOptions;

  // AI Screen
  String get aiTitle;
  String get aiSubtitle;
  String get aiAskKineon;
  String get aiMatch;
  String get aiAddToList;
  String get aiThinking;
  String get aiWelcomeTitle;
  String get aiWelcomeSubtitle;
  String get aiErrorTitle;
  String get aiErrorMessage;
  String get aiRetry;
  String get aiQuickDecision;
  String get aiQuickDecisionSubtitle;
  String get aiQuickDecisionComplete;
  String get aiQuickDecisionCompleteSubtitle;
  String get aiIntelligence;
  String get aiWelcomeMessage;
  String get aiAddedToList;
  String get aiErrorRetry;
  String get aiQuickReplyRelax;
  String get aiQuickReplySciFi;
  String get aiQuickReplyCouple;
  String get aiQuickReplySurprise;
  String get aiQuickReplyRetry;
  String get aiQuickReplyPopular;
  String get aiListening;
  String get aiSpeechNotAvailable;

  // Library Screen
  String get libraryTitle;
  String get librarySearchHint;
  String get libraryCancel;
  String get libraryViewingHeatmap;
  String get libraryActiveActivity;
  String get libraryLast6Months;
  String get libraryLess;
  String get libraryMore;
  String get libraryWatchlist;
  String get libraryFavorites;
  String get libraryWatched;
  String get libraryMyLists;
  String get libraryCreateList;
  String get libraryChooseIcon;
  String get libraryListName;
  String get libraryListNameHint;
  String get libraryCreate;
  String get libraryCreateNewList;
  String get libraryEmptyWatchlistTitle;
  String get libraryEmptyWatchlistSubtitle;
  String get libraryEmptyFavoritesTitle;
  String get libraryEmptyFavoritesSubtitle;
  String get libraryEmptyWatchedTitle;
  String get libraryEmptyWatchedSubtitle;
  String get libraryEmptyListsTitle;
  String get libraryEmptyListsSubtitle;
  String get libraryExplore;
  String get librarySaveFirstMovie;
  String get libraryDiscover;
  String get libraryStartWatching;
  String get libraryCreateFirst;
  String get libraryNoResults;
  String get libraryNoResultsFor;
  String get libraryRenameList;
  String get libraryDeleteList;
  String libraryDeleteListConfirm(String listName);
  String get libraryNewList;

  // List Detail
  String get listDetailEmpty;
  String get listDetailEmptySubtitle;
  String get listDetailExplore;
  String get listDetailViewDetails;
  String get listDetailRemoveFromList;
  String get listDetailErrorLoading;
  String get listDetailNoTitle;

  // List Limits (Free vs Pro)
  String get listLimitMaxListsTitle;
  String listLimitMaxListsDesc(int limit);
  String get listLimitMaxItemsTitle;
  String listLimitMaxItemsDesc(int limit);
  String get listLimitProBenefit;
  String get listLimitUpgrade;

  // Common
  String get commonRetry;
  String get commonCancel;
  String get commonSave;
  String get commonDelete;

  // Global States
  String get stateEmptySearchTitle;
  String get stateEmptySearchSubtitle;
  String get stateEmptySearchAction;
  String get stateEmptyWatchlistTitle;
  String get stateEmptyWatchlistSubtitle;
  String get stateEmptyWatchlistAction;
  String get stateEmptyFavoritesTitle;
  String get stateEmptyFavoritesSubtitle;
  String get stateEmptyFavoritesAction;
  String get stateEmptyWatchedTitle;
  String get stateEmptyWatchedSubtitle;
  String get stateEmptyWatchedAction;
  String get stateEmptyListsTitle;
  String get stateEmptyListsSubtitle;
  String get stateEmptyListsAction;
  String get stateEmptyNotificationsTitle;
  String get stateEmptyNotificationsSubtitle;
  String get stateEmptyDownloadsTitle;
  String get stateEmptyDownloadsSubtitle;
  String get stateEmptyDownloadsAction;
  String get stateEmptyHistoryTitle;
  String get stateEmptyHistorySubtitle;
  String get stateEmptyGenericTitle;
  String get stateEmptyGenericSubtitle;
  String get stateErrorNetworkTitle;
  String get stateErrorNetworkMessage;
  String get stateErrorServerTitle;
  String get stateErrorServerMessage;
  String get stateErrorNotFoundTitle;
  String get stateErrorNotFoundMessage;
  String get stateErrorUnauthorizedTitle;
  String get stateErrorUnauthorizedMessage;
  String get stateErrorTimeoutTitle;
  String get stateErrorTimeoutMessage;
  String get stateErrorMaintenanceTitle;
  String get stateErrorMaintenanceMessage;
  String get stateErrorGenericTitle;
  String get stateErrorGenericMessage;
  String get stateActionRetry;
  String get stateActionBack;
  String get stateActionLogin;
  String get stateActionRefresh;
  String get stateActionExplore;
  String get stateActionDiscover;
  String get stateActionCreate;
  String get stateActionWatch;
  String get stateActionClearFilters;

  // Profile Screen
  String get profileTitle;
  String get profileMemberSince;
  String get profileProSubtitle;
  String get profileMonthly;
  String get profileAnnual;
  String get profilePerMonth;
  String get profileUpgradeFor;
  String get profileManageSubscription;
  String get profileProActive;
  String get profileRenews;
  String get profileManage;
  String get profileAppPreferences;
  String get profileHideSpoilers;
  String get profileStreamingRegion;
  String get profileAppearance;
  String get profileLanguage;
  String get profileSelectRegion;
  String get profileDarkMode;
  String get profileLightMode;
  String get profileSystemMode;
  String get profileDataProvidedBy;
  String get profilePrivacyPolicy;
  String get profileTermsOfService;
  String get profileMadeWith;
  String get profileForCinephiles;
  String get profileLogout;
  String get profileDeleteAccount;
  String get profileDeleteAccountWarning;
  String get profileDeleteAccountError;
  String get profileKineonPro;
  String get profileFeatureUnlimitedAI;
  String get profileFeatureUnlimitedChat;
  String get profileFeatureOfflineSync;
  String get profileFeatureEarlyAccess;
  String get profileFeatureUnlimitedLists;
  String get profileFeatureStories;
  String get profileFeatureSmartCollections;

  // Paywall
  String get paywallTitle;
  String paywallDescription(int limit, String feature);
  String get paywallUpgrade;
  String get paywallComeback;
  String get paywallResetTime;
  String get paywallProIncludes;
  String get paywallFeatureChat;
  String get paywallFeatureSearch;
  String get paywallFeatureRecommendations;
  String get paywallFeatureLists;
  String get paywallFeatureEarlyAccess;
  String get paywallFeatureAIChat;
  String get paywallFeatureAISearch;
  String get paywallFeatureAIInsight;
  String get paywallFeatureAIPicks;

  // Preferences Selector (Onboarding)
  String get prefsTellUs;
  String get prefsYourPreferences;
  String get prefsSelectDescription;
  String get prefsFavoriteGenres;
  String get prefsMoodQuestion;
  String get prefsMoodHint;
  String get prefsSaving;

  // Genre names
  String get genreAction;
  String get genreComedy;
  String get genreDrama;
  String get genreSciFi;
  String get genreHorror;
  String get genreRomance;
  String get genreThriller;
  String get genreAnimation;
  String get genreDocumentary;
  String get genreFantasy;

  // AI Picks Personalization
  String get aiPicksBasedOnPreferences;
  String get aiPicksBasedOnHistory;
  String get aiPicksTrending;
  String get aiPicksColdStart;
  String get aiPicksRefresh;
  String get aiPicksRefine;
  String get aiPicksPersonalize;
  String get aiPicksContentMovie;
  String get aiPicksContentSeries;
  String get aiPicksMatchBadge;
  String get aiPicksTrendingBadge;

  // Quick Preferences Bottom Sheet
  String get quickPrefsTitle;
  String get quickPrefsSubtitle;
  String get quickPrefsMoodLabel;
  String get quickPrefsMoodHint;
  String get quickPrefsGenresLabel;
  String get quickPrefsSave;
  String get quickPrefsCancel;

  // AI Welcome Screen
  String get aiWelcomeHello;
  String get aiWelcomeGreeting;
  String get aiViewHistory;
  String get aiNewChat;

  // Kino Mascot / AI states
  String get kinoTagline;
  String get kinoLoadingPicks;
  String get kinoLoadingPicksHint;
  String get kinoRefiningPicks;
  String get kinoErrorTitle;
  String get kinoRetry;

  // General Fallbacks
  String get noTitle;

  // Watch Providers
  String get whereToWatch;
  String get watchProviderStreaming;
  String get watchProviderRent;
  String get watchProviderBuy;
  String get watchProviderPoweredBy;
  String get watchProviderNotAvailable;

  // Smart Collections
  String get smartCollections;
  String get smartCollectionsSubtitle;
  String collectionItems(int count);
  String get collectionWhyIncluded;
  String get collectionShare;
  String get collectionEmpty;
  String get collectionLoading;

  // In Theaters
  String get inTheaters;
  String get inTheatersKinoMessage;
  String get inTheatersFindCinemas;
  String get inTheatersRegionalChain;
  String get inTheatersShowtimes;
  String get inTheatersRemindMe;
  String get inTheatersInviteFriends;
  String get inTheatersReminderSet;
  String inTheatersShareText(String title);

  // Onboarding Pro Teaser (Slide 4)
  String get onboardingTitle4;
  String get onboardingAccent4;
  String get onboardingDesc4;
  String get onboardingProFeature1;
  String get onboardingProFeature2;
  String get onboardingProFeature3;
  String get onboardingProFeature4;
  String get onboardingProFeature5;
  String get onboardingProFeature6;
  String get onboardingProBadge;

  // Usage Progress Bar
  String usageRemaining(int used, int total);
  String get usageUnlimited;
  String get usageUpgradeCta;
  String get usageAiCredits;

  // Smart Paywall (Positive moments)
  String get smartPaywallTitle;
  String get smartPaywallSubtitle;
  String get smartPaywallCta;
  String get smartPaywallDismiss;
  String get smartPaywallTrialHint;

  // Stories
  String get storiesTitle;
  String get storiesDescription;
  String get storiesCta;
  String get storiesLoading;
  String get storiesEmpty;
  String get storiesError;
  String get storiesSwipeHint;
  String get storiesTapToDetails;
  String get storiesEndTitle;
  String get storiesEndSubtitle;
  String get storiesEndAction;
  String get storiesSessionCount;
  String get storiesProTitle;
  String get storiesProSubtitle;
  String get storiesProCta;
  String get storiesProFreeLabel;
}
