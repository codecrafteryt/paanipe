/**
 * Pannipe Cloud Functions
 *
 *  onOrderCreated  – re-computes subtotal (from live product prices) and the
 *                    distance-based delivery fee (from the store's rules), then
 *                    pushes "New order" to the seller.
 *  onOrderUpdated  – pushes status changes to the other party.
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue, GeoPoint } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { setGlobalOptions, logger } from "firebase-functions/v2";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";

initializeApp();
setGlobalOptions({ region: "asia-south1", maxInstances: 10 });

const db = getFirestore();

// ── Delivery fee (must match lib/core/delivery_fee.dart) ──────────────────
function distanceKm(a: GeoPoint, b: GeoPoint): number {
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.latitude - a.latitude);
  const dLng = toRad(b.longitude - a.longitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a.latitude)) *
      Math.cos(toRad(b.latitude)) *
      Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

function deliveryFee(km: number, freeWithinKm: number, chargePerKm: number) {
  if (km <= freeWithinKm) return 0;
  return Math.ceil((km - freeWithinKm) * chargePerKm);
}

const round1 = (n: number) => Math.round(n * 10) / 10;

// ── Push helper ───────────────────────────────────────────────────────────
async function pushToUser(
  uid: string,
  title: string,
  body: string,
  data: Record<string, string>
) {
  const userRef = db.collection("users").doc(uid);
  const snap = await userRef.get();
  const tokens: string[] = snap.get("fcmTokens") ?? [];
  if (tokens.length === 0) return;

  const res = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
    android: {
      priority: "high",
      notification: { channelId: "pannipe_orders", sound: "default" },
    },
    apns: { payload: { aps: { sound: "default" } } },
  });

  // Drop tokens that are no longer valid.
  const dead: string[] = [];
  res.responses.forEach((r, i) => {
    const code = r.error?.code ?? "";
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      dead.push(tokens[i]);
    }
  });
  if (dead.length) {
    await userRef.update({ fcmTokens: FieldValue.arrayRemove(...dead) });
  }
}

const STATUS_TEXT: Record<string, string> = {
  accepted: "accepted your order",
  preparing: "is preparing your order",
  out_for_delivery: "has sent your order out for delivery",
  delivered: "marked your order as delivered. Please confirm you received it.",
  rejected: "could not take your order",
};

// ── Triggers ──────────────────────────────────────────────────────────────
export const onOrderCreated = onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const order = snap.data();
    const orderId = event.params.orderId;

    const storeSnap = await db.collection("stores").doc(order.storeId).get();
    if (!storeSnap.exists) {
      await snap.ref.update({ status: "rejected", cancelReason: "Store not found" });
      return;
    }
    const store = storeSnap.data()!;

    // Re-price items from the catalogue so the client can't tamper.
    let subtotal = 0;
    const items = [];
    for (const item of order.items as Array<Record<string, unknown>>) {
      const p = await storeSnap.ref
        .collection("products")
        .doc(String(item.productId))
        .get();
      const qty = Math.max(1, Math.min(99, Number(item.qty) || 1));
      if (!p.exists || p.get("inStock") !== true) {
        await snap.ref.update({
          status: "rejected",
          cancelReason: `${item.name ?? "An item"} is no longer available`,
        });
        // onOrderUpdated notifies the customer about the rejection.
        return;
      }
      const price = Number(p.get("price"));
      subtotal += price * qty;
      items.push({ ...item, price, qty });
    }

    const km = distanceKm(order.deliveryLocation, store.location);
    const fee = deliveryFee(km, store.freeWithinKm, store.chargePerKm);

    await snap.ref.update({
      items,
      subtotal,
      distanceKm: round1(km),
      deliveryFee: fee,
      total: subtotal + fee,
      verified: true,
    });

    await pushToUser(
      order.storeId,
      "New order 💧",
      `${order.customerName || "A customer"} ordered Rs ${subtotal + fee} (COD)`,
      { orderId, type: "new_order", mode: "seller" }
    );
    logger.info("order verified", { orderId, subtotal, fee });
  }
);

export const onOrderUpdated = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after || before.status === after.status) return;
    const orderId = event.params.orderId;
    const status: string = after.status;

    if (status === "cancelled") {
      await pushToUser(after.storeId, "Order cancelled",
        `${after.customerName || "Customer"} cancelled their order.`,
        { orderId, type: "order_status", mode: "seller" });
    } else if (status === "completed") {
      await pushToUser(after.storeId, "Order completed ✅",
        `${after.customerName || "Customer"} confirmed delivery.`,
        { orderId, type: "order_status", mode: "seller" });
    } else if (STATUS_TEXT[status]) {
      await pushToUser(after.customerId, after.storeName ?? "Pannipe",
        `${after.storeName ?? "The store"} ${STATUS_TEXT[status]}`,
        { orderId, type: "order_status", mode: "customer" });
    }
  }
);

export { sendEmailOtp, verifyEmailOtp } from "./emailOtp";
