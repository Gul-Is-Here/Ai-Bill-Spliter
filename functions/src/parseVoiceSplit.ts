import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { generateJson } from "./gemini";
import { consumeQuota } from "./rateLimit";
import { geminiVoiceSchema, parseVoiceSplit as validate, VoiceSchemaError } from "./voiceSchema";

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

export const parseVoiceSplit = onCall(
  { enforceAppCheck: true, secrets: [GEMINI_API_KEY], timeoutSeconds: 30, region: "us-central1" },
  async (req) => {
    const uid = req.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

    const transcript = req.data?.transcript;
    const items = req.data?.items;
    if (typeof transcript !== "string" || transcript.trim().length < 3 || transcript.length > 2000) {
      throw new HttpsError("invalid-argument", "Transcript must be 3-2000 characters.");
    }
    if (!Array.isArray(items) || items.length > 200 || !items.every((i) => typeof i === "string" && i.length <= 120)) {
      throw new HttpsError("invalid-argument", "Invalid items.");
    }

    await consumeQuota(uid, "voice");

    const itemList = items.map((name: string, i: number) => `${i}: ${name}`).join("\n") || "(no items)";
    const prompt = `A user describes how to split a bill. The speech may be English, Urdu, or Roman Urdu.
Bill items (index: name):
${itemList}

Rules: list every person mentioned; the speaker is "Me". Use "itemwise" if they say who had which item,
"percentage" if they give percentages or shares that sum to 100, otherwise "equal". Match item references
to the closest index. "payer" is who paid, if said.

Transcript: """${transcript.trim()}"""`;

    const raw = await generateJson(GEMINI_API_KEY.value(), [{ text: prompt }], geminiVoiceSchema);
    try {
      return validate(raw, items.length);
    } catch (e) {
      if (e instanceof VoiceSchemaError) throw new HttpsError("failed-precondition", `Could not understand: ${e.message}`);
      throw e;
    }
  },
);
