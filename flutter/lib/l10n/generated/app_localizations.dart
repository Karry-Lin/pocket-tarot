import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Pocket Tarot'**
  String get appTitle;

  /// No description provided for @startupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Startup check failed'**
  String get startupFailedTitle;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @startupCheckingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking startup'**
  String get startupCheckingTitle;

  /// No description provided for @startupCheckingMessage.
  ///
  /// In en, this message translates to:
  /// **'Checking connection and account status'**
  String get startupCheckingMessage;

  /// No description provided for @networkBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect'**
  String get networkBlockedTitle;

  /// No description provided for @networkBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your network and try again'**
  String get networkBlockedMessage;

  /// No description provided for @retryCheck.
  ///
  /// In en, this message translates to:
  /// **'Recheck'**
  String get retryCheck;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'A daily card and a deep three-card reading, held in your hand.'**
  String get loginTagline;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @googleLogin.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in'**
  String get googleLogin;

  /// No description provided for @playGamesLogin.
  ///
  /// In en, this message translates to:
  /// **'Play Games sign-in'**
  String get playGamesLogin;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginAction;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerAction;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetSent;

  /// No description provided for @formFailure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get formFailure;

  /// No description provided for @emailCredentialFailure.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get emailCredentialFailure;

  /// No description provided for @googleFailure.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again later.'**
  String get googleFailure;

  /// No description provided for @playGamesFailure.
  ///
  /// In en, this message translates to:
  /// **'Play Games sign-in failed. Please try again later.'**
  String get playGamesFailure;

  /// No description provided for @emailLogin.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in'**
  String get emailLogin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @sendPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get sendPasswordReset;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Email'**
  String get emailInvalid;

  /// No description provided for @passwordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordInvalid;

  /// No description provided for @displayNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Display name must be 1-16 characters'**
  String get displayNameInvalid;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Confirm password must match password'**
  String get confirmPasswordMismatch;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'The verification email has been sent. Return to the app after verifying to continue creating your profile.'**
  String get verifyEmailMessage;

  /// No description provided for @verifyEmailAction.
  ///
  /// In en, this message translates to:
  /// **'I have verified'**
  String get verifyEmailAction;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for activation'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created. Full access is available after admin activation.'**
  String get pendingMessage;

  /// No description provided for @accountDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeletedTitle;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled and cannot continue. Contact operations if you have questions.'**
  String get accountDeletedMessage;

  /// No description provided for @accountDeletedAction.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get accountDeletedAction;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get navHome;

  /// No description provided for @navDivination.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get navDivination;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Guidance'**
  String get homeTitle;

  /// No description provided for @dailyReadingPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Meaning'**
  String get dailyReadingPanelTitle;

  /// No description provided for @dailyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s card is still in the deck'**
  String get dailyEmptyTitle;

  /// No description provided for @dailyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Weather, time, and your current state can be included in the reading. The result is kept for today only.'**
  String get dailyEmptyMessage;

  /// No description provided for @dailyDrawButton.
  ///
  /// In en, this message translates to:
  /// **'Draw today\'s card'**
  String get dailyDrawButton;

  /// No description provided for @dailyLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading in progress'**
  String get dailyLoadingTitle;

  /// No description provided for @dailyLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Drawing today\'s card and preparing your spiritual weather.'**
  String get dailyLoadingMessage;

  /// No description provided for @dailyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Daily reading failed to load'**
  String get dailyLoadFailed;

  /// No description provided for @retryLoad.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get retryLoad;

  /// No description provided for @divinationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Room'**
  String get divinationTitle;

  /// No description provided for @divinationLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Reading room failed to load'**
  String get divinationLoadFailed;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @promptWork.
  ///
  /// In en, this message translates to:
  /// **'Work direction'**
  String get promptWork;

  /// No description provided for @promptLove.
  ///
  /// In en, this message translates to:
  /// **'Relationship status'**
  String get promptLove;

  /// No description provided for @promptNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next choice'**
  String get promptNextStep;

  /// No description provided for @startDraft.
  ///
  /// In en, this message translates to:
  /// **'Reveal 9 cards'**
  String get startDraft;

  /// No description provided for @createReading.
  ///
  /// In en, this message translates to:
  /// **'Generate reading'**
  String get createReading;

  /// No description provided for @readingCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Reading failed'**
  String get readingCreateFailed;

  /// No description provided for @drawPreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing the spread'**
  String get drawPreparingTitle;

  /// No description provided for @drawPreparingMessage.
  ///
  /// In en, this message translates to:
  /// **'Shuffling the deck and arranging nine cards.'**
  String get drawPreparingMessage;

  /// No description provided for @drawTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose three meaningful cards.'**
  String get drawTitle;

  /// No description provided for @drawSelectedStatus.
  ///
  /// In en, this message translates to:
  /// **'{selectedCount} / 3 selected. Cards flip when picked, and the selection cannot be changed.'**
  String drawSelectedStatus(int selectedCount);

  /// No description provided for @drawReadButton.
  ///
  /// In en, this message translates to:
  /// **'View reading'**
  String get drawReadButton;

  /// No description provided for @deepLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading in progress'**
  String get deepLoadingTitle;

  /// No description provided for @deepLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Reading your three selected cards and preparing a record you can save.'**
  String get deepLoadingMessage;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Reading Result'**
  String get resultTitle;

  /// No description provided for @resultQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'About this question'**
  String get resultQuestionTitle;

  /// No description provided for @resultCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Three-card message'**
  String get resultCardsTitle;

  /// No description provided for @resultNoQuestion.
  ///
  /// In en, this message translates to:
  /// **'This reading was saved without a written question.'**
  String get resultNoQuestion;

  /// No description provided for @resultBackToReading.
  ///
  /// In en, this message translates to:
  /// **'Back to Reading'**
  String get resultBackToReading;

  /// No description provided for @resultSave.
  ///
  /// In en, this message translates to:
  /// **'Save record'**
  String get resultSave;

  /// No description provided for @resultSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get resultSaving;

  /// No description provided for @resultClear.
  ///
  /// In en, this message translates to:
  /// **'Clear record'**
  String get resultClear;

  /// No description provided for @resultClearing.
  ///
  /// In en, this message translates to:
  /// **'Clearing'**
  String get resultClearing;

  /// No description provided for @resultSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get resultSaved;

  /// No description provided for @fallbackResultQuestion.
  ///
  /// In en, this message translates to:
  /// **'You are not only asking whether to move forward, but whether you can care for yourself inside uncertainty. The Moon brings emotion to the surface, Temperance asks you to slow the pace, and The Star points toward a gentler but clearer path.'**
  String get fallbackResultQuestion;

  /// No description provided for @fallbackResultBulletMoon.
  ///
  /// In en, this message translates to:
  /// **'The Moon: The current uncertainty is not a mistake. It is showing you that some information has not been spoken yet.'**
  String get fallbackResultBulletMoon;

  /// No description provided for @fallbackResultBulletTemperance.
  ///
  /// In en, this message translates to:
  /// **'Temperance: Do not try to solve everything in one conversation. Confirm boundaries first, then expectations.'**
  String get fallbackResultBulletTemperance;

  /// No description provided for @fallbackResultBulletStar.
  ///
  /// In en, this message translates to:
  /// **'The Star: An answer worth approaching will make you feel more whole, not more constrained.'**
  String get fallbackResultBulletStar;

  /// No description provided for @fallbackResultAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Tonight\'s advice'**
  String get fallbackResultAdviceTitle;

  /// No description provided for @fallbackResultAdvice.
  ///
  /// In en, this message translates to:
  /// **'Turn the question into one practical sentence: tomorrow I can ask one more question instead of making one immediate decision.'**
  String get fallbackResultAdvice;

  /// No description provided for @deepSelectExactlyThreeCards.
  ///
  /// In en, this message translates to:
  /// **'Select exactly 3 cards'**
  String get deepSelectExactlyThreeCards;

  /// No description provided for @deepNoSavableResult.
  ///
  /// In en, this message translates to:
  /// **'No reading result to save'**
  String get deepNoSavableResult;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Tarot Library'**
  String get libraryTitle;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Card library failed to load'**
  String get libraryLoadFailed;

  /// No description provided for @searchCardsLabel.
  ///
  /// In en, this message translates to:
  /// **'Search card name or keyword'**
  String get searchCardsLabel;

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} cards'**
  String cardsCount(int count);

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryMajor.
  ///
  /// In en, this message translates to:
  /// **'Major Arcana'**
  String get categoryMajor;

  /// No description provided for @categoryWands.
  ///
  /// In en, this message translates to:
  /// **'Wands'**
  String get categoryWands;

  /// No description provided for @categoryCups.
  ///
  /// In en, this message translates to:
  /// **'Cups'**
  String get categoryCups;

  /// No description provided for @categorySwords.
  ///
  /// In en, this message translates to:
  /// **'Swords'**
  String get categorySwords;

  /// No description provided for @categoryPentacles.
  ///
  /// In en, this message translates to:
  /// **'Pentacles'**
  String get categoryPentacles;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile failed to load'**
  String get profileLoadFailed;

  /// No description provided for @profileLoadFallback.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get profileLoadFallback;

  /// No description provided for @profileStats.
  ///
  /// In en, this message translates to:
  /// **'Daily readings {dailyCount} · deep readings {deepCount}'**
  String profileStats(int dailyCount, int deepCount);

  /// No description provided for @localeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get localeSystem;

  /// No description provided for @localeZh.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get localeZh;

  /// No description provided for @localeEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEn;

  /// No description provided for @weatherToggle.
  ///
  /// In en, this message translates to:
  /// **'Use weather for daily reading'**
  String get weatherToggle;

  /// No description provided for @editDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get editDisplayName;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deepResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Reading'**
  String get deepResultTitle;

  /// No description provided for @saveToHistory.
  ///
  /// In en, this message translates to:
  /// **'Save to history'**
  String get saveToHistory;

  /// No description provided for @selectedCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected three cards'**
  String get selectedCardsTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @loadHistory.
  ///
  /// In en, this message translates to:
  /// **'Load history'**
  String get loadHistory;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved readings yet'**
  String get emptyHistory;

  /// No description provided for @unnamedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Untitled question'**
  String get unnamedQuestion;

  /// No description provided for @upright.
  ///
  /// In en, this message translates to:
  /// **'Upright'**
  String get upright;

  /// No description provided for @reversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get reversed;

  /// No description provided for @cardMeaningText.
  ///
  /// In en, this message translates to:
  /// **'Upright: {uprightMeaning}\nReversed: {reversedMeaning}'**
  String cardMeaningText(String uprightMeaning, String reversedMeaning);

  /// No description provided for @editNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get editNameTitle;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get nicknameLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
