# `process-receipt` Edge Function

Parses one or more receipt photos into structured line items using a
**Gemini 2.0 Flash → OpenRouter** failover chain.

## Contract

### Request — `POST /functions/v1/process-receipt`

```json
{
  "images": ["<base64 JPEG without data: prefix>", "..."],
  "hint": "optional free-text hint (e.g. 'menu prices include 11% PB1')"
}
```

### Success — `200`

```json
{
  "items": [{ "name": "Nasi Goreng", "price": 35000, "qty": 2 }],
  "detected_total": 110000,
  "detected_tax": 11000,
  "detected_service": 5500,
  "merchant": "Warung Sederhana",
  "receipt_date": "2026-04-25",
  "confidence": 0.92,
  "provider_used": "gemini"
}
```

`provider_used` reflects which provider answered: `"gemini"` on the happy path,
`"openrouter"` on failover.

### Failure modes

| Status | `error`                  | Meaning                                                  |
| ------ | ------------------------ | -------------------------------------------------------- |
| 400    | `invalid_json`           | body wasn't valid JSON                                   |
| 400    | `images_required`        | `images` missing/empty/non-string                        |
| 405    | `method_not_allowed`     | non-POST                                                 |
| 422    | `gemini_failed`          | Gemini returned but JSON didn't match the schema         |
| 5xx    | `all_providers_failed`   | both providers failed; payload includes both error texts |

## Required secrets

```bash
supabase secrets set GEMINI_API_KEY=...
supabase secrets set OPENROUTER_API_KEY=...
```

`OPENROUTER_API_KEY` is optional but strongly recommended — without it there
is no failover, and Gemini quota outages surface to users directly.

## Failover policy (the "why")

Gemini Flash is the **primary** because it's roughly 5× cheaper per image than
the next-best vision model. We fail over to OpenRouter when the primary
indicates capacity / availability problems (HTTP 429, 5xx, or a 15s timeout).
We do **not** fail over on 4xx other than 429 — those usually mean a malformed
request, which would fail identically on the secondary.

Within OpenRouter we attempt the free Gemini route first, then fall back to
`anthropic/claude-haiku-4.5` only if rate-limited. The double-fallback keeps
the median cost tied to the free tier while preserving a paid escape hatch.

## Local dev

```bash
supabase functions serve process-receipt --env-file .env.local
```

Smoke-test failover by temporarily unsetting `GEMINI_API_KEY` — the response
should keep working with `provider_used: "openrouter"`.
