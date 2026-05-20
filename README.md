# Pocket Tarot

Pocket Tarot 是 Android 優先的塔羅牌占卜 App。第一版包含 Firebase 登入註冊、人工啟用帳號、每日抽牌、深度占卜、占卜館歷史、塔羅圖書館、個人檔案、本地語言/天氣設定，以及 Express API 文件。

## 專案結構

```text
flutter/  Flutter app、Firebase client auth、本地設定、多語系、塔羅牌 assets
server/   Express + TypeScript API、MongoDB、Firebase Admin auth、LLM、天氣、OpenAPI
docs/     系統設計、API、DB schema、Flutter flow、LLM contract、測試策略
```

系統設計入口是 `ARCHITECTURE.md`，細節文件放在 `docs/architecture/`。

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

驗證：

```bash
flutter analyze
flutter test
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
npm test
```

本機 URL：

- Health check：`GET /healthz`
- Swagger UI：`GET /docs`
- OpenAPI JSON：`GET /docs.json`
- API base path：`/api/v1`

## 測試資料邊界

後端測試使用真 MongoDB，但只能清理帶明確 marker 的測試資料。禁止 `dropDatabase()` 或無條件清空 collection。

## 主要文件

- `ARCHITECTURE.md`
- `docs/architecture/api.md`
- `docs/architecture/db-schema.md`
- `docs/architecture/flutter-flow.md`
- `docs/architecture/llm-contract.md`
- `docs/architecture/testing.md`
- `flutter/README.md`
- `server/README.md`
