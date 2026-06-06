# Pocket Tarot

Pocket Tarot 是 Android 優先的塔羅牌占卜 App，結合 Firebase 身分驗證、Flutter 行動介面、Express API、MongoDB 儲存，以及 OpenAI-compatible Chat Completions 產生牌義解讀。它的目標不是只提供靜態牌卡說明，而是把每日抽牌、提問式深度占卜、歷史紀錄與個人設定串成一個可以持續使用的占卜體驗。

使用者可以透過 Email/Password 或 Google 登入，完成 Email verification 與帳號啟用流程後進入主 App。主畫面提供每日抽牌，會依照使用者設定帶入語言與可選的天氣 context，產生當日牌卡解讀與摘要；占卜館則提供三張牌的深度占卜流程，使用者可以輸入問題、選牌、查看結果，並決定是否保留在歷史紀錄中。塔羅圖書館收錄完整 78 張牌卡資料，讓使用者能在占卜之外查閱牌義。

## App 特色

- 每日抽牌：建立每天一筆的牌卡解讀，支援本地語言與可選天氣 context。
- 深度占卜：支援提問、草稿、三張牌選擇、結果產生與歷史紀錄。
- 塔羅圖書館：Flutter 端內建完整 78 張塔羅牌資料，查閱不依賴後端。
- 會員與帳號狀態：整合 Firebase Auth、Email 驗證、人工啟用、帳號刪除與重新導向流程。
- 個人設定：支援顯示名稱、本地語言模式與天氣開關。
- 安全閱讀輸出：占卜結果以受限 Markdown 呈現，避免把不必要的 HTML、圖片、表格或連結帶進 UI。

## 技術概觀

Flutter app 負責行動端體驗、Firebase client auth、本地設定、牌卡 assets 與 API 呼叫；Server 端以 Express + TypeScript 提供使用者、每日抽牌、深度占卜、管理者與文件化 API。後端使用 MongoDB 儲存使用者與占卜紀錄，透過 Firebase Admin 驗證 Bearer token，並呼叫 LLM 與 Open-Meteo 產生更貼近使用情境的解讀內容。

整體設計把「帳號狀態判斷」、「抽牌資料」、「LLM 內容產生」與「前端呈現」拆開：Flutter 啟動時會先檢查 API 健康狀態，再依 Firebase session、Email 驗證、profile、啟用狀態與刪除狀態決定要進入登入頁、驗證頁、等待啟用頁或主 App。這讓離線、API down、帳號尚未啟用等狀態都能有明確的畫面與流程。

## 專案結構

```text
flutter/  Flutter app、Firebase client auth、本地設定、多語系、塔羅牌 assets
server/   Express + TypeScript API、MongoDB、Firebase Admin auth、LLM、天氣、OpenAPI
```

## 必要服務

- Firebase Authentication：Email/Password、Email verification、Google sign-in。
- MongoDB：users、daily_readings、deep_readings。
- OpenAI-compatible Chat Completions：產生 reading markdown 與 summary。
- Open-Meteo：每日抽牌可選天氣 context。

## Flutter

```bash
cd flutter
flutter pub get
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1
```

### API 環境切換

Flutter 端使用 `--dart-define=API_BASE_URL=...` 控制 API base URL。這是編譯期設定，web build 產物完成後不能靠伺服器環境變數切換 API，需要重新 build。

```bash
# local web
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://127.0.0.1:4000/api/v1

# local Android emulator
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1

# dev Android emulator
flutter run -d emulator-5554 --dart-define=API_BASE_URL=https://tarot-api-dev.julojulo.com/api/v1

# dev
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=https://tarot-api-dev.julojulo.com/api/v1

# prod
flutter build web --release --dart-define=API_BASE_URL=https://tarot-api.julojulo.com/api/v1
```

也可以用 `--dart-define-from-file` 管理環境檔，例如 `flutter/env/dev.json`：

```json
{
  "API_BASE_URL": "https://tarot-api-dev.julojulo.com/api/v1"
}
```

```bash
flutter build web --release --dart-define-from-file=env/dev.json
```

不要把 MongoDB URI、LLM API key、Firebase Admin service account 等 server secrets 放進 Flutter build。

驗證：

```bash
flutter analyze
flutter build web --release
```

## Server

```bash
cd server
npm install
npm run dev
```

`server/src/server.ts` 需要 `MONGODB_URI`，可從 `server/.env.example` 建立本機 `.env`。

驗證：

```bash
npm run build
```

本機 URL：

- Health check：`GET /healthz`
- Swagger UI：`GET /docs`
- OpenAPI JSON：`GET /docs.json`
- API base path：`/api/v1`

## 主要文件

- `flutter/README.md`
- `server/README.md`
