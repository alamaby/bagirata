// Supabase Edge Function: process-receipt
//
// Multi-image receipt OCR with DB-driven provider rotation.
//
// Provider configs (api_key, base_url, model_name, priority) live in the
// `llm_configs` table; this function loads active rows ordered by priority
// and tries each in turn. Per-attempt telemetry is fire-and-forget written
// to `llm_logs` so failures can be diagnosed in the dashboard.
//
// Request:  { images: string[] /* base64, no data: prefix */, hint?: string }
// Response: { items, detected_total, detected_tax, detected_service,
//             merchant, receipt_date, confidence, provider_used }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT =
  `You are a receipt parser. Extract line items, totals, tax, service charges, merchant, and receipt date from the attached photos.

Return STRICTLY this JSON shape, no prose:
{
  "items": [{"name": string, "price": number, "qty": integer}],
  "detected_total": number | null,
  "detected_tax": number | null,
  "detected_service": number | null,
  "merchant": string | null,
  "receipt_date": string | null,   // ISO 8601
  "confidence": number              // 0..1
}

Rules:
- Combine duplicate line items by summing qty when names match exactly.
- Prices are per-unit (so subtotal = price * qty); never include tax in price.
- If multiple photos show different parts of the same receipt, merge them.
- Use the receipt's currency as-is; do not convert.`;

interface OcrPayload {
  items: { name: string; price: number; qty: number }[];
  detected_total: number | null;
  detected_tax: number | null;
  detected_service: number | null;
  merchant: string | null;
  receipt_date: string | null;
  confidence: number;
}

interface LlmConfig {
  id: string;
  provider_name: string;
  api_key: string;
  base_url: string | null;
  model_name: string | null;
  priority: number;
}

class ProviderError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

function isOcrPayload(value: unknown): value is OcrPayload {
  if (!value || typeof value !== "object") return false;
  const v = value as Record<string, unknown>;
  if (!Array.isArray(v.items)) return false;
  for (const it of v.items) {
    if (
      !it || typeof it !== "object" ||
      typeof (it as Record<string, unknown>).name !== "string" ||
      typeof (it as Record<string, unknown>).price !== "number"
    ) {
      return false;
    }
  }
  return typeof v.confidence === "number";
}

function buildGeminiUrl(baseUrl: string, modelName: string, apiKey: string): string {
  // Defensive: terima 3 konvensi `base_url`.
  // 1) Sudah include `:generateContent` → pakai apa adanya.
  if (baseUrl.includes(":generateContent")) {
    return `${baseUrl}${baseUrl.includes("?") ? "&" : "?"}key=${apiKey}`;
  }
  const trimmed = baseUrl.replace(/\/+$/, "");
  // 2) Sudah include /v1beta atau /v1.
  if (/\/v1(beta)?(\/|$)/.test(trimmed)) {
    return `${trimmed}/models/${modelName}:generateContent?key=${apiKey}`;
  }
  // 3) Host-only → default ke /v1beta.
  return `${trimmed}/v1beta/models/${modelName}:generateContent?key=${apiKey}`;
}

function buildOpenRouterUrl(baseUrl: string): string {
  if (baseUrl.endsWith("/chat/completions")) return baseUrl;
  return `${baseUrl.replace(/\/+$/, "")}/chat/completions`;
}

async function callGemini(
  cfg: LlmConfig,
  images: string[],
  hint?: string,
): Promise<OcrPayload> {
  if (!cfg.base_url) throw new ProviderError("gemini base_url missing", 400);
  if (!cfg.model_name) throw new ProviderError("gemini model_name missing", 400);
  const url = buildGeminiUrl(cfg.base_url, cfg.model_name, cfg.api_key);
  const parts: unknown[] = [
    { text: SYSTEM_PROMPT + (hint ? `\n\nHint: ${hint}` : "") },
    ...images.map((b64) => ({
      inline_data: { mime_type: "image/jpeg", data: b64 },
    })),
  ];
  const res = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      contents: [{ role: "user", parts }],
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.1,
      },
    }),
    signal: AbortSignal.timeout(15_000),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new ProviderError(`gemini ${res.status}: ${body.slice(0, 300)}`, res.status);
  }
  const json = await res.json();
  const text = json?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string") {
    throw new ProviderError("gemini empty body", 502);
  }
  const parsed = JSON.parse(text);
  if (!isOcrPayload(parsed)) {
    throw new ProviderError("gemini schema mismatch", 422);
  }
  return parsed;
}

