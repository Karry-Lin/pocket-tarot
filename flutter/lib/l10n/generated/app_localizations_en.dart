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
  String get startupFailedTitle => 'Startup check failed';

  @override
  String get tryAgainLater => 'Please try again later';

  @override
  String get startupCheckingTitle => 'Checking startup';

  @override
  String get startupCheckingMessage => 'Checking connection and account status';

  @override
  String get networkBlockedTitle => 'Unable to connect';

  @override
  String get networkBlockedMessage => 'Check your network and try again';

  @override
  String get retryCheck => 'Recheck';

  @override
  String get loginTagline =>
      'A daily card and a deep three-card reading, held in your hand.';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get googleLogin => 'Google sign-in';

  @override
  String get playGamesLogin => 'Play Games sign-in';

  @override
  String get loginAction => 'Sign in';

  @override
  String get registerAction => 'Register';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get passwordResetSent => 'Password reset email sent';

  @override
  String get formFailure => 'Something went wrong. Please try again later.';

  @override
  String get emailCredentialFailure => 'Email or password is incorrect';

  @override
  String get googleFailure => 'Google sign-in failed. Please try again later.';

  @override
  String get playGamesFailure =>
      'Play Games sign-in failed. Please try again later.';

  @override
  String get emailLogin => 'Email sign-in';

  @override
  String get createAccount => 'Create account';

  @override
  String get sendPasswordReset => 'Send reset email';

  @override
  String get emailInvalid => 'Enter a valid Email';

  @override
  String get passwordInvalid => 'Password must be at least 6 characters';

  @override
  String get displayNameInvalid => 'Display name must be 1-16 characters';

  @override
  String get confirmPasswordMismatch => 'Confirm password must match password';

  @override
  String get verifyEmailTitle => 'Verify Email';

  @override
  String get verifyEmailMessage =>
      'The verification email has been sent. Return to the app after verifying to continue creating your profile.';

  @override
  String get verifyEmailAction => 'I have verified';

  @override
  String get pendingTitle => 'Waiting for activation';

  @override
  String get pendingMessage =>
      'Your account has been created. Full access is available after admin activation.';

  @override
  String get accountDeletedTitle => 'Account deleted';

  @override
  String get accountDeletedMessage =>
      'This account is disabled and cannot continue. Contact operations if you have questions.';

  @override
  String get accountDeletedAction => 'Back to login';

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
  String get dailyLoadingTitle => 'Reading in progress';

  @override
  String get dailyLoadingMessage =>
      'Drawing today\'s card and preparing your spiritual weather.';

  @override
  String get dailyLoadFailed => 'Daily reading failed to load';

  @override
  String get retryLoad => 'Reload';

  @override
  String get divinationTitle => 'Reading Room';

  @override
  String get divinationLoadFailed => 'Reading room failed to load';

  @override
  String get questionLabel => 'Question';

  @override
  String get promptWork => 'Work direction';

  @override
  String get promptLove => 'Relationship status';

  @override
  String get promptNextStep => 'Next choice';

  @override
  String get startDraft => 'Reveal 9 cards';

  @override
  String get createReading => 'Generate reading';

  @override
  String get readingCreateFailed => 'Reading failed';

  @override
  String get drawPreparingTitle => 'Preparing the spread';

  @override
  String get drawPreparingMessage =>
      'Shuffling the deck and arranging nine cards.';

  @override
  String get drawTitle => 'Choose three meaningful cards.';

  @override
  String drawSelectedStatus(int selectedCount) {
    return '$selectedCount / 3 selected. Cards flip when picked, and the selection cannot be changed.';
  }

  @override
  String get drawReadButton => 'View reading';

  @override
  String get deepLoadingTitle => 'Reading in progress';

  @override
  String get deepLoadingMessage =>
      'Reading your three selected cards and preparing a record you can save.';

  @override
  String get resultTitle => 'Deep Reading Result';

  @override
  String get resultQuestionTitle => 'About this question';

  @override
  String get resultCardsTitle => 'Three-card message';

  @override
  String get resultNoQuestion =>
      'This reading was saved without a written question.';

  @override
  String get resultBackToReading => 'Back to Reading';

  @override
  String get resultSave => 'Save record';

  @override
  String get resultSaving => 'Saving';

  @override
  String get resultSaved => 'Saved';

  @override
  String get fallbackResultQuestion =>
      'You are not only asking whether to move forward, but whether you can care for yourself inside uncertainty. The Moon brings emotion to the surface, Temperance asks you to slow the pace, and The Star points toward a gentler but clearer path.';

  @override
  String get fallbackResultBulletMoon =>
      'The Moon: The current uncertainty is not a mistake. It is showing you that some information has not been spoken yet.';

  @override
  String get fallbackResultBulletTemperance =>
      'Temperance: Do not try to solve everything in one conversation. Confirm boundaries first, then expectations.';

  @override
  String get fallbackResultBulletStar =>
      'The Star: An answer worth approaching will make you feel more whole, not more constrained.';

  @override
  String get fallbackResultAdviceTitle => 'Tonight\'s advice';

  @override
  String get fallbackResultAdvice =>
      'Turn the question into one practical sentence: tomorrow I can ask one more question instead of making one immediate decision.';

  @override
  String get deepSelectExactlyThreeCards => 'Select exactly 3 cards';

  @override
  String get deepNoSavableResult => 'No reading result to save';

  @override
  String get libraryTitle => 'Tarot Library';

  @override
  String get libraryLoadFailed => 'Card library failed to load';

  @override
  String get searchCardsLabel => 'Search card name or keyword';

  @override
  String cardsCount(int count) {
    return 'Showing $count cards';
  }

  @override
  String get categoryAll => 'All';

  @override
  String get categoryMajor => 'Major Arcana';

  @override
  String get categoryWands => 'Wands';

  @override
  String get categoryCups => 'Cups';

  @override
  String get categorySwords => 'Swords';

  @override
  String get categoryPentacles => 'Pentacles';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoadFailed => 'Profile failed to load';

  @override
  String get profileLoadFallback => 'Unable to load profile';

  @override
  String profileStats(int dailyCount, int deepCount) {
    return 'Daily readings $dailyCount · deep readings $deepCount';
  }

  @override
  String get localeSystem => 'System';

  @override
  String get localeZh => 'Traditional Chinese';

  @override
  String get localeEn => 'English';

  @override
  String get weatherToggle => 'Use weather for daily reading';

  @override
  String get editDisplayName => 'Edit display name';

  @override
  String get signOut => 'Sign out';

  @override
  String get deepResultTitle => 'Deep Reading';

  @override
  String get saveToHistory => 'Save to history';

  @override
  String get selectedCardsTitle => 'Selected three cards';

  @override
  String get historyTitle => 'History';

  @override
  String get loadHistory => 'Load history';

  @override
  String get emptyHistory => 'No saved readings yet';

  @override
  String get unnamedQuestion => 'Untitled question';

  @override
  String get upright => 'Upright';

  @override
  String get reversed => 'Reversed';

  @override
  String cardMeaningText(String uprightMeaning, String reversedMeaning) {
    return 'Upright: $uprightMeaning\nReversed: $reversedMeaning';
  }

  @override
  String get editNameTitle => 'Edit display name';

  @override
  String get nicknameLabel => 'Display name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';
}
