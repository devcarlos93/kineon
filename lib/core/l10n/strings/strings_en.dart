import '../app_localizations.dart';

/// Traducciones en Inglés
class StringsEn implements AppStrings {
  // ═══════════════════════════════════════════════════════════════════════════
  // ONBOARDING
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String onboardingStep(int current, int total) =>
      'STEP ${current.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}';

  @override
  String get onboardingTitle1 => 'Decide what to watch';

  @override
  String get onboardingAccent1 => 'without wasting time.';

  @override
  String get onboardingDesc1 =>
      'AI that understands your cinematic tastes to offer you only what you\'re passionate about.';

  @override
  String get onboardingTitle2 => 'Recommendations by';

  @override
  String get onboardingAccent2 => 'mood and time.';

  @override
  String get onboardingDesc2 =>
      'Got 90 minutes and want something light? Or an epic 3-hour night? Kineon adapts to you.';

  @override
  String get onboardingTitle3 => 'Save, mark, and';

  @override
  String get onboardingAccent3 => 'create your lists.';

  @override
  String get onboardingDesc3 =>
      'Organize your cinematic universe. Watchlist, favorites, watched, and custom lists.';

  @override
  String get onboardingPrefsTitle => 'What genres do you like?';

  @override
  String get onboardingPrefsSubtitle =>
      'Select at least 3 to personalize your recommendations';

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get loginHeadline1 => 'Discover your';

  @override
  String get loginHeadline2 => 'next';

  @override
  String get loginHeadline3 => 'obsession.';

  @override
  String get loginTagline => 'Cinema, curated by AI.';

  @override
  String get loginContinueApple => 'Continue with Apple';

  @override
  String get loginContinueGoogle => 'Continue with Google';

  @override
  String get loginSocialProof => 'Join 50k+ cinephiles today.';

  @override
  String get loginTermsPrefix => 'By continuing, you agree to Kineon\'s';

  @override
  String get loginTermsOfService => 'Terms of Service';

  @override
  String get loginPrivacyPolicy => 'Privacy Policy';

  @override
  String get loginErrorGoogle => 'Error signing in with Google';

  @override
  String get loginErrorApple => 'Error signing in with Apple';

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navAI => 'AI';

  @override
  String get navLibrary => 'Library';

  @override
  String get navProfile => 'Profile';

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get appName => 'Kineon';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  // ═══════════════════════════════════════════════════════════════════════════
  // MOVIE DETAIL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get detailWatchlist => 'WATCHLIST';

  @override
  String get detailFavorite => 'FAVORITE';

  @override
  String get detailSeen => 'SEEN';

  @override
  String get detailShare => 'SHARE';

  @override
  String get detailSynopsis => 'SYNOPSIS';

  @override
  String get detailTrailers => 'TRAILERS & EXTRAS';

  @override
  String get detailCast => 'CAST';

  @override
  String get detailAiTitle => 'Should you watch it?';

  @override
  String get detailWatchNow => 'Watch now in 4K';

  @override
  String get detailSeeAll => 'See all';

  @override
  String get detailNoCast => 'No cast information';

  @override
  String get detailNoTrailers => 'No trailers available';

  @override
  String get detailErrorLoading => 'Error loading details';

  @override
  String get detailRetry => 'Retry';

  @override
  String get detailTapToReveal => 'Tap to reveal';

  @override
  String get detailShowMore => 'Show more';

  @override
  String get detailShowLess => 'Show less';

  @override
  String get detailAddToList => 'LIST';

  // ═══════════════════════════════════════════════════════════════════════════
  // HOME
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get homeWelcome => 'WELCOME';

  @override
  String homeGreeting(String name) => 'Hello, $name';

  @override
  String get homeForYouToday => 'For you today';

  @override
  String get homeAiCurated => 'AI CURATED';

  @override
  String get homeQuickDecide => 'One tap and decide';

  @override
  String get homeMyList => 'My List';

  @override
  String get homeNotInterested => 'Not\ninterested';

  @override
  String get homeViewDetails => 'View\ndetails';

  @override
  String get homeTrending => 'Trending';

  @override
  String get homeNewReleases => 'New Releases';

  @override
  String get homeTopRated => 'Top Rated';

  @override
  String get homeQuickWatch => 'Quick Watch';

