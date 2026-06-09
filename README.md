# Pocket Tarot 隨身塔羅

Pocket Tarot 是一款專為 Android 設計、相容 Web 端開發的塔羅牌占卜 App。本專案結合了 Firebase 身分驗證、Flutter 行動介面、Express (TypeScript) API、MongoDB 儲存，以及 OpenAI 相容的 Chat Completions LLM 牌意解讀。

本專案旨在提供一個流暢、具儀式感且具備完整帳號狀態管理的占卜平台，包含每日抽牌、提問式深度占卜、歷史紀錄與個人設定。

---

## 專案功能特色

1. **帳號狀態與安全防護（Auth Gate）**：
   - 整合 Firebase Auth 支援 Email/密碼 註冊登入、Google 登入與 GitHub 登入。
   - 具備完整的 Email 驗證（Email Verification）、新帳號人工/自動啟用、帳號刪除流程。
   - **智慧型帳號連結（Account Linking）**：當使用者用第三方帳號（如 GitHub）登入，且其信箱已被原有的 Email 或 Google 註冊時，會跳出底部選單引導使用者以「原本的登入方式」進行驗證（例如輸入原信箱密碼或進行 Google 驗證），並安全地將新登入方式連結至同一帳號。

2. **每日抽牌（Daily Reading）**：
   - 每天可進行一次單張牌占卜。
   - 支援自動取得設備定位（經由 Geolocator），向後端 API 發送天氣請求以在解讀中融入當前的「心靈天氣」脈絡（若無定位權限則以無天氣模式安全回退）。
   - 提供清除今日抽卡紀錄並重新回到抽卡儀式畫面的功能。

3. **深度占卜（Deep Divination）**：
   - 三張牌（問題核心、隱藏影響、行動建議）的提問式深度占卜。
   - 支援占卜草稿建立、手動挑選三張牌、即時顯示牌面正逆位與說明。
   - 支援將占卜結果儲存至歷史紀錄，並可自由切換歷史紀錄的公開/隱藏狀態。

4. **塔羅圖書館（Tarot Library）**：
   - 本地端完整收錄 78 張偉特塔羅牌（22 張大阿爾克那、56 張小阿爾克那）的名稱、正逆位牌義與圖像。不需依賴後端網路即可離線查閱。
   - 當使用者名稱包含英文時，系統使用優雅的 `Lora` 襯線體呈現，完美保留原始輸入的大小寫字母。

5. **安全閱讀輸出（Safe Markdown）**：
   - 後端 LLM 產出的解讀結果會在 Flutter 端透過安全的 Markdown 渲染器顯示，僅保留標題、段落、列表與分隔線，自動剔除可能包含 HTML、圖片、表格或外部連結的不安全標籤，確保 UI 乾淨安全。

---

## 技術棧與專案結構

本專案採用前後端分離架構：
- **`flutter/`**：Flutter 行動 App，負責 Firebase Client Auth、地圖定位、本地語系切換、SharedPreferences 本地設定與 78 張牌卡靜態資源。
- **`server/`**：Express + TypeScript 後端 API，整合 Firebase Admin SDK 進行 token 驗證，搭配 MongoDB (Mongoose) 儲存資料，並整合 Open-Meteo 天氣 API 與 OpenAI 相容 LLM API。

---

## 必要服務與環境變數

在啟動專案前，您需要準備以下服務：
- **Firebase Authentication**：處理身份驗證、Email 驗證、Google/GitHub 登入與 Token 驗證。
- **MongoDB**：儲存使用者 Profiles、每日抽卡紀錄、深度占卜紀錄與草稿。
- **OpenAI 相容 Chat Completions API**：調用大語言模型生成塔羅牌義解讀與簡短摘要。
- **Open-Meteo 氣象 API**：在每日抽牌中融入當地的溫度與天氣狀況。
- **Nominatim OpenStreetMap API**：將抽牌時定位的經緯度，反向解析為可讀的地理位置名稱（例如城市名）顯示於 App 中。

---

## 快速開始

### 後端服務 (Server)

1. 進入目錄並安裝依賴：
   ```bash
   cd server
   npm install
   ```
2. 設定環境變數：
   複製 `server/.env.example` 為 `server/.env`，並依需求填入 `MONGODB_URI`、`LLM_API_KEY`、`GOOGLE_APPLICATION_CREDENTIALS` 等欄位。
   - 註：`NEW_USERS_ACTIVE_BY_DEFAULT` 控制註冊後是否自動啟用（預設 `true`，若為 `false` 則需管理員手動啟用）。
3. 啟動開發伺服器：
   ```bash
   npm run dev
   ```
   - 健康檢查端點：`GET http://localhost:4000/healthz`
   - API 文檔（Swagger）：`GET http://localhost:4000/docs`

### 前端應用 (Flutter)

1. 進入目錄並安裝套件：
   ```bash
   cd flutter
   flutter pub get
   ```
2. 設定 Firebase：
   使用 `flutterfire configure` 產生本地 `firebase_options.dart` 設定。
3. 執行 App（以 Web 開發環境為例，透過 `--dart-define` 注入後端 API 位址）：
   ```bash
   # 本地 Web 測試
   flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1

   # 本地 Android 模擬器測試
   flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
   ```

---

## 構建與部署驗證

### 後端驗證
```bash
cd server
npm run build
```

### 前端編譯 (Android APK)
如果要進行實機測試，請使用實體設備可連線的後端 API 位址進行編譯：
```bash
cd flutter
flutter analyze
flutter build apk --release --dart-define=API_BASE_URL=https://your-production-api.com/api/v1
```
編譯產物將會生成在 `build/app/outputs/flutter-apk/app-release.apk`。

---

## 詳細文件

更多詳細細節，請參閱各子目錄下的說明文件：
- [Flutter 端詳細文件說明](file:///c:/Users/Kerry/Desktop/pocket-tarot/flutter/README.md)
- [後端 Server 端詳細文件說明](file:///c:/Users/Kerry/Desktop/pocket-tarot/server/README.md)

