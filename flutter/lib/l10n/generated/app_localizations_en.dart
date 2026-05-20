// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pocket Tarot';

  @override
  String get navHome => 'Daily';

  @override
  String get navDivination => 'Reading';

  @override
  String get navLibrary => 'Library';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeTitle => 'Daily Guidance';

  @override
  String get dailyReadingPanelTitle => 'Card Meaning';

  @override
  String get dailyEmptyTitle => 'Today\'s card is still in the deck';

  @override
  String get dailyEmptyMessage =>
      'Weather, time, and your current state can be included in the reading. The result is kept for today only.';

  @override
  String get dailyDrawButton => 'Draw today\'s card';

  @override
  String get dailyLoadFailed => 'Daily reading failed to load';

  @override
  String get retryLoad => 'Reload';
}
