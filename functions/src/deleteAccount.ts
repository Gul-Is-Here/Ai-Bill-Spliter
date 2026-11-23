import { HttpsError, onCall } from "firebase-functions/v2/https";
import { auth, bucket, db } from "./admin";

/** Deletes every trace of the caller: Firestore subtree, Storage files, Auth user. */
export const deleteAccount = onCall({ enforceAppCheck: true, region: "us-central1" }, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  await db.recursiveDelete(db.collection("users").doc(uid));
  await bucket().deleteFiles({ prefix: `users/${uid}/` });
  await auth.deleteUser(uid);
  return { ok: true };
});