  @override
  String get homeQuickWatchBadge => 'UNDER 90 MIN';

  @override
  String get homeBingeWorthy => 'Binge-worthy Series';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeInList => 'IN LIST';

  @override
  String get homePopular => 'Popular';

  @override
  String get homeTrendingTv => 'Trending TV Shows';

  @override
  String get homeUpcoming => 'Upcoming';

  // ═══════════════════════════════════════════════════════════════════════════
  // MEDIA LIST
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get listCuratedDiscovery => 'CURATED DISCOVERY';

  @override
  String get listTrendingMovies => 'Trending Now';

  @override
  String get listTrendingTv => 'Trending TV Shows';

  @override
  String get listPopular => 'Popular';

  @override
  String get listTopRated => 'Top Rated';

  @override
  String get listUpcoming => 'Upcoming';

  @override
  String get listNowPlaying => 'Now Playing';

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get searchIntelligent => 'Intelligent';

  @override
  String get searchDiscovery => 'Discovery';

  @override
  String get searchHint => 'Something like Interstellar...';

  @override
  String get searchFilterGenre => 'Genre';

  @override
  String get searchFilterMood => 'Mood';

  @override
  String get searchFilterRuntime => 'Runtime';

  @override
  String get searchFilterYear => 'Year';

  @override
  String get searchFilterRating => 'Rating';

  @override
  String get searchAiRecommended => 'AI Recommended';

  @override
  String get searchMatch => 'Match';

  @override
  String get searchEmptyTitle => 'Search with AI';

  @override
  String get searchEmptySubtitle => 'Describe what you want to watch and AI will find the perfect movie for you';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String get searchNoResultsSubtitle => 'We couldn\'t find anything, try another mood or description';

  @override
  String get searchAddedFavorite => 'Added to favorites';

  @override
  String get searchRemovedFavorite => 'Removed from favorites';

  @override
  String get searchAddedWatchlist => 'Added to watchlist';

  @override
  String get searchRemovedWatchlist => 'Removed from watchlist';

  @override
  String get searchMarkedSeen => 'Marked as seen';

  @override
  String get searchUnmarkedSeen => 'Unmarked';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchFilterMaxRuntime => 'Max Runtime';

  @override
  String get searchFilterMinRating => 'Min Rating';

  // ═══════════════════════════════════════════════════════════════════════════
  // AI SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get aiTitle => 'Kineon AI';

  @override
  String get aiSubtitle => 'Your cinematic assistant';

  @override
  String get aiAskKineon => 'Ask me what to watch...';

  @override
  String get aiMatch => 'Match';

  @override
  String get aiAddToList => 'Add to list';

  @override
  String get aiThinking => 'Thinking...';

  @override
  String get aiWelcomeTitle => 'What do you feel like watching?';

  @override
  String get aiWelcomeSubtitle => 'Describe what you\'re looking for and I\'ll recommend perfect movies and series for you';

  @override
  String get aiErrorTitle => 'Something went wrong';

  @override
  String get aiErrorMessage => 'We couldn\'t process your request. Please try again.';

  @override
  String get aiRetry => 'Retry';

  @override
  String get aiQuickDecision => 'Quick Decision';

  @override
  String get aiQuickDecisionSubtitle => 'Swipe to train your preferences';

  @override
  String get aiQuickDecisionComplete => 'Done!';

  @override
  String get aiQuickDecisionCompleteSubtitle => 'You\'ve completed all quick decisions';

  @override
  String get aiIntelligence => 'KINEON INTELLIGENCE';

  @override
  String get aiWelcomeMessage => 'Tell me what you want to watch today. I can recommend movies or series based on your mood, favorite genre, or something similar to what you already liked.';

  @override
  String get aiAddedToList => 'Added to your list';

  @override
  String get aiErrorRetry => 'Sorry, there was a problem processing your message. Shall we try again?';

  @override
  String get aiQuickReplyRelax => 'Something to relax';

  @override
  String get aiQuickReplySciFi => 'Sci-fi mind-bending';

  @override
  String get aiQuickReplyCouple => 'For a date night';

  @override
  String get aiQuickReplySurprise => 'Surprise me';

  @override
  String get aiQuickReplyRetry => 'Retry';

  @override
  String get aiQuickReplyPopular => 'Something popular';

  @override
  String get aiListening => 'Listening...';

