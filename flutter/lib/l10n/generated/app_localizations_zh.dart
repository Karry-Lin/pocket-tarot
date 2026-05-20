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
  String get dailyLoadFailed => '今日抽牌載入失敗';

  @override
  String get retryLoad => '重新載入';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '口袋塔羅';

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
  String get dailyLoadFailed => '今日抽牌載入失敗';

  @override
  String get retryLoad => '重新載入';
}
