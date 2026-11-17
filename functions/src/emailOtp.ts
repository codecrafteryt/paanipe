/**
 * Email one-time-code sign-in (Firebase Auth has no native email OTP).
 *
 *   sendEmailOtp({ email })          → emails a 6-digit code
 *   verifyEmailOtp({ email, code })  → { token } custom token for signInWithCustomToken
 *
 * Security
 *  - Only a salted SHA-256 hash of the code is stored, in `emailOtps/{sha256(email)}`
 *    (no client access: firestore.rules has no match for this collection).
 *  - Code expires after 10 min; 5 wrong attempts burns it; success deletes it (no replay).
 *  - Resend cooldown 60 s and max 5 codes per email per hour.
 *  - Constant-time comparison; email normalised (trim + lowercase) and validated.
 */
import { createHash, randomBytes, randomInt, timingSafeEqual } from "crypto";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { defineSecret, defineString } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import * as nodemailer from "nodemailer";

const SMTP_HOST = defineString("SMTP_HOST", { default: "smtp.gmail.com" });
const SMTP_PORT = defineString("SMTP_PORT", { default: "465" });
const MAIL_FROM = defineString("MAIL_FROM", { default: "Pannipe <no-reply@pannipe.app>" });
const SMTP_USER = defineSecret("SMTP_USER");
const SMTP_PASS = defineSecret("SMTP_PASS");

const CODE_TTL_MS = 10 * 60 * 1000;
const RESEND_COOLDOWN_MS = 60 * 1000;
const MAX_SENDS_PER_HOUR = 5;
const MAX_ATTEMPTS = 5;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

const sha256 = (s: string) => createHash("sha256").update(s).digest("hex");
const otpDoc = (email: string) => getFirestore().collection("emailOtps").doc(sha256(email));

function normalizeEmail(raw: unknown): string {
  const email = typeof raw === "string" ? raw.trim().toLowerCase() : "";
  if (email.length > 254 || !EMAIL_RE.test(email)) {
    throw new HttpsError("invalid-argument", "Enter a valid email address.");
  }
  return email;
}

export const sendEmailOtp = onCall({ secrets: [SMTP_USER, SMTP_PASS] }, async (req) => {
  const email = normalizeEmail(req.data?.email);
  const ref = otpDoc(email);
  const now = Date.now();

  const snap = await ref.get();
  const prev = snap.data();
  const windowStart: number = prev?.windowStart?.toMillis?.() ?? 0;
  const inWindow = now - windowStart < 60 * 60 * 1000;
  const sends: number = inWindow ? prev?.sends ?? 0 : 0;
  if (prev && now - (prev.lastSentAt?.toMillis?.() ?? 0) < RESEND_COOLDOWN_MS) {
    throw new HttpsError("resource-exhausted", "Please wait a minute before requesting a new code.");
  }
  if (sends >= MAX_SENDS_PER_HOUR) {
    throw new HttpsError("resource-exhausted", "Too many codes requested. Try again in an hour.");
  }

  const code = randomInt(0, 1_000_000).toString().padStart(6, "0");
  const salt = randomBytes(16).toString("hex");

  await nodemailer
    .createTransport({
      host: SMTP_HOST.value(),
      port: Number(SMTP_PORT.value()),
      secure: Number(SMTP_PORT.value()) === 465,
      auth: { user: SMTP_USER.value(), pass: SMTP_PASS.value() },
    })
    .sendMail({
      from: MAIL_FROM.value(),
      to: email,
      subject: `${code} is your Pannipe code`,
      text: `Your Pannipe sign-in code is ${code}. It expires in 10 minutes. If you didn't request it, ignore this email.`,
      html: `<p>Your Pannipe sign-in code is</p><p style="font-size:28px;font-weight:700;letter-spacing:6px">${code}</p><p>It expires in 10 minutes. If you didn't request it, you can ignore this email.</p>`,
    })
    .catch((e) => {
      logger.error("sendMail failed", e);
      throw new HttpsError("unavailable", "Could not send the email. Try again shortly.");
    });

  await ref.set({
    codeHash: sha256(salt + code),
    salt,
    attempts: 0,
    expiresAt: Timestamp.fromMillis(now + CODE_TTL_MS),
    lastSentAt: Timestamp.fromMillis(now),
    windowStart: inWindow ? Timestamp.fromMillis(windowStart) : Timestamp.fromMillis(now),
    sends: sends + 1,
  });
  return { sent: true };
});

export const verifyEmailOtp = onCall(async (req) => {
  const email = normalizeEmail(req.data?.email);
  const code = typeof req.data?.code === "string" ? req.data.code.trim() : "";
  if (!/^\d{6}$/.test(code)) throw new HttpsError("invalid-argument", "Enter the 6-digit code.");

  const ref = otpDoc(email);
  const ok = await getFirestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const d = snap.data();
    if (!d || !d.codeHash) throw new HttpsError("not-found", "Request a new code.");
    if (d.expiresAt.toMillis() < Date.now()) {
      tx.update(ref, { codeHash: null });
      throw new HttpsError("deadline-exceeded", "This code has expired. Request a new one.");
    }
    const match = timingSafeEqual(Buffer.from(sha256(d.salt + code)), Buffer.from(d.codeHash));
    if (match) {
      tx.delete(ref); // single use
      return true;
    }
    const attempts = (d.attempts ?? 0) + 1;
    tx.update(ref, attempts >= MAX_ATTEMPTS ? { codeHash: null, attempts } : { attempts });
    return false;
  });
  if (!ok) throw new HttpsError("permission-denied", "Wrong code. Please check and try again.");

  const auth = getAuth();
  const user = await auth.getUserByEmail(email).catch(() => auth.createUser({ email, emailVerified: true }));
  if (user.disabled) throw new HttpsError("permission-denied", "This account has been disabled.");
  if (!user.emailVerified) await auth.updateUser(user.uid, { emailVerified: true });
  return { token: await auth.createCustomToken(user.uid) };
});