  @override
  String get aiSpeechNotAvailable => 'Voice recognition not available';

  // ═══════════════════════════════════════════════════════════════════════════
  // LIBRARY SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get libraryTitle => 'My Library';

  @override
  String get librarySearchHint => 'Search your library...';

  @override
  String get libraryCancel => 'Cancel';

  @override
  String get libraryViewingHeatmap => 'Viewing Heatmap';

  @override
  String get libraryActiveActivity => 'Active Activity';

  @override
  String get libraryLast6Months => 'Last 6 Months';

  @override
  String get libraryLess => 'Less';

  @override
  String get libraryMore => 'More';

  @override
  String get libraryWatchlist => 'Watchlist';

  @override
  String get libraryFavorites => 'Favorites';

  @override
  String get libraryWatched => 'Watched';

  @override
  String get libraryMyLists => 'My Lists';

  @override
  String get libraryCreateList => 'Create List';

  @override
  String get libraryChooseIcon => 'Choose an icon';

  @override
  String get libraryListName => 'List name';

  @override
  String get libraryListNameHint => 'E.g.: Horror movies';

  @override
  String get libraryCreate => 'Create';

  @override
  String get libraryCreateNewList => 'Create new list';

  @override
  String get libraryEmptyWatchlistTitle => 'No watchlist yet';

  @override
  String get libraryEmptyWatchlistSubtitle => 'Our AI will help you find the perfect movies for you';

  @override
  String get libraryEmptyFavoritesTitle => 'No favorites yet';

  @override
  String get libraryEmptyFavoritesSubtitle => 'Mark your favorite movies to find them easily';

  @override
  String get libraryEmptyWatchedTitle => 'Nothing watched yet';

  @override
  String get libraryEmptyWatchedSubtitle => 'Keep track of everything you watch';

  @override
  String get libraryEmptyListsTitle => 'No custom lists';

  @override
  String get libraryEmptyListsSubtitle => 'Create lists to organize your favorite content';

  @override
  String get libraryExplore => 'Explore';

  @override
  String get librarySaveFirstMovie => 'Save my first movie';

  @override
  String get libraryDiscover => 'Discover';

  @override
  String get libraryStartWatching => 'Start watching';

  @override
  String get libraryCreateFirst => 'Create my first list';

  @override
  String get libraryNoResults => 'No results';

  @override
  String get libraryNoResultsFor => 'We found nothing for';

  @override
  String get libraryRenameList => 'Rename list';

  @override
  String get libraryDeleteList => 'Delete list';

  @override
  String libraryDeleteListConfirm(String listName) =>
      'Are you sure you want to delete "$listName"? This action cannot be undone.';

  @override
  String get libraryNewList => 'New list';

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST DETAIL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get listDetailEmpty => 'Empty list';

  @override
  String get listDetailEmptySubtitle => 'Add movies or TV shows from their details';

  @override
  String get listDetailExplore => 'Explore';

  @override
  String get listDetailViewDetails => 'View details';

  @override
  String get listDetailRemoveFromList => 'Remove from list';

  @override
  String get listDetailErrorLoading => 'Error loading list';

  @override
  String get listDetailNoTitle => 'No title';

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST LIMITS (Free vs Pro)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get listLimitMaxListsTitle => 'List limit reached';

  @override
  String listLimitMaxListsDesc(int limit) =>
      'With the free version you can create up to $limit list. Go Pro to create unlimited lists.';

  @override
  String get listLimitMaxItemsTitle => 'List is full';

  @override
  String listLimitMaxItemsDesc(int limit) =>
      'With the free version you can add up to $limit items per list. Go Pro to add unlimited.';

  @override
  String get listLimitProBenefit => 'Pro: Unlimited lists and items';

