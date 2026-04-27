// Supabase Edge Function: process-receipt
//
// Multi-image receipt OCR with Gemini → OpenRouter failover.
//
// Why this exists server-side rather than in the Flutter client:
//   1. API keys never reach the device.
//   2. Provider failover logic can change without an app release.
//   3. Token-cost telemetry stays centralised.
//
// Request:  { images: string[] /* base64, no data: prefix */, hint?: string }
// Response: {
//   items: [{ name, price, qty }],
//   detectedTotal?, detectedTax?, detectedService?, merchant?, receiptDate?,
//   confidence: number, providerUsed: 'gemini' | 'openrouter'
// }

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `You are a receipt parser. Extract line items, totals, tax, service charges, merchant, and receipt date from the attached photos.

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

async function callGemini(
  apiKey: string,
  images: string[],
  hint?: string,
): Promise<OcrPayload> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${apiKey}`;
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
    throw new ProviderError(`gemini ${res.status}`, res.status);
  }
  const json = await res.json();
  const text = json?.candidates?.[0]?.content?.parts?.[0]?.text;
  if (typeof text !== "string") throw new ProviderError("gemini empty body", 502);
  const parsed = JSON.parse(text);
  if (!isOcrPayload(parsed)) throw new ProviderError("gemini schema mismatch", 422);
  return parsed;
}

async function callOpenRouter(
  apiKey: string,
  images: string[],
  hint?: string,
): Promise<OcrPayload> {
  const tryModel = async (model: string): Promise<OcrPayload> => {
    const res = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model,
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
    if (!res.ok) throw new ProviderError(`openrouter ${res.status}`, res.status);
    const json = await res.json();
    const text = json?.choices?.[0]?.message?.content;
    if (typeof text !== "string") throw new ProviderError("openrouter empty body", 502);
    const parsed = JSON.parse(text);
    if (!isOcrPayload(parsed)) throw new ProviderError("openrouter schema mismatch", 422);
    return parsed;
  };

  // Cheap free-tier first; fall back to a paid model only on rate-limit.
  try {
    return await tryModel("google/gemini-2.0-flash-exp:free");
  } catch (e) {
    if (e instanceof ProviderError && e.status === 429) {
      return await tryModel("anthropic/claude-haiku-4.5");
    }
    throw e;
  }
}

class ProviderError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

function shouldFailover(err: unknown): boolean {
  if (!(err instanceof ProviderError)) return true; // unknown error → try fallback
  // 429 (quota), 5xx, and timeouts (mapped to 408 by AbortSignal) → fail over.
  return err.status === 429 || err.status >= 500 || err.status === 408;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return jsonResponse({ error: "method_not_allowed" }, 405);

  let body: { images?: string[]; hint?: string };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: "invalid_json" }, 400);
  }
  const images = body.images;
  if (!Array.isArray(images) || images.length === 0 || images.some((x) => typeof x !== "string")) {
    return jsonResponse({ error: "images_required" }, 400);
  }

  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  const openRouterKey = Deno.env.get("OPENROUTER_API_KEY");

  let payload: OcrPayload | null = null;
  let providerUsed: "gemini" | "openrouter" | null = null;
  let primaryError: unknown = null;

  if (geminiKey) {
    try {
      payload = await callGemini(geminiKey, images, body.hint);
      providerUsed = "gemini";
    } catch (e) {
      primaryError = e;
      if (!shouldFailover(e) || !openRouterKey) {
        return jsonResponse(
          { error: "gemini_failed", detail: String(e) },
          e instanceof ProviderError ? e.status : 502,
        );
      }
    }
  }

  if (!payload && openRouterKey) {
    try {
      payload = await callOpenRouter(openRouterKey, images, body.hint);
      providerUsed = "openrouter";
    } catch (e) {
      return jsonResponse(
        {
          error: "all_providers_failed",
          gemini: primaryError ? String(primaryError) : "not_configured",
          openrouter: String(e),
        },
        e instanceof ProviderError ? e.status : 502,
      );
    }
  }

  if (!payload || !providerUsed) {
    return jsonResponse({ error: "no_provider_configured" }, 500);
  }

  // Camel-case the response to match the Flutter DTO (json_serializable
  // `field_rename: snake` makes Dart camelCase ↔ JSON snake_case).
  return jsonResponse({
    items: payload.items,
    detected_total: payload.detected_total,
    detected_tax: payload.detected_tax,
    detected_service: payload.detected_service,
    merchant: payload.merchant,
    receipt_date: payload.receipt_date,
    confidence: payload.confidence,
    provider_used: providerUsed,
  });
});
