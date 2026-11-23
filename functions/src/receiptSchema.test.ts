import { test } from "node:test";
import assert from "node:assert/strict";
import { parseReceipt, SchemaError } from "./receiptSchema";

test("converts decimals to minor units and normalizes fields", () => {
  const r = parseReceipt({
    merchant: " Cafe ", currency: "pkr", date: "2026-11-01",
    items: [{ name: "Tea", quantity: 2, total: 300.5 }], tax: 48.08, tip: 0, serviceCharge: null, discount: 0, total: 348.58,
  });
  assert.equal(r.merchant, "Cafe");
  assert.equal(r.currency, "PKR");
  assert.deepEqual(r.items, [{ name: "Tea", quantity: 2, totalMinor: 30050 }]);
  assert.equal(r.taxMinor, 4808);
  assert.equal(r.serviceChargeMinor, 0);
  assert.equal(r.totalMinor, 34858);
});

test("respects zero-decimal currencies", () => {
  const r = parseReceipt({ items: [{ name: "Ramen", quantity: 1, total: 980 }], tax: 98, tip: 0, serviceCharge: 0, discount: 0 }, 0);
  assert.equal(r.items[0].totalMinor, 980);
});

test("rejects missing items, negative money and bad names", () => {
  assert.throws(() => parseReceipt({ items: [] }), SchemaError);
  assert.throws(() => parseReceipt({ items: [{ name: "X", quantity: 1, total: -5 }] }), SchemaError);
  assert.throws(() => parseReceipt({ items: [{ name: " ", quantity: 1, total: 5 }] }), SchemaError);
  assert.throws(() => parseReceipt("nope"), SchemaError);
});

test("defaults bad quantity to 1 and drops malformed date/currency", () => {
  const r = parseReceipt({ items: [{ name: "A", quantity: -3, total: 1 }], date: "yesterday", currency: "Rs." });
  assert.equal(r.items[0].quantity, 1);
  assert.equal(r.date, null);
  assert.equal(r.currency, null);
});
