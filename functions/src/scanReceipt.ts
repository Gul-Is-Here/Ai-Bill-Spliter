import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { bucket } from "./admin";
import { generateJson } from "./gemini";
import { consumeQuota } from "./rateLimit";
import { geminiReceiptSchema, parseReceipt, SchemaError } from "./receiptSchema";

const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const MAX_BYTES = 2 * 1024 * 1024;

const PROMPT = `You read restaurant and shop receipts. Extract every purchased line item exactly as printed.
Use the line total (quantity x unit price) for "total". Put tax/GST/VAT in "tax", tips in "tip",
service charges in "serviceCharge", and bill-level discounts (positive number) in "discount".
Do not include subtotal, total, tax, or payment lines as items. Use 0 when a field is absent.`;

export const scanReceipt = onCall(
  // App Check not enforced here by product decision; sign-in + daily quota + own-folder path check still apply.
  { enforceAppCheck: false, secrets: [GEMINI_API_KEY], timeoutSeconds: 60, memory: "512MiB", region: "us-central1" },
  async (req) => {
    const uid = req.auth?.uid;
    if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

    const path = req.data?.imagePath;
    const digits = req.data?.fractionDigits;
    if (typeof path !== "string" || !path.startsWith(`users/${uid}/receipts/`) || path.includes("..")) {
      throw new HttpsError("invalid-argument", "Invalid image path.");
    }
    const fractionDigits = Number.isInteger(digits) && digits >= 0 && digits <= 3 ? (digits as number) : 2;

    await consumeQuota(uid, "scan");

    const file = bucket().file(path);
    const [meta] = await file.getMetadata().catch(() => {
      throw new HttpsError("not-found", "Image not found.");
    });
    if (Number(meta.size) > MAX_BYTES) throw new HttpsError("invalid-argument", "Image too large.");
    const [bytes] = await file.download();

    const raw = await generateJson(
      GEMINI_API_KEY.value(),
      [{ text: PROMPT }, { inlineData: { mimeType: meta.contentType ?? "image/jpeg", data: bytes.toString("base64") } }],
      geminiReceiptSchema,
    );
    try {
      return parseReceipt(raw, fractionDigits);
    } catch (e) {
      if (e instanceof SchemaError) throw new HttpsError("failed-precondition", `Unreadable receipt: ${e.message}`);
      throw e;
    }
  },
);