  @override
  String get listLimitUpgrade => 'Go Pro';

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOBAL STATES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get stateEmptySearchTitle => 'No results';
  @override
  String get stateEmptySearchSubtitle => 'Try a different search';
  @override
  String get stateEmptySearchAction => 'Clear filters';
  @override
  String get stateEmptyWatchlistTitle => 'Empty watchlist';
  @override
  String get stateEmptyWatchlistSubtitle => 'Save what you want to watch later';
  @override
  String get stateEmptyWatchlistAction => 'Explore';
  @override
  String get stateEmptyFavoritesTitle => 'No favorites';
  @override
  String get stateEmptyFavoritesSubtitle => 'Mark your favorite movies';
  @override
  String get stateEmptyFavoritesAction => 'Discover';
  @override
  String get stateEmptyWatchedTitle => 'Nothing watched yet';
  @override
  String get stateEmptyWatchedSubtitle => 'Your history will appear here';
  @override
  String get stateEmptyWatchedAction => 'Watch now';
  @override
  String get stateEmptyListsTitle => 'No lists';
  @override
  String get stateEmptyListsSubtitle => 'Organize your favorite content';
  @override
  String get stateEmptyListsAction => 'Create list';
  @override
  String get stateEmptyNotificationsTitle => 'No notifications';
  @override
  String get stateEmptyNotificationsSubtitle => 'All caught up here';
  @override
  String get stateEmptyDownloadsTitle => 'No downloads';
  @override
  String get stateEmptyDownloadsSubtitle => 'Download to watch offline';
  @override
  String get stateEmptyDownloadsAction => 'Explore';
  @override
  String get stateEmptyHistoryTitle => 'No history';
  @override
  String get stateEmptyHistorySubtitle => 'Your recent activity will appear here';
  @override
  String get stateEmptyGenericTitle => 'Nothing here';
  @override
  String get stateEmptyGenericSubtitle => 'This space is empty';
  @override
  String get stateErrorNetworkTitle => 'No connection';
  @override
  String get stateErrorNetworkMessage => 'Check your internet connection';
  @override
  String get stateErrorServerTitle => 'Server error';
  @override
  String get stateErrorServerMessage => 'We\'re working on it';
  @override
  String get stateErrorNotFoundTitle => 'Not found';
  @override
  String get stateErrorNotFoundMessage => 'Content doesn\'t exist or was deleted';
  @override
  String get stateErrorUnauthorizedTitle => 'Session expired';
  @override
  String get stateErrorUnauthorizedMessage => 'Please log in again';
  @override
  String get stateErrorTimeoutTitle => 'Timed out';
  @override
  String get stateErrorTimeoutMessage => 'Request took too long';
  @override
  String get stateErrorMaintenanceTitle => 'Under maintenance';
  @override
  String get stateErrorMaintenanceMessage => 'We\'ll be back soon, promise';
  @override
  String get stateErrorGenericTitle => 'Something went wrong';
  @override
  String get stateErrorGenericMessage => 'Please try again';
  @override
  String get stateActionRetry => 'Retry';
  @override
  String get stateActionBack => 'Go back';
  @override
  String get stateActionLogin => 'Log in';
  @override
  String get stateActionRefresh => 'Refresh';
  @override
  String get stateActionExplore => 'Explore';
  @override
  String get stateActionDiscover => 'Discover';
  @override
  String get stateActionCreate => 'Create';
  @override
  String get stateActionWatch => 'Watch now';
  @override
  String get stateActionClearFilters => 'Clear filters';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileMemberSince => 'Member since';

  @override
  String get profileProSubtitle => 'Unlock the full potential of Kineon';

  @override
  String get profileMonthly => 'Monthly';

  @override
  String get profileAnnual => 'Annual';

  @override
  String get profilePerMonth => '/mo';

  @override
  String get profileUpgradeFor => 'Upgrade for';

  @override
  String get profileManageSubscription => 'Manage subscription';

  @override
  String get profileProActive => 'Kineon Pro Active';

  @override
  String get profileRenews => 'Renews on';

  @override
  String get profileManage => 'Manage';

  @override
  String get profileAppPreferences => 'App Preferences';

  @override
  String get profileHideSpoilers => 'Hide spoilers';

  @override
  String get profileStreamingRegion => 'Streaming region';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSelectRegion => 'Select region';

  @override
  String get profileDarkMode => 'Dark mode';

  @override
  String get profileLightMode => 'Light mode';

  @override
  String get profileSystemMode => 'System';

  @override
  String get profileDataProvidedBy => 'Data provided by';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsOfService => 'Terms of Service';

  @override
  String get profileMadeWith => 'Made with';

  @override
  String get profileForCinephiles => 'for cinephiles';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteAccountWarning => 'This action is irreversible. All your data, lists, preferences and history will be deleted.';

  @override
  String get profileDeleteAccountError => 'Could not delete account. Please try again later.';

