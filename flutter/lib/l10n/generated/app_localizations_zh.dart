// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '口袋塔羅';

  @override
  String get startupFailedTitle => '啟動檢查失敗';

  @override
  String get tryAgainLater => '請稍後再試';

  @override
  String get startupCheckingTitle => '啟動檢查中';

  @override
  String get startupCheckingMessage => '正在確認連線與帳號狀態';

  @override
  String get networkBlockedTitle => '目前無法連線';

  @override
  String get networkBlockedMessage => '請檢查網路後重試';

  @override
  String get retryCheck => '重新檢查';

  @override
  String get loginTagline => '每日一張，深度三張，把今天的選擇握在手心。';

  @override
  String get displayNameLabel => '暱稱';

  @override
  String get passwordLabel => '密碼';

  @override
  String get confirmPasswordLabel => '確認密碼';

  @override
  String get googleLogin => 'Google 登入';

  @override
  String get playGamesLogin => 'Play Games 登入';

  @override
  String get loginAction => '登入';

  @override
  String get registerAction => '註冊';

  @override
  String get forgotPassword => '忘記密碼';

  @override
  String get passwordResetSent => '重設信已送出';

  @override
  String get formFailure => '操作失敗，請稍後再試';

  @override
  String get emailCredentialFailure => '帳號或密碼錯誤';

  @override
  String get emailAlreadyRegistered => '這個 Email 已註冊，請改用登入或重設密碼。';

  @override
  String get googleFailure => 'Google 登入失敗，請稍後再試';

  @override
  String get playGamesFailure => 'Play Games 登入失敗，請稍後再試';

  @override
  String get emailLogin => 'Email 登入';

  @override
  String get createAccount => '建立帳號';

  @override
  String get sendPasswordReset => '送出重設信';

  @override
  String get emailInvalid => '請輸入有效的 Email';

  @override
  String get passwordInvalid => '密碼至少需要 6 個字元';

  @override
  String get displayNameInvalid => '暱稱長度必須為 1-16 字';

  @override
  String get confirmPasswordMismatch => '確認密碼必須和密碼相同';

  @override
  String get verifyEmailTitle => '確認 Email';

  @override
  String get verifyEmailMessage => '我們已寄出驗證信。請先到信箱點擊驗證連結，再回來按下按鈕。';

  @override
  String get verifyEmailAction => '我已完成驗證';

  @override
  String get verifyEmailStillPending => 'Email 尚未完成驗證，請先到信箱點擊驗證連結後再試。';

  @override
  String get pendingTitle => '等待啟用';

  @override
  String get pendingMessage => '帳號已建立，管理員啟用後即可進入完整功能。';

  @override
  String get accountDeletedTitle => '帳號已刪除';

  @override
  String get accountDeletedMessage => '這個帳號已停用且無法繼續使用。如有疑問，請聯絡服務維運人員。';

  @override
  String get accountDeletedAction => '回到登入';

  @override
  String get navHome => '首頁';

  @override
  String get navDivination => '占卜館';

  @override
  String get navLibrary => '圖書館';

  @override
  String get navProfile => '個人';

  @override
  String get homeTitle => '今日指引';

  @override
  String get dailyReadingPanelTitle => '牌義解讀';

  @override
  String get dailyEmptyTitle => '今天的牌還在牌堆裡';

  @override
  String get dailyEmptyMessage => '天氣、時間與當下狀態會一起送進解讀，結果只保留今天這一筆。';

  @override
  String get dailyDrawButton => '抽今日牌';

  @override
  String get dailyLoadingTitle => '占卜中';

  @override
  String get dailyLoadingMessage => '正在抽取今日牌面，並整理今天的心靈天氣。';

  @override
  String get dailyLoadFailed => '今日抽牌載入失敗';

  @override
  String get retryLoad => '重新載入';

  @override
  String get divinationTitle => '占卜館';

  @override
  String get divinationLoadFailed => '占卜館載入失敗';

  @override
  String get questionLabel => '想問的問題';

  @override
  String get promptWork => '工作方向';

  @override
  String get promptLove => '感情狀態';

  @override
  String get promptNextStep => '下一步選擇';

  @override
  String get startDraft => '展開 9 張牌';

  @override
  String get createReading => '產生解讀';

  @override
  String get readingCreateFailed => '占卜產生失敗';

  @override
  String get drawPreparingTitle => '準備牌陣';

  @override
  String get drawPreparingMessage => '正在洗牌，讓九張牌依序浮現。';

  @override
  String get drawTitle => '選三張有重量的牌。';

  @override
  String drawSelectedStatus(int selectedCount) {
    return '$selectedCount / 3 已選。點選後會翻面，選定後不可更換。';
  }

  @override
  String get drawReadButton => '查看解讀';

  @override
  String get deepLoadingTitle => '占卜中';

  @override
  String get deepLoadingMessage => '正在解讀你選出的三張牌，整理成可以保存的紀錄。';

  @override
  String get resultTitle => '深度占卜結果';

  @override
  String get resultQuestionTitle => '關於這個問題';

  @override
  String get resultCardsTitle => '三張牌的訊息';

  @override
  String get resultNoQuestion => '這次占卜沒有留下問題文字。';

  @override
  String get resultBackToReading => '回到占卜館';

  @override
  String get resultSave => '保存紀錄';

  @override
  String get resultSaving => '保存中';

  @override
  String get resultClear => '清除紀錄';

  @override
  String get resultClearing => '清除中';

  @override
  String get resultSaved => '已保存';

  @override
  String get fallbackResultQuestion =>
      '你正在問的不是「該不該前進」，而是「我能否在不確定裡仍然照顧自己」。月亮讓情緒浮上來，節制要求你把步伐放慢，星星則指出仍有一條溫柔但清楚的路。';

  @override
  String get fallbackResultBulletMoon => '月亮：現在的模糊不是錯誤，它是在提醒你有些資訊還未被說出口。';

  @override
  String get fallbackResultBulletTemperance => '節制：不要用一次談話解決全部。先確認界線，再確認期待。';

  @override
  String get fallbackResultBulletStar => '星星：真正值得靠近的答案，會讓你感到更完整，而不是更緊縮。';

  @override
  String get fallbackResultAdviceTitle => '今晚的建議';

  @override
  String get fallbackResultAdvice => '把問題拆成一個可行動的小句子：我明天可以多問一個問題，而不是立刻做一個決定。';

  @override
  String get deepSelectExactlyThreeCards => '必須選擇 3 張牌';

  @override
  String get deepNoSavableResult => '沒有可保存的占卜結果';

  @override
  String get libraryTitle => '塔羅圖書館';

  @override
  String get libraryLoadFailed => '牌庫載入失敗';

  @override
  String get searchCardsLabel => '搜尋牌名或關鍵字';

  @override
  String cardsCount(int count) {
    return '顯示 $count 張牌';
  }

  @override
  String get categoryAll => '全部';

  @override
  String get categoryMajor => '大阿爾克那';

  @override
  String get categoryWands => '權杖';

  @override
  String get categoryCups => '聖杯';

  @override
  String get categorySwords => '寶劍';

  @override
  String get categoryPentacles => '錢幣';

  @override
  String get profileTitle => '個人檔案';

  @override
  String get profileLoadFailed => '個人檔案載入失敗';

  @override
  String get profileLoadFallback => '無法載入個人檔案';

  @override
  String profileStats(int dailyCount, int deepCount) {
    return '每日抽牌 $dailyCount 次 · 深度占卜 $deepCount 次';
  }

  @override
  String get localeSystem => '系統';

  @override
  String get localeZh => '繁體中文';

  @override
  String get localeEn => 'English';

  @override
  String get weatherToggle => '每日抽牌使用天氣';

  @override
  String get editDisplayName => '編輯暱稱';

  @override
  String get signOut => '登出';

  @override
  String get deepResultTitle => '深度解讀';

  @override
  String get saveToHistory => '保存到歷史紀錄';

  @override
  String get selectedCardsTitle => '抽到的三張牌';

  @override
  String get historyTitle => '歷史紀錄';

  @override
  String get loadHistory => '載入歷史';

  @override
  String get emptyHistory => '尚未保存占卜紀錄';

  @override
  String get unnamedQuestion => '未命名問題';

  @override
  String get upright => '正位';

  @override
  String get reversed => '逆位';

  @override
  String cardMeaningText(String uprightMeaning, String reversedMeaning) {
    return '正位：$uprightMeaning\n逆位：$reversedMeaning';
  }

  @override
  String get editNameTitle => '編輯暱稱';

  @override
  String get nicknameLabel => '暱稱';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '口袋塔羅';

  @override
  String get startupFailedTitle => '啟動檢查失敗';

  @override
  String get tryAgainLater => '請稍後再試';

  @override
  String get startupCheckingTitle => '啟動檢查中';

  @override
  String get startupCheckingMessage => '正在確認連線與帳號狀態';

  @override
  String get networkBlockedTitle => '目前無法連線';

  @override
  String get networkBlockedMessage => '請檢查網路後重試';

  @override
  String get retryCheck => '重新檢查';

  @override
  String get loginTagline => '每日一張，深度三張，把今天的選擇握在手心。';

  @override
  String get displayNameLabel => '暱稱';

  @override
  String get passwordLabel => '密碼';

  @override
  String get confirmPasswordLabel => '確認密碼';

  @override
  String get googleLogin => 'Google 登入';

  @override
  String get playGamesLogin => 'Play Games 登入';

  @override
  String get loginAction => '登入';

  @override
  String get registerAction => '註冊';

  @override
  String get forgotPassword => '忘記密碼';

  @override
  String get passwordResetSent => '重設信已送出';

  @override
  String get formFailure => '操作失敗，請稍後再試';

  @override
  String get emailCredentialFailure => '帳號或密碼錯誤';

  @override
  String get emailAlreadyRegistered => '這個 Email 已註冊，請改用登入或重設密碼。';

  @override
  String get googleFailure => 'Google 登入失敗，請稍後再試';

  @override
  String get playGamesFailure => 'Play Games 登入失敗，請稍後再試';

  @override
  String get emailLogin => 'Email 登入';

  @override
  String get createAccount => '建立帳號';

  @override
  String get sendPasswordReset => '送出重設信';

  @override
  String get emailInvalid => '請輸入有效的 Email';

  @override
  String get passwordInvalid => '密碼至少需要 6 個字元';

  @override
  String get displayNameInvalid => '暱稱長度必須為 1-16 字';

  @override
  String get confirmPasswordMismatch => '確認密碼必須和密碼相同';

  @override
  String get verifyEmailTitle => '確認 Email';

  @override
  String get verifyEmailMessage => '我們已寄出驗證信。請先到信箱點擊驗證連結，再回來按下按鈕。';

  @override
  String get verifyEmailAction => '我已完成驗證';

  @override
  String get verifyEmailStillPending => 'Email 尚未完成驗證，請先到信箱點擊驗證連結後再試。';

  @override
  String get pendingTitle => '等待啟用';

  @override
  String get pendingMessage => '帳號已建立，管理員啟用後即可進入完整功能。';

  @override
  String get accountDeletedTitle => '帳號已刪除';

  @override
  String get accountDeletedMessage => '這個帳號已停用且無法繼續使用。如有疑問，請聯絡服務維運人員。';

  @override
  String get accountDeletedAction => '回到登入';

  @override
  String get navHome => '首頁';

  @override
  String get navDivination => '占卜館';

  @override
  String get navLibrary => '圖書館';

  @override
  String get navProfile => '個人';

  @override
  String get homeTitle => '今日指引';

  @override
  String get dailyReadingPanelTitle => '牌義解讀';

  @override
  String get dailyEmptyTitle => '今天的牌還在牌堆裡';

  @override
  String get dailyEmptyMessage => '天氣、時間與當下狀態會一起送進解讀，結果只保留今天這一筆。';

  @override
  String get dailyDrawButton => '抽今日牌';

  @override
  String get dailyLoadingTitle => '占卜中';

  @override
  String get dailyLoadingMessage => '正在抽取今日牌面，並整理今天的心靈天氣。';

  @override
  String get dailyLoadFailed => '今日抽牌載入失敗';

  @override
  String get retryLoad => '重新載入';

  @override
  String get divinationTitle => '占卜館';

  @override
  String get divinationLoadFailed => '占卜館載入失敗';

  @override
  String get questionLabel => '想問的問題';

  @override
  String get promptWork => '工作方向';

  @override
  String get promptLove => '感情狀態';

  @override
  String get promptNextStep => '下一步選擇';

  @override
  String get startDraft => '展開 9 張牌';

  @override
  String get createReading => '產生解讀';

  @override
  String get readingCreateFailed => '占卜產生失敗';

  @override
  String get drawPreparingTitle => '準備牌陣';

  @override
  String get drawPreparingMessage => '正在洗牌，讓九張牌依序浮現。';

  @override
  String get drawTitle => '選三張有重量的牌。';

  @override
  String drawSelectedStatus(int selectedCount) {
    return '$selectedCount / 3 已選。點選後會翻面，選定後不可更換。';
  }

  @override
  String get drawReadButton => '查看解讀';

  @override
  String get deepLoadingTitle => '占卜中';

  @override
  String get deepLoadingMessage => '正在解讀你選出的三張牌，整理成可以保存的紀錄。';

  @override
  String get resultTitle => '深度占卜結果';

  @override
  String get resultQuestionTitle => '關於這個問題';

  @override
  String get resultCardsTitle => '三張牌的訊息';

  @override
  String get resultNoQuestion => '這次占卜沒有留下問題文字。';

  @override
  String get resultBackToReading => '回到占卜館';

  @override
  String get resultSave => '保存紀錄';

  @override
  String get resultSaving => '保存中';

  @override
  String get resultClear => '清除紀錄';

  @override
  String get resultClearing => '清除中';

  @override
  String get resultSaved => '已保存';

  @override
  String get fallbackResultQuestion =>
      '你正在問的不是「該不該前進」，而是「我能否在不確定裡仍然照顧自己」。月亮讓情緒浮上來，節制要求你把步伐放慢，星星則指出仍有一條溫柔但清楚的路。';

  @override
  String get fallbackResultBulletMoon => '月亮：現在的模糊不是錯誤，它是在提醒你有些資訊還未被說出口。';

  @override
  String get fallbackResultBulletTemperance => '節制：不要用一次談話解決全部。先確認界線，再確認期待。';

  @override
  String get fallbackResultBulletStar => '星星：真正值得靠近的答案，會讓你感到更完整，而不是更緊縮。';

  @override
  String get fallbackResultAdviceTitle => '今晚的建議';

  @override
  String get fallbackResultAdvice => '把問題拆成一個可行動的小句子：我明天可以多問一個問題，而不是立刻做一個決定。';

  @override
  String get deepSelectExactlyThreeCards => '必須選擇 3 張牌';

  @override
  String get deepNoSavableResult => '沒有可保存的占卜結果';

  @override
  String get libraryTitle => '塔羅圖書館';

  @override
  String get libraryLoadFailed => '牌庫載入失敗';

  @override
  String get searchCardsLabel => '搜尋牌名或關鍵字';

  @override
  String cardsCount(int count) {
    return '顯示 $count 張牌';
  }

  @override
  String get categoryAll => '全部';

  @override
  String get categoryMajor => '大阿爾克那';

  @override
  String get categoryWands => '權杖';

  @override
  String get categoryCups => '聖杯';

  @override
  String get categorySwords => '寶劍';

  @override
  String get categoryPentacles => '錢幣';

  @override
  String get profileTitle => '個人檔案';

  @override
  String get profileLoadFailed => '個人檔案載入失敗';

  @override
  String get profileLoadFallback => '無法載入個人檔案';

  @override
  String profileStats(int dailyCount, int deepCount) {
    return '每日抽牌 $dailyCount 次 · 深度占卜 $deepCount 次';
  }

  @override
  String get localeSystem => '系統';

  @override
  String get localeZh => '繁體中文';

  @override
  String get localeEn => 'English';

  @override
  String get weatherToggle => '每日抽牌使用天氣';

  @override
  String get editDisplayName => '編輯暱稱';

  @override
  String get signOut => '登出';

  @override
  String get deepResultTitle => '深度解讀';

  @override
  String get saveToHistory => '保存到歷史紀錄';

  @override
  String get selectedCardsTitle => '抽到的三張牌';

  @override
  String get historyTitle => '歷史紀錄';

  @override
  String get loadHistory => '載入歷史';

  @override
  String get emptyHistory => '尚未保存占卜紀錄';

  @override
  String get unnamedQuestion => '未命名問題';

  @override
  String get upright => '正位';

  @override
  String get reversed => '逆位';

  @override
  String cardMeaningText(String uprightMeaning, String reversedMeaning) {
    return '正位：$uprightMeaning\n逆位：$reversedMeaning';
  }

  @override
  String get editNameTitle => '編輯暱稱';

  @override
  String get nicknameLabel => '暱稱';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';
}
