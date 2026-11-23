import { HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";

const MODEL = "gemini-2.5-flash";

type Part = { text: string } | { inlineData: { mimeType: string; data: string } };

/** Calls Gemini with structured JSON output and returns the parsed (unvalidated) JSON. */
export async function generateJson(apiKey: string, parts: Part[], schema: object): Promise<unknown> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
    signal: AbortSignal.timeout(45_000),
    body: JSON.stringify({
      contents: [{ role: "user", parts }],
      generationConfig: { temperature: 0, responseMimeType: "application/json", responseSchema: schema },
    }),
  });
  if (!res.ok) {
    logger.error("Gemini error", { status: res.status, body: (await res.text()).slice(0, 500) });
    throw new HttpsError(res.status === 429 ? "resource-exhausted" : "unavailable", "AI service unavailable.");
  }
  const body = (await res.json()) as { candidates?: { content?: { parts?: { text?: string }[] } }[] };
  const text = body.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new HttpsError("failed-precondition", "Empty AI response.");
  try {
    return JSON.parse(text);
  } catch {
    throw new HttpsError("failed-precondition", "AI returned invalid JSON.");
  }
}
