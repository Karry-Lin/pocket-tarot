# Pocket Tarot 後端服務 (Server)

這是 Pocket Tarot 的 Express + TypeScript 後端專案，提供身分驗證、使用者管理、每日抽牌以及深度占卜等 API 功能。

---

## 腳本說明

```bash
# 本地開發啟動（熱重載）
npm run dev

# 專案編譯為 JavaScript
npm run build
```

---

## 環境變數配置

在執行服務前，必須在 `server/` 目錄下建立 `.env` 檔案（可從 `.env.example` 複製修改）：

- `PORT`：後端伺服器的啟動埠號（預設為 `4000`）。
- `MONGODB_URI`：MongoDB 的連接字串（例如 `mongodb://127.0.0.1:27017/pocket_tarot`）。
- `ADMIN_API_KEY`：管理員端點進行操作時所需的認證金鑰。
- `NEW_USERS_ACTIVE_BY_DEFAULT`：控制新註冊使用者是否自動設為啟用（active）。預設為 `true`；若設為 `false`，新註冊帳號必須經由管理員（Admin API）手動啟用後前端才能進入 App。
- **LLM 相關設定**：
  - `LLM_BASE_URL`：相容 OpenAI 規格的 Chat Completions API 基礎位址。
  - `LLM_API_KEY`：LLM 服務的金鑰。
  - `LLM_MODEL`：要調用的 LLM 模型名稱。
  - `LLM_READING_TEMPERATURE`：（可選）生成牌意時的隨機度（預設 `0.8`）。
  - `LLM_SUMMARY_TEMPERATURE`：（可選）生成摘要時的隨機度（預設 `0.3`）。
  - `LLM_TIMEOUT_MS`：（可選）LLM API 請求逾時時間（毫秒，預設 `30000`）。
  - `LLM_MAX_RETRIES`：（可選）LLM API 請求失敗重試次數（預設 `1`）。
- **Firebase Admin 相關設定**：
  - `GOOGLE_APPLICATION_CREDENTIALS`：Firebase Admin 服務帳戶私鑰憑證 JSON 檔案的**絕對路徑**。
  - `GOOGLE_CLOUD_PROJECT`：您的 Firebase 專案 ID。

---

## 本地服務端點

後端預設啟動於 `http://localhost:4000`：

- **健康檢查**：`GET /healthz`
- **Swagger API 文件網頁**：`GET /docs`
- **OpenAPI JSON 設定檔**：`GET /docs.json`
- **API 基礎路徑**：`/api/v1`

---

## 已實作之 API 端點說明

### 0. 系統健康檢查 (System Health)
- `GET /healthz`：伺服器健康狀況檢查（由前端啟動防護認證關卡調用，回傳 `{"status": "ok"}`）。

### 1. 會員註冊與管理 (Auth & Users)
- `POST /api/v1/auth/register-profile`：註冊新帳戶 Profile（會依據 `NEW_USERS_ACTIVE_BY_DEFAULT` 標註 active 狀態）。
- `GET /api/v1/users/me`：獲取當前登入者資訊（名稱、信箱、註冊時間、狀態）。
- `PATCH /api/v1/users/me`：修改當前使用者的個人檔案（如修改顯示名稱）。

### 2. 每日抽牌 (Daily Readings)
- `GET /api/v1/daily-readings/today`：取得今日的抽牌結果。
- `POST /api/v1/daily-readings/today`：發送抽牌請求（可傳入 `locale` 和 `weather` 地理天氣資訊），調用 LLM 產出解讀。
- `DELETE /api/v1/daily-readings/today`：清除/重置今日的抽牌紀錄（由前端主畫面之「清除」按鈕調用）。

### 3. 深度占卜 (Deep Readings)
- `POST /api/v1/deep-readings/drafts`：建立三張牌占卜草稿。
- `POST /api/v1/deep-readings`：確認完成挑牌，傳送問題與選牌資訊，調用 LLM 分析解讀。
- `GET /api/v1/deep-readings/history`：獲取該使用者所有的占卜歷史紀錄。
- `GET /api/v1/deep-readings/:id`：取得特定一筆深度占卜解讀結果。
- `PATCH /api/v1/deep-readings/:id/history-visibility`：切換該筆紀錄是否顯示於歷史列表中。

### 4. 後台管理與測試 (Admin Only)
- `GET /api/v1/admin/users`：管理員列出所有註冊使用者。
- `GET /api/v1/admin/users/:id`：獲取特定使用者的詳細資料與狀態。
- `PATCH /api/v1/admin/users/:id/activation`：修改使用者的啟用狀態 (active / inactive)。
- `PATCH /api/v1/admin/users/:id/deletion`：標註使用者帳號為已刪除 (deleted)。
- `POST /api/v1/admin/llm/test`：測試後端 LLM API 連線與產出。

---

## 外部第三方 API 介接說明

為了完成占卜與天氣脈絡的生成，後端服務會在其內部邏輯中主動向以下外部服務發送 HTTP 請求：

1. **相容 OpenAI Chat Completions API** (`POST {LLM_BASE_URL}/chat/completions`)
   - **用途**：呼叫 LLM 模型產生「每日抽牌」及「深度占卜」的 Markdown 解讀文本與簡短摘要。
   - **配置**：經由環境變數 `LLM_BASE_URL`、`LLM_API_KEY` 與 `LLM_MODEL` 進行配置。

2. **Open-Meteo 氣象預報 API** (`GET https://api.open-meteo.com/v1/forecast`)
   - **用途**：當使用者在每日抽卡時開啟了天氣功能，後端會依據定位經緯度即時抓取該處的溫度、降雨、濕度以及天氣代碼。

3. **OpenStreetMap Nominatim 反向地理編碼 API** (`GET https://nominatim.openstreetmap.org/reverse`)
   - **用途**：將使用者每日抽卡所傳送的經緯度，反向解析為具體易讀的城市或行政區有名名稱（如 "台北市"、"San Francisco"），以便於在天氣卡片中顯示位置資訊。

4. **Firebase Token 驗證 API**
   - **用途**：Firebase Admin SDK 會定期與 Google 認證金鑰伺服器連線，下載最新的 X.509 公鑰以安全地在本機解析與驗證前端傳過來的 Bearer JWT token。

