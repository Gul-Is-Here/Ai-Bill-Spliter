export type Method = "equal" | "itemwise" | "percentage";

export interface VoiceSplit {
  participants: string[];
  payer: string | null;
  method: Method;
  assignments: { itemIndex: number; names: string[] }[];
  percentages: { name: string; basisPoints: number }[];
}

export const geminiVoiceSchema = {
  type: "OBJECT",
  properties: {
    participants: { type: "ARRAY", items: { type: "STRING" }, description: "Everyone splitting, including the speaker as 'Me'" },
    payer: { type: "STRING", nullable: true },
    method: { type: "STRING", enum: ["equal", "itemwise", "percentage"] },
    assignments: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: { itemIndex: { type: "INTEGER" }, names: { type: "ARRAY", items: { type: "STRING" } } },
        required: ["itemIndex", "names"],
      },
    },
    percentages: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: { name: { type: "STRING" }, percent: { type: "NUMBER" } },
        required: ["name", "percent"],
      },
    },
  },
  required: ["participants", "method", "assignments", "percentages"],
};

export class VoiceSchemaError extends Error {}

const cleanName = (v: unknown): string | null => {
  if (typeof v !== "string") return null;
  const s = v.trim().replace(/\s+/g, " ").slice(0, 40);
  return s.length ? s : null;
};

/** Validates model output against the known item count; names must be in the participant list. */
export function parseVoiceSplit(raw: unknown, itemCount: number): VoiceSplit {
  if (typeof raw !== "object" || raw === null) throw new VoiceSchemaError("root must be an object");
  const r = raw as Record<string, unknown>;
  if (!Array.isArray(r.participants)) throw new VoiceSchemaError("participants must be an array");

  const seen = new Map<string, string>(); // lowercase -> display
  for (const p of r.participants) {
    const n = cleanName(p);
    if (n && !seen.has(n.toLowerCase())) seen.set(n.toLowerCase(), n);
  }
  if (seen.size === 0 || seen.size > 30) throw new VoiceSchemaError("need 1-30 participants");
  const known = (v: unknown) => {
    const n = cleanName(v);
    return n ? seen.get(n.toLowerCase()) ?? null : null;
  };

  const method = r.method;
  if (method !== "equal" && method !== "itemwise" && method !== "percentage") throw new VoiceSchemaError("bad method");

  const assignments: VoiceSplit["assignments"] = [];
  if (Array.isArray(r.assignments)) {
    for (const a of r.assignments) {
      if (typeof a !== "object" || a === null) continue;
      const { itemIndex, names } = a as Record<string, unknown>;
      if (!Number.isInteger(itemIndex) || (itemIndex as number) < 0 || (itemIndex as number) >= itemCount) continue;
      const valid = Array.isArray(names) ? [...new Set(names.map(known).filter((n): n is string => n !== null))] : [];
      if (valid.length) assignments.push({ itemIndex: itemIndex as number, names: valid });
    }
  }

  let percentages: VoiceSplit["percentages"] = [];
  if (method === "percentage") {
    if (!Array.isArray(r.percentages)) throw new VoiceSchemaError("percentages missing");
    for (const p of r.percentages) {
      if (typeof p !== "object" || p === null) continue;
      const { name, percent } = p as Record<string, unknown>;
      const n = known(name);
      if (n && typeof percent === "number" && Number.isFinite(percent) && percent >= 0 && percent <= 100) {
        percentages.push({ name: n, basisPoints: Math.round(percent * 100) });
      }
    }
    const sum = percentages.reduce((s, p) => s + p.basisPoints, 0);
    if (Math.abs(sum - 10000) > 100) throw new VoiceSchemaError("percentages must total 100");
    // Absorb small rounding drift into the first entry so the client gets exactly 100%.
    if (percentages.length) percentages[0].basisPoints += 10000 - sum;
  } else {
    percentages = [];
  }

  return {
    participants: [...seen.values()],
    payer: known(r.payer),
    method: method === "itemwise" && assignments.length === 0 ? "equal" : method,
    assignments: method === "itemwise" ? assignments : [],
    percentages,
  };
}
