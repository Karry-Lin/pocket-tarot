# Pocket Tarot 前端應用 (Flutter)

這是 Pocket Tarot 的 Flutter 前端專案，專為 Android 優先設計，並相容 Web 端開發測試。

---

## 快速啟動

執行時需使用 `--dart-define` 注入後端 API 連線位址。

```bash
# Web 端本機開發（預設 port 3000）
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1

# Android 模擬器本機開發（指向主機的 10.0.2.2）
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1

# 實機測試（指向局域網 IP 或實體開發伺服器）
flutter run -d <DEVICE_ID> --dart-define=API_BASE_URL=https://tarot-api-dev.julojulo.com/api/v1
```

---

## 程式碼檢查與編譯

```bash
# 靜態分析
flutter analyze

# 編譯 Web 釋出版本
flutter build web --release

# 編譯 Android APK 釋出版本
flutter build apk --release --dart-define=API_BASE_URL=https://tarot-api.julojulo.com/api/v1
```
生成的 APK 檔案路徑：`build/app/outputs/flutter-apk/app-release.apk`。

---

## 核心模組架構說明

### 1. 啟動與防護機制（Auth Gate & App Startup）
- **`lib/app/app_providers.dart`**：整合啟動所需的所有實體，包含 API 健康檢查、延遲 Firebase 初始化、Firebase Auth 服務、Dio Client Token 載入與認證控制。
- **`lib/domain/use_cases/app_startup_controller.dart`**：將啟動與 API 健康狀況轉化成對應路徑（例如無網路、帳號已刪除等狀態）。
- **`lib/domain/use_cases/auth_gate_evaluator.dart`**：實作狀態引導鏈，依據「API 健康 -> 登入狀態 -> 信箱驗證 -> Profile 註冊 -> 啟用狀態 -> 帳號刪除 -> 主畫面」順序進行頁面分流。
- **進入點路由 `/splash`**：啟動時顯示載入畫面，若 API 連線失敗會阻擋並提供重試按鈕。亦處理 `/account-deleted`、`/verify-email`、`/pending` 等保護頁面。

### 2. 身分驗證與帳號連結（Firebase Auth Service）
- **`lib/data/services/firebase_auth_service.dart`**：整合 Firebase SDK 與 Google / GitHub 登入。
- **帳號連結 (Account Linking)**：當以第三方（如 GitHub）登入但遇到信箱已被其他方式（如 Google 或 Email/密碼）佔用時，會觸發 `AccountLinkingRequired` 例外，跳出 `_AccountLinkingSheet` 底部選單，引導使用者輸入原密碼或使用 Google 驗證，成功後透過 `linkPendingCredential` 自動將 GitHub 連結至原有帳號。
- **`lib/domain/use_cases/auth_form_validator.dart`**：負責登入、註冊、重設密碼的欄位即時驗證。

### 3. 本地塔羅牌圖書館（Local Tarot Catalog）
- 為了確保在離線狀態下依然可用，圖書館分頁會直接從 `assets/data/tarot_cards.json` 讀取全部 78 張偉特塔羅牌資料。
- 顯示英文名稱與標題時，使用 `Lora` 襯線字體，避免預設字體強制將所有英文暱稱或標題改為全大寫（Small Caps），完整保留使用者輸入的原始大小寫。

### 4. 每日抽牌與定位天氣服務
- **`lib/domain/use_cases/daily_reading_controller.dart`**：控制首頁的抽牌狀態流（今日未抽、AI 產出中、完成解讀、錯誤重試）。支援清除今日抽卡紀錄。
- **`lib/data/services/device_location_service.dart`**：整合 Geolocator 請求位置權限。抽牌時取得經緯度傳送給後端以納入當地天氣資訊，若使用者拒絕權限或定位失敗，將以「無天氣狀態」安全回退，不阻擋抽牌流程。

### 5. 深度占卜（Deep Divination）
- **`lib/domain/use_cases/deep_reading_controller.dart`**：掌管占卜館（Divination Room）狀態，支援建立占卜草稿、手動挑選三張牌、請求 LLM 分析，以及載入歷史紀錄。
- 提供 `history-visibility` 切換，允許使用者隨時設定該筆占卜在歷史紀錄中公開或隱藏。

### 6. 個人設定（Local Settings）
- **`lib/data/repositories/local_settings_repository.dart`**：利用 SharedPreferences 本地儲存使用者偏好的語系模式（系統預設、繁體中文、英文）與天氣開關。
- **`appLocaleProvider`**：將本地儲存的語系直接套用至 `MaterialApp.locale`，當使用者在 Profile 更改語系時，App 會即時切換介面文字。

### 7. 安全 Markdown 渲染（Safe Markdown）
- **`lib/ui/core/widgets/safe_markdown_body.dart`**：自訂安全渲染器。在將 LLM 生成的 Markdown 繪製到 UI 前，會自動過濾並剔除所有不安全的 HTML 標籤、圖片、表格、程式碼區塊以及外部超連結，僅保留純文字的段落、標題、列表和水平線，防止 UI 跑版並確保閱讀安全。

