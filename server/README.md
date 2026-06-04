# Pocket Tarot Server

Express + TypeScript backend for Pocket Tarot.

## Scripts

```bash
npm run dev
npm run build
npm test
```

`src/server.ts` requires `MONGODB_URI`. Local development can copy `.env.example` to `.env`.

`NEW_USERS_ACTIVE_BY_DEFAULT` controls whether newly registered profiles are immediately active. It defaults to `true`; set it to `false` to keep the previous admin-activation flow.

## Test Database

Integration tests use the MongoDB URI from `MONGODB_URI`, or `mongodb://127.0.0.1:27017/pocket_tarot_test` when unset. Tests create emails with a `test+...@pocket-tarot.local` marker and clean up only those exact emails.

## Local URLs

- Health check: `GET /healthz`
- Swagger UI: `GET /docs`
- OpenAPI JSON: `GET /docs.json`

API routes use `/api/v1`.

## Implemented API Segments

- `POST /api/v1/auth/register-profile`
- `GET /api/v1/users/me`
- `PATCH /api/v1/users/me`
- `GET /api/v1/admin/users`
- `GET /api/v1/admin/users/:id`
- `PATCH /api/v1/admin/users/:id/activation`
- `PATCH /api/v1/admin/users/:id/deletion`
- `POST /api/v1/admin/llm/test`
- `GET /api/v1/daily-readings/today`
- `POST /api/v1/daily-readings/today`
- `POST /api/v1/deep-readings/drafts`
- `POST /api/v1/deep-readings`
- `GET /api/v1/deep-readings/history`
- `GET /api/v1/deep-readings/:id`
- `PATCH /api/v1/deep-readings/:id/history-visibility`
