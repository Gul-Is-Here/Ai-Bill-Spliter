import { HttpsError } from "firebase-functions/v2/https";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "./admin";

export const DAILY_LIMITS = { scan: 20, voice: 20 } as const;
export type LimitKind = keyof typeof DAILY_LIMITS;

/** Atomically counts a call against the user's daily quota; throws resource-exhausted when over. */
export async function consumeQuota(uid: string, kind: LimitKind, now = new Date()): Promise<void> {
  const day = now.toISOString().slice(0, 10);
  const ref = db.collection("users").doc(uid).collection("usage").doc(day);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const used = (snap.get(kind) as number | undefined) ?? 0;
    if (used >= DAILY_LIMITS[kind]) {
      throw new HttpsError("resource-exhausted", `Daily ${kind} limit reached.`);
    }
    tx.set(ref, { [kind]: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
  });
}
