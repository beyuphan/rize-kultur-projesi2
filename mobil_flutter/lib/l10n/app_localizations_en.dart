// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Rize Culture Project';

  @override
  String get welcome => 'Welcome to Rize!';

  @override
  String get explore => 'Explore';

  @override
  String get map => 'Map';

  @override
  String get routes => 'Routes';

  @override
  String get settings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appTheme => 'App Theme';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get selectThemeTitle => 'Select App Theme';

  @override
  String get selectLanguageTitle => 'Select App Language';

  @override
  String get themeFirtinaYesili => 'Fırtına Green';

  @override
  String get themeKackarSisi => 'Kaçkar Mist';

  @override
  String get searchHint => 'Search plateaus, waterfalls and more...';

  @override
  String get categories => 'Categories';

  @override
  String get popularVenues => 'Popular Venues';

  @override
  String get seeAll => 'See All';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryPlateaus => 'Plateaus';

  @override
  String get categoryWaterfalls => 'Waterfalls';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryHistorical => 'Historical';

  @override
  String get categoryNature => 'Nature';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get yourRating => 'Your Rating';

  @override
  String get photos => 'Photos';

  @override
  String get addComment => 'Add Comment';

  @override
  String get reviews => 'Reviews';

  @override
  String reviewsCount(String count) {
    return '($count Reviews)';
  }
}
