import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Rize Culture Project'**
  String get title;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rize!'**
  String get welcome;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @selectThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select App Theme'**
  String get selectThemeTitle;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get selectLanguageTitle;

  /// No description provided for @themeFirtinaYesili.
  ///
  /// In en, this message translates to:
  /// **'Fırtına Green'**
  String get themeFirtinaYesili;

  /// No description provided for @themeKackarSisi.
  ///
  /// In en, this message translates to:
  /// **'Kaçkar Mist'**
  String get themeKackarSisi;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plateaus, waterfalls and more...'**
  String get searchHint;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @popularVenues.
  ///
  /// In en, this message translates to:
  /// **'Popular Venues'**
  String get popularVenues;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryPlateaus.
  ///
  /// In en, this message translates to:
  /// **'Plateaus'**
  String get categoryPlateaus;

  /// No description provided for @categoryWaterfalls.
  ///
  /// In en, this message translates to:
  /// **'Waterfalls'**
  String get categoryWaterfalls;

  /// No description provided for @categoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurants;

  /// No description provided for @categoryHistorical.
  ///
  /// In en, this message translates to:
  /// **'Historical'**
  String get categoryHistorical;

  /// No description provided for @categoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favoriler'**
  String get favorites;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated Successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Username can not be empty'**
  String get usernameCannotBeEmpty;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @enterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid e-mail'**
  String get enterAValidEmail;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login...'**
  String get loginSubtitle;

  /// No description provided for @emailValidation.
  ///
  /// In en, this message translates to:
  /// **'E-Mail Validation'**
  String get emailValidation;

  /// No description provided for @passwordValidation.
  ///
  /// In en, this message translates to:
  /// **'Password Validation'**
  String get passwordValidation;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Dont Have Account?'**
  String get dontHaveAccount;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register...'**
  String get registerSubtitle;

  /// No description provided for @usernameValidation.
  ///
  /// In en, this message translates to:
  /// **'Username Validation'**
  String get usernameValidation;

  /// No description provided for @passwordLengthValidation.
  ///
  /// In en, this message translates to:
  /// **'Password Length Validation'**
  String get passwordLengthValidation;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already Have Account?'**
  String get alreadyHaveAccount;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @guestProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Discover'**
  String get guestProfileTitle;

  /// No description provided for @guestPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover All Feature'**
  String get guestPromptTitle;

  /// No description provided for @guestPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to add places to your favorites, leave reviews and ratings.'**
  String get guestPromptSubtitle;

  /// The number of reviews for a place
  ///
  /// In en, this message translates to:
  /// **'({count} Reviews)'**
  String reviewsCount(String count);

  /// No description provided for @settingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get settingsProfileTitle;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and edit your account information'**
  String get settingsProfileSubtitle;

  /// No description provided for @bottomNavExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get bottomNavExplore;

  /// No description provided for @bottomNavMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get bottomNavMap;

  /// No description provided for @bottomNavRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get bottomNavRoutes;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get bottomNavProfile;

  /// No description provided for @noVenuesFound.
  ///
  /// In en, this message translates to:
  /// **'No Venues Found'**
  String get noVenuesFound;

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your Comment'**
  String get yourComment;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No Comments Yet'**
  String get noCommentsYet;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'search Results'**
  String get searchResults;

  /// No description provided for @tagCarAccess.
  ///
  /// In en, this message translates to:
  /// **'Car Access'**
  String get tagCarAccess;

  /// No description provided for @tagWinterFriendly.
  ///
  /// In en, this message translates to:
  /// **'Winter Friendly'**
  String get tagWinterFriendly;

  /// No description provided for @tagEntryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry Fee'**
  String get tagEntryFee;

  /// No description provided for @tagHikingTrail.
  ///
  /// In en, this message translates to:
  /// **'Hiking Trail'**
  String get tagHikingTrail;

  /// No description provided for @discoverRoutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Routes to Discover'**
  String get discoverRoutesTitle;

  /// No description provided for @routeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Detail'**
  String get routeDetailTitle;

  /// No description provided for @routeLoadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading routes.'**
  String get routeLoadingError;

  /// No description provided for @routesNotFound.
  ///
  /// In en, this message translates to:
  /// **'No routes found.'**
  String get routesNotFound;

  /// No description provided for @firtinaVadisiName.
  ///
  /// In en, this message translates to:
  /// **'Fırtına Valley Adventure'**
  String get firtinaVadisiName;

  /// No description provided for @firtinaVadisiDescription.
  ///
  /// In en, this message translates to:
  /// **'This route along the Fırtına River offers views of historical bridges and lush green nature.'**
  String get firtinaVadisiDescription;

  /// No description provided for @firtinaVadisiDuration.
  ///
  /// In en, this message translates to:
  /// **'4-5 Hours'**
  String get firtinaVadisiDuration;

  /// No description provided for @firtinaVadisiDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get firtinaVadisiDifficulty;

  /// No description provided for @kackarlarZirveName.
  ///
  /// In en, this message translates to:
  /// **'Journey to the Peaks of Kaçkars'**
  String get kackarlarZirveName;

  /// No description provided for @kackarlarZirveDescription.
  ///
  /// In en, this message translates to:
  /// **'Starting from Ayder Plateau, this route offers breathtaking views of the Kaçkar Mountains for experienced hikers.'**
  String get kackarlarZirveDescription;

  /// No description provided for @kackarlarZirveDuration.
  ///
  /// In en, this message translates to:
  /// **'2 Days'**
  String get kackarlarZirveDuration;

  /// No description provided for @kackarlarZirveDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get kackarlarZirveDifficulty;

  /// No description provided for @cayBahceleriName.
  ///
  /// In en, this message translates to:
  /// **'Tea Gardens Tour'**
  String get cayBahceleriName;

  /// No description provided for @cayBahceleriDescription.
  ///
  /// In en, this message translates to:
  /// **'A pleasant trip among the famous tea fields of Rize. Witness the journey of tea from the field to the cup.'**
  String get cayBahceleriDescription;

  /// No description provided for @cayBahceleriDuration.
  ///
  /// In en, this message translates to:
  /// **'3 Hours'**
  String get cayBahceleriDuration;

  /// No description provided for @cayBahceleriDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get cayBahceleriDifficulty;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @routeSharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing route...'**
  String get routeSharing;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @placeCount.
  ///
  /// In en, this message translates to:
  /// **'Place Count'**
  String get placeCount;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get stops;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @places.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get places;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @startRoute.
  ///
  /// In en, this message translates to:
  /// **'Start Route'**
  String get startRoute;

  /// No description provided for @routePreparation.
  ///
  /// In en, this message translates to:
  /// **'Route Preparation'**
  String get routePreparation;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @clothingDescription.
  ///
  /// In en, this message translates to:
  /// **'Comfortable hiking clothes and waterproof jacket'**
  String get clothingDescription;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @waterDescription.
  ///
  /// In en, this message translates to:
  /// **'At least 2 liters of water per person'**
  String get waterDescription;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @foodDescription.
  ///
  /// In en, this message translates to:
  /// **'Snacks and energy bars for meals'**
  String get foodDescription;

  /// No description provided for @firstAid.
  ///
  /// In en, this message translates to:
  /// **'First Aid'**
  String get firstAid;

  /// No description provided for @firstAidDescription.
  ///
  /// In en, this message translates to:
  /// **'Basic first aid supplies'**
  String get firstAidDescription;

  /// No description provided for @safetyTips.
  ///
  /// In en, this message translates to:
  /// **'Safety Tips'**
  String get safetyTips;

  /// No description provided for @checkWeather.
  ///
  /// In en, this message translates to:
  /// **'Check the weather forecast'**
  String get checkWeather;

  /// No description provided for @travelInGroup.
  ///
  /// In en, this message translates to:
  /// **'Travel in groups'**
  String get travelInGroup;

  /// No description provided for @askLocalGuides.
  ///
  /// In en, this message translates to:
  /// **'Get information from local guides'**
  String get askLocalGuides;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Keep emergency contact information with you'**
  String get emergencyContacts;

  /// No description provided for @recommendedTime.
  ///
  /// In en, this message translates to:
  /// **'Recommended time'**
  String get recommendedTime;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on Map'**
  String get showOnMap;

  /// No description provided for @openingOnMap.
  ///
  /// In en, this message translates to:
  /// **'opening on map...'**
  String get openingOnMap;

  /// No description provided for @startRouteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start this route? GPS tracking will be enabled and you will be guided.'**
  String get startRouteConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @routeStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting route... Opening GPS.'**
  String get routeStarting;

  /// No description provided for @themeLazHoronu.
  ///
  /// In en, this message translates to:
  /// **'Laz Horon'**
  String get themeLazHoronu;

  /// No description provided for @themeZumrutYayla.
  ///
  /// In en, this message translates to:
  /// **'Emerald Plateau'**
  String get themeZumrutYayla;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