async function callOpenRouter(
  cfg: LlmConfig,
  images: string[],
  hint?: string,
): Promise<OcrPayload> {
  if (!cfg.base_url) throw new ProviderError("openrouter base_url missing", 400);
  if (!cfg.model_name) throw new ProviderError("openrouter model_name missing", 400);
  const url = buildOpenRouterUrl(cfg.base_url);
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${cfg.api_key}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: cfg.model_name,
      response_format: { type: "json_object" },
      temperature: 0.1,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        {
          role: "user",
          content: [
            ...(hint ? [{ type: "text", text: `Hint: ${hint}` }] : []),
            ...images.map((b64) => ({
              type: "image_url",
              image_url: { url: `data:image/jpeg;base64,${b64}` },
            })),
          ],
        },
      ],
    }),
    signal: AbortSignal.timeout(20_000),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new ProviderError(
      `openrouter ${res.status}: ${body.slice(0, 300)}`,
      res.status,
    );
  }
  const json = await res.json();
  const text = json?.choices?.[0]?.message?.content;
  if (typeof text !== "string") {
    throw new ProviderError("openrouter empty body", 502);
  }
  const parsed = JSON.parse(text);
  if (!isOcrPayload(parsed)) {
    throw new ProviderError("openrouter schema mismatch", 422);
  }
  return parsed;
}

async function callProvider(
  cfg: LlmConfig,
  images: string[],
  hint?: string,
): Promise<OcrPayload> {
  switch (cfg.provider_name.toLowerCase()) {
    case "gemini":
      return await callGemini(cfg, images, hint);
    case "openrouter":
      return await callOpenRouter(cfg, images, hint);
    case "nvidianim":
      throw new ProviderError("nvidianim not_implemented", 501);
    default:
      throw new ProviderError(
        `unsupported_provider: ${cfg.provider_name}`,
        400,
      );
  }
}

function statusOf(err: unknown): number {
  if (err instanceof ProviderError) return err.status;
  // AbortSignal.timeout throws DOMException 'TimeoutError' — surface as 408.
  if (err instanceof DOMException && err.name === "TimeoutError") return 408;
  return 500;
}

function shouldFailover(err: unknown): boolean {
  const status = statusOf(err);
  // 429 (quota), 5xx, dan 408 (timeout) → failover. 4xx auth/invalid → stop.
  return status === 429 || status >= 500 || status === 408;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  let body: { images?: string[]; hint?: string };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: "invalid_json" }, 400);
  }
  const images = body.images;
  const hint = body.hint;
  if (
    !Array.isArray(images) || images.length === 0 ||
    images.some((x) => typeof x !== "string")
  ) {
    return jsonResponse({ error: "images_required" }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse({ error: "supabase_env_missing" }, 500);
  }
  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data: configs, error: cfgErr } = await supabase
    .from("llm_configs")
    .select("id, provider_name, api_key, base_url, model_name, priority")
    .eq("is_active", true)
    .order("priority", { ascending: true });

  if (cfgErr) {
    return jsonResponse(
      { error: "llm_configs_load_failed", detail: cfgErr.message },
      500,
    );
  }
  if (!configs || configs.length === 0) {
    return jsonResponse({ error: "no_active_provider" }, 500);
  }

  // Telemetry helper — fire-and-forget, tidak boleh memblok response.
  const logAttempt = (
    cfg: LlmConfig,
    statusCode: number,
    latencyMs: number,
    ok: boolean,
    summary: unknown,
  ): void => {
    supabase.from("llm_logs").insert({
      bill_id: null,
      provider: cfg.provider_name,
      request_payload: {
        model: cfg.model_name,
        image_count: images.length,
        hint: hint ?? null,
      },
      response_payload: ok && summary && typeof summary === "object"
        ? {
          items_count: (summary as OcrPayload).items?.length ?? 0,
          confidence: (summary as OcrPayload).confidence ?? null,
        }
        : summary,
      latency_ms: latencyMs,
      status_code: statusCode,
    }).then(() => {}, () => {});
  };

  const errors: { provider: string; status: number; message: string }[] = [];

  for (const cfg of configs as LlmConfig[]) {
    const start = Date.now();
    try {
      const payload = await callProvider(cfg, images, hint);
      logAttempt(cfg, 200, Date.now() - start, true, payload);
      return jsonResponse({
        items: payload.items,
        detected_total: payload.detected_total,
        detected_tax: payload.detected_tax,
        detected_service: payload.detected_service,
        merchant: payload.merchant,
        receipt_date: payload.receipt_date,
        confidence: payload.confidence,
        provider_used: cfg.provider_name,
      });
    } catch (e) {
      const status = statusOf(e);
      const message = e instanceof Error ? e.message : String(e);
      logAttempt(cfg, status, Date.now() - start, false, { error: message });
      errors.push({ provider: cfg.provider_name, status, message });
      if (!shouldFailover(e)) break;
    }
  }

  return jsonResponse(
    { error: "all_providers_failed", attempts: errors },
    502,
  );
});
