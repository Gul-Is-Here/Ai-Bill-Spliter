/** Shape returned to the app. Money is integer minor units (e.g. paisa/cents). */
export interface ReceiptItem {
  name: string;
  quantity: number;
  totalMinor: number;
}

export interface Receipt {
  merchant: string | null;
  date: string | null;
  currency: string | null;
  items: ReceiptItem[];
  taxMinor: number;
  tipMinor: number;
  serviceChargeMinor: number;
  discountMinor: number;
  totalMinor: number | null;
}

/** JSON schema handed to Gemini's structured output (amounts as decimals in major units). */
export const geminiReceiptSchema = {
  type: "OBJECT",
  properties: {
    merchant: { type: "STRING", nullable: true },
    date: { type: "STRING", nullable: true, description: "ISO date YYYY-MM-DD if visible" },
    currency: { type: "STRING", nullable: true, description: "ISO 4217 code, e.g. PKR, USD" },
    items: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          name: { type: "STRING" },
          quantity: { type: "NUMBER" },
          total: { type: "NUMBER", description: "Line total for all units, after any line discount" },
        },
        required: ["name", "quantity", "total"],
      },
    },
    tax: { type: "NUMBER" },
    tip: { type: "NUMBER" },
    serviceCharge: { type: "NUMBER" },
    discount: { type: "NUMBER", description: "Bill-level discount as a positive number" },
    total: { type: "NUMBER", nullable: true },
  },
  required: ["items", "tax", "tip", "serviceCharge", "discount"],
};

export class SchemaError extends Error {}

const MAX_ITEMS = 200;
const MAX_AMOUNT_MINOR = 1_000_000_000_00; // 1 billion major units

function isObj(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

function money(v: unknown, field: string, digits: number): number {
  if (v === undefined || v === null) return 0;
  if (typeof v !== "number" || !Number.isFinite(v) || v < 0) throw new SchemaError(`${field} must be a non-negative number`);
  const minor = Math.round(v * 10 ** digits);
  if (minor > MAX_AMOUNT_MINOR) throw new SchemaError(`${field} is too large`);
  return minor;
}

function optString(v: unknown, max: number): string | null {
  if (typeof v !== "string") return null;
  const s = v.trim().slice(0, max);
  return s.length ? s : null;
}

/** Validates raw model output and converts it to minor units. Throws SchemaError on anything unusable. */
export function parseReceipt(raw: unknown, digits = 2): Receipt {
  if (!isObj(raw)) throw new SchemaError("root must be an object");
  if (!Array.isArray(raw.items)) throw new SchemaError("items must be an array");
  if (raw.items.length === 0) throw new SchemaError("no items found");
  if (raw.items.length > MAX_ITEMS) throw new SchemaError("too many items");

  const items = raw.items.map((it, i): ReceiptItem => {
    if (!isObj(it)) throw new SchemaError(`items[${i}] must be an object`);
    const name = optString(it.name, 120);
    if (!name) throw new SchemaError(`items[${i}].name missing`);
    const q = typeof it.quantity === "number" && Number.isFinite(it.quantity) && it.quantity > 0 ? it.quantity : 1;
    return { name, quantity: Math.min(Math.round(q * 1000) / 1000, 10_000), totalMinor: money(it.total, `items[${i}].total`, digits) };
  });

  const currency = optString(raw.currency, 3);
  const date = optString(raw.date, 10);
  return {
    merchant: optString(raw.merchant, 120),
    date: date && /^\d{4}-\d{2}-\d{2}$/.test(date) ? date : null,
    currency: currency && /^[A-Z]{3}$/.test(currency.toUpperCase()) ? currency.toUpperCase() : null,
    items,
    taxMinor: money(raw.tax, "tax", digits),
    tipMinor: money(raw.tip, "tip", digits),
    serviceChargeMinor: money(raw.serviceCharge, "serviceCharge", digits),
    discountMinor: money(raw.discount, "discount", digits),
    totalMinor: raw.total === null || raw.total === undefined ? null : money(raw.total, "total", digits),
  };
}