  @override
  String get profileKineonPro => 'Kineon Pro';

  @override
  String get profileFeatureUnlimitedAI => 'Unlimited AI Recommendations';

  @override
  String get profileFeatureUnlimitedChat => 'Unlimited AI Chat';

  @override
  String get profileFeatureOfflineSync => 'Offline Collection Sync';

  @override
  String get profileFeatureEarlyAccess => 'Early Access to New Features';

  @override
  String get profileFeatureUnlimitedLists => 'Unlimited Custom Lists';

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYWALL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get paywallTitle => 'You\'ve reached your daily limit';

  @override
  String paywallDescription(int limit, String feature) =>
      'Your free plan includes $limit daily uses of $feature. Upgrade to Pro for unlimited AI.';

  @override
  String get paywallUpgrade => 'Upgrade to Pro';

  @override
  String get paywallComeback => 'Come back tomorrow';

  @override
  String get paywallResetTime => 'Your limit resets at midnight';

  @override
  String get paywallProIncludes => 'Includes:';

  @override
  String get paywallFeatureChat => 'Unlimited AI Chat';

  @override
  String get paywallFeatureSearch => 'Unlimited Smart Search';

  @override
  String get paywallFeatureRecommendations => 'Unlimited AI Recommendations';

  @override
  String get paywallFeatureLists => 'Unlimited Custom Lists';

  @override
  String get paywallFeatureEarlyAccess => 'Early Access to New Features';

  @override
  String get paywallFeatureAIChat => 'AI Chat';

  @override
  String get paywallFeatureAISearch => 'AI Search';

  @override
  String get paywallFeatureAIInsight => 'AI Insights';

  @override
  String get paywallFeatureAIPicks => 'AI Recommendations';

  // ═══════════════════════════════════════════════════════════════════════════
  // PREFERENCES SELECTOR (ONBOARDING)
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get prefsTellUs => 'Tell us';

  @override
  String get prefsYourPreferences => 'your preferences.';

  @override
  String get prefsSelectDescription => 'Select what you like to personalize your recommendations.';

  @override
  String get prefsFavoriteGenres => 'FAVORITE GENRES';

  @override
  String get prefsMoodQuestion => 'WHAT MOOD DEFINES YOU?';

  @override
  String get prefsMoodHint => 'Describe your preferred mood...';

  @override
  String get prefsSaving => 'Saving...';

  // Genre names
  @override
  String get genreAction => 'Action';

  @override
  String get genreComedy => 'Comedy';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreSciFi => 'Sci-Fi';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreAnimation => 'Animation';

  @override
  String get genreDocumentary => 'Documentary';

  @override
  String get genreFantasy => 'Fantasy';

  // ═══════════════════════════════════════════════════════════════════════════
  // AI PICKS PERSONALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get aiPicksBasedOnPreferences => 'Based on your tastes and mood';

  @override
  String get aiPicksBasedOnHistory => 'Based on your history';

  @override
  String get aiPicksTrending => 'Trending now';

  @override
  String get aiPicksColdStart => 'Top picks to get started';

  @override
  String get aiPicksRefresh => 'Refresh';

  @override
  String get aiPicksRefine => 'Refine';

  @override
  String get aiPicksPersonalize => 'Personalize';

  // Quick Preferences Bottom Sheet
  @override
  String get quickPrefsTitle => 'Adjust your preferences';

  @override
  String get quickPrefsSubtitle => 'Personalize your recommendations';

  @override
  String get quickPrefsMoodLabel => 'Your current mood';

  @override
  String get quickPrefsMoodHint => 'E.g.: Something light to relax...';

  @override
  String get quickPrefsGenresLabel => 'Favorite genres';

  @override
  String get quickPrefsSave => 'Save';

  @override
  String get quickPrefsCancel => 'Cancel';

  // ═══════════════════════════════════════════════════════════════════════════
  // WATCH PROVIDERS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get whereToWatch => 'Where to watch';

  @override
  String get watchProviderStreaming => 'Streaming';

  @override
  String get watchProviderRent => 'Rent';

  @override
  String get watchProviderBuy => 'Buy';

  @override
  String get watchProviderPoweredBy => 'Data from JustWatch';

  @override
  String get watchProviderNotAvailable => 'Not available in your country';

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL FALLBACKS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  String get noTitle => 'No title';
}
