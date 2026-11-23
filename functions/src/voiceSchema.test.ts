import { test } from "node:test";
import assert from "node:assert/strict";
import { parseVoiceSplit, VoiceSchemaError } from "./voiceSchema";

test("itemwise: dedupes names, drops unknown names and out-of-range items", () => {
  const r = parseVoiceSplit(
    {
      participants: ["Ali", "ali ", "Sara", "Me"],
      payer: "sara",
      method: "itemwise",
      assignments: [
        { itemIndex: 0, names: ["Ali", "Ghost"] },
        { itemIndex: 1, names: ["Sara", "Me", "sara"] },
        { itemIndex: 9, names: ["Ali"] },
      ],
      percentages: [],
    },
    2,
  );
  assert.deepEqual(r.participants, ["Ali", "Sara", "Me"]);
  assert.equal(r.payer, "Sara");
  assert.deepEqual(r.assignments, [
    { itemIndex: 0, names: ["Ali"] },
    { itemIndex: 1, names: ["Sara", "Me"] },
  ]);
});

test("percentage: converts to basis points and fixes rounding drift to exactly 100%", () => {
  const r = parseVoiceSplit(
    { participants: ["A", "B", "C"], method: "percentage", assignments: [], percentages: [
      { name: "A", percent: 33.33 }, { name: "B", percent: 33.33 }, { name: "C", percent: 33.33 },
    ] },
    0,
  );
  assert.equal(r.percentages.reduce((s, p) => s + p.basisPoints, 0), 10000);
});

test("rejects percentages far from 100 and empty participants", () => {
  assert.throws(() => parseVoiceSplit({ participants: ["A", "B"], method: "percentage", assignments: [],
    percentages: [{ name: "A", percent: 50 }, { name: "B", percent: 20 }] }, 0), VoiceSchemaError);
  assert.throws(() => parseVoiceSplit({ participants: [], method: "equal", assignments: [], percentages: [] }, 0), VoiceSchemaError);
  assert.throws(() => parseVoiceSplit({ participants: ["A"], method: "weird", assignments: [], percentages: [] }, 0), VoiceSchemaError);
});

test("itemwise with no usable assignments falls back to equal", () => {
  const r = parseVoiceSplit({ participants: ["A", "B"], method: "itemwise", assignments: [{ itemIndex: 5, names: ["A"] }], percentages: [] }, 1);
  assert.equal(r.method, "equal");
  assert.deepEqual(r.assignments, []);
});
