const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const https = require("https");

admin.initializeApp();
const db = admin.firestore();

const PASS_PRICES = {
  trial3Day: { title: "3-Day Starter Pass", days: 3, price: 165, expiryDays: 5 },
  routine7Day: { title: "7-Day Routine Pass", days: 7, price: 350, expiryDays: 10 },
  power15Day: { title: "15-Day Power Pass", days: 15, price: 720, expiryDays: 20 },
};

const KHAMMAM_SPECIALTIES = [
  "Rayalaseema Set Dosa & Coconut Chutney",
  "Steaming Ghee Thatte Idlis + Medu Vada",
  "Homestyle Poori Masala (Amma Chethi Vanta)",
  "MLA Pesarattu Upma & Ginger Pachadi",
  "Crisp Mysore Bonda & Drumstick Sambar",
  "Karnataka Udupi Ghee Roast Dosa",
];

function getNowIst() {
  const utcNow = new Date();
  return new Date(utcNow.getTime() + 5.5 * 60 * 60 * 1000);
}

function getTargetDeliveryDateIst() {
  const ist = getNowIst();
  const isAfterCutoff = ist.getUTCHours() >= 21;
  const daysToAdd = isAfterCutoff ? 2 : 1;
  return new Date(Date.UTC(ist.getUTCFullYear(), ist.getUTCMonth(), ist.getUTCDate() + daysToAdd, 2, 0, 0));
}

async function requireAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }
  if (context.auth.token && context.auth.token.role === "admin") return;
  const userDoc = await db.collection("users").doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data().role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Admin privileges required.");
  }
}

async function commitInChunks(operations, chunkSize = 450) {
  for (let i = 0; i < operations.length; i += chunkSize) {
    const chunk = operations.slice(i, i + chunkSize);
    const batch = db.batch();
    chunk.forEach((fn) => fn(batch));
    await batch.commit();
  }
}

async function sendMulticastChunked(tokens, payload) {
  const uniqueTokens = [...new Set(tokens.filter(Boolean))];
  let totalSuccess = 0;
  for (let i = 0; i < uniqueTokens.length; i += 500) {
    const chunk = uniqueTokens.slice(i, i + 500);
    const res = await admin.messaging().sendEachForMulticast({
      tokens: chunk,
      ...payload,
    });
    totalSuccess += res.successCount;
  }
  return totalSuccess;
}

function createRazorpayOrderApi(keyId, keySecret, amountInPaise, receipt) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({
      amount: amountInPaise,
      currency: "INR",
      receipt,
      payment_capture: 1,
    });
    const authHeader = "Basic " + Buffer.from(`${keyId}:${keySecret}`).toString("base64");
    const req = https.request(
      {
        hostname: "api.razorpay.com",
        path: "/v1/orders",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body),
          Authorization: authHeader,
        },
      },
      (res) => {
        let raw = "";
        res.on("data", (d) => (raw += d));
        res.on("end", () => {
          try {
            const parsed = JSON.parse(raw);
            if (res.statusCode >= 200 && res.statusCode < 300 && parsed.id) {
              resolve(parsed);
            } else {
              reject(new Error(parsed.error ? parsed.error.description : `Razorpay HTTP ${res.statusCode}`));
            }
          } catch (e) {
            reject(e);
          }
        });
      }
    );
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

/**
 * 1. createOrderIntent (Callable)
 * Computes authoritative server-side totals (food + delivery fee - verified coupon),
 * creates a Razorpay Order on the server, and stores a pending payment intent.
 */
exports.createOrderIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Please sign in to place an order.");
  }

  const {
    orderMode = "singleDay",
    tierKey = "routine7Day",
    kitchenId,
    itemQuantities = {},
    appliedCoupon,
    clusterId = "cluster_01",
    clusterName = "Hostel Security Gate",
    deliverySlot = "07:30 AM – 08:00 AM",
    deliveryInstructions = "",
    paymentMethod = "Google Pay",
    comboSelection = "A",
    autoRotatePassMenu = true,
    customerName = "Hungr Customer",
    phoneNumber = "",
  } = data || {};

  // Fetch Razorpay server credentials from server-only /secrets/payments
  const secretDoc = await db.collection("secrets").doc("payments").get();
  const publicCfgDoc = await db.collection("config").doc("payments").get();
  const razorpayKeyId =
    (secretDoc.exists && secretDoc.data().razorpayKeyId) ||
    (publicCfgDoc.exists && publicCfgDoc.data().razorpayKeyId) ||
    "";
  const razorpayKeySecret = (secretDoc.exists && secretDoc.data().razorpayKeySecret) || "";

  if (!razorpayKeyId || !razorpayKeySecret) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "PAYMENT_NOT_CONFIGURED: Razorpay server credentials are not configured yet."
    );
  }

  // Compute server-side item prices from live Firestore catalog
  let itemsSubtotal = 0;
  const itemDetails = [];
  const priceMap = {};
  const nameMap = {};
  let resolvedKitchenName = "Hungr Partner Kitchen";

  const shopsSnap = await db.collection("tiffin_shops").get();
  shopsSnap.forEach((doc) => {
    const s = doc.data();
    if (kitchenId && doc.id === kitchenId && s.name) {
      resolvedKitchenName = s.name;
    }
    const dishes = s.menuItems || s.dishes || [];
    dishes.forEach((d) => {
      if (d && d.id) {
        priceMap[d.id] = Number(d.price) || 49;
        nameMap[d.id] = d.name || "Morning Tiffin";
      }
    });
  });

  // Fallback standard catalog prices if Firestore catalog hasn't been seeded yet
  const fallbackCatalog = {
    item_set_dosa: { name: "Rayalaseema Set Dosa (3 Pcs)", price: 49 },
    item_idli_vada: { name: "Steaming Ghee Idlis (4 Pcs) + Medu Vada (1 Pc)", price: 49 },
    item_poori_masala: { name: "Homestyle Poori Masala (3 Pcs)", price: 55 },
    item_mysore_bonda: { name: "Crisp Mysore Bonda (4 Pcs)", price: 45 },
    item_upma_pesarattu: { name: "MLA Pesarattu Upma", price: 55 },
    addon_boiled_eggs: { name: "Farm Boiled Eggs (2 Pcs)", price: 20 },
    addon_filter_coffee: { name: "Kumbakonam Degree Filter Coffee (200ml)", price: 25 },
    addon_badam_milk: { name: "Steaming Kesari Badam Milk (200ml)", price: 25 },
  };

  for (const [id, rawQty] of Object.entries(itemQuantities || {})) {
    const qty = Math.max(0, Math.min(20, parseInt(rawQty, 10) || 0));
    if (qty <= 0) continue;
    const unitPrice = priceMap[id] || (fallbackCatalog[id] && fallbackCatalog[id].price) || 49;
    const itemName = nameMap[id] || (fallbackCatalog[id] && fallbackCatalog[id].name) || id;
    itemsSubtotal += unitPrice * qty;
    itemDetails.push({ id, name: itemName, price: unitPrice, qty });
  }

  let baseSubtotal = itemsSubtotal;
  let passInfo = null;
  if (orderMode === "subscriptionPass") {
    passInfo = PASS_PRICES[tierKey] || PASS_PRICES.routine7Day;
    baseSubtotal += passInfo.price;
  } else if (itemDetails.length === 0) {
    throw new functions.https.HttpsError("invalid-argument", "Cart is empty.");
  }

  // Unit-economics protection: ₹15 gate drop fee on single-day orders under ₹149
  const deliveryFee = orderMode === "singleDay" && itemsSubtotal < 149 ? 15 : 0;

  // Validate coupon against live Firestore offers
  let discountAmount = 0;
  let validCoupon = null;
  if (appliedCoupon) {
    const code = String(appliedCoupon).trim().toUpperCase();
    const offersSnap = await db.collection("offers").where("code", "==", code).where("isActive", "==", true).limit(1).get();
    let offer = null;
    if (!offersSnap.empty) {
      offer = offersSnap.docs[0].data();
    } else if (code === "FIRST50") {
      offer = { code: "FIRST50", type: "flat", value: 50, minOrder: 99 };
    } else if (code === "HUNGRFREE") {
      offer = { code: "HUNGRFREE", type: "flat", value: 25, minOrder: 49 };
    }

    if (offer && baseSubtotal >= (Number(offer.minOrder) || 0)) {
      validCoupon = offer.code;
      if (offer.type === "percentage") {
        discountAmount = Math.min(baseSubtotal, Math.round((baseSubtotal * Number(offer.value || 0)) / 100));
      } else {
        discountAmount = Math.min(baseSubtotal, Number(offer.value || 0));
      }
    }
  }

  const totalAmount = Math.max(1, baseSubtotal + deliveryFee - discountAmount);
  const intentRef = db.collection("payment_intents").doc();

  const rzpOrder = await createRazorpayOrderApi(
    razorpayKeyId,
    razorpayKeySecret,
    totalAmount * 100,
    `hng_${intentRef.id.slice(0, 12)}`
  );

  await intentRef.set({
    intentId: intentRef.id,
    razorpayOrderId: rzpOrder.id,
    userId: context.auth.uid,
    phoneNumber: context.auth.token.phone_number || phoneNumber,
    customerName,
    orderMode,
    tierKey: passInfo ? tierKey : null,
    tier: passInfo ? passInfo.title : null,
    days: passInfo ? passInfo.days : 1,
    expiryDays: passInfo ? passInfo.expiryDays : 2,
    kitchenId: kitchenId || null,
    kitchenName: resolvedKitchenName,
    itemQuantities,
    itemDetails,
    deliveryFee,
    discountAmount,
    appliedCoupon: validCoupon,
    totalAmount,
    clusterId,
    clusterName,
    deliverySlot,
    deliveryInstructions,
    paymentMethod,
    comboSelection,
    autoRotatePassMenu,
    status: "PENDING",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    intentId: intentRef.id,
    razorpayOrderId: rzpOrder.id,
    razorpayKeyId,
    amountInPaise: totalAmount * 100,
    totalAmount,
    deliveryFee,
    discountAmount,
  };
});

/**
 * 2. verifyAndCreateOrder (Callable)
 * Verifies Razorpay HMAC-SHA256 signature and atomically creates verified order, pass, and tickets.
 */
exports.verifyAndCreateOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  }

  const { intentId, razorpayOrderId, razorpayPaymentId, razorpaySignature } = data || {};
  if (!intentId || !razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
    throw new functions.https.HttpsError("invalid-argument", "Missing payment verification fields.");
  }

  const secretDoc = await db.collection("secrets").doc("payments").get();
  const keySecret = secretDoc.exists ? secretDoc.data().razorpayKeySecret : null;
  if (!keySecret) {
    throw new functions.https.HttpsError("failed-precondition", "Payment secret missing.");
  }

  const expectedSignature = crypto
    .createHmac("sha256", keySecret)
    .update(`${razorpayOrderId}|${razorpayPaymentId}`)
    .digest("hex");

  if (expectedSignature !== razorpaySignature) {
    throw new functions.https.HttpsError("permission-denied", "Invalid Razorpay payment signature.");
  }

  const intentRef = db.collection("payment_intents").doc(intentId);
  const intentSnap = await intentRef.get();
  if (!intentSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Payment intent not found.");
  }
  const intent = intentSnap.data();
  if (intent.userId !== context.auth.uid) {
    throw new functions.https.HttpsError("permission-denied", "Not authorized for this intent.");
  }
  if (intent.status === "PAID" && intent.orderId) {
    return { success: true, orderId: intent.orderId, bagToken: intent.bagToken };
  }

  const startDate = getTargetDeliveryDateIst();
  const prefixWords = String(intent.clusterName || "HNG")
    .split(/\s+/)
    .filter(Boolean);
  const prefix =
    prefixWords.length >= 2
      ? (prefixWords[0][0] + prefixWords[1][0]).toUpperCase()
      : String(intent.clusterName || "HN").slice(0, 2).toUpperCase();
  const bagToken = `#${prefix}-${String(Math.floor(10 + Math.random() * 89))}`;

  const orderRef = db.collection("orders").doc();
  const batch = db.batch();

  batch.set(orderRef, {
    orderId: orderRef.id,
    userId: context.auth.uid,
    phoneNumber: intent.phoneNumber || "",
    customerName: intent.customerName || "Hungr Customer",
    orderMode: intent.orderMode,
    tier: intent.tier,
    tierKey: intent.tierKey,
    days: intent.days,
    kitchenId: intent.kitchenId,
    kitchenName: intent.kitchenName,
    items: intent.itemQuantities,
    itemDetails: intent.itemDetails,
    deliveryFee: intent.deliveryFee || 0,
    discountAmount: intent.discountAmount || 0,
    appliedCoupon: intent.appliedCoupon || null,
    totalAmount: intent.totalAmount,
    clusterId: intent.clusterId,
    clusterName: intent.clusterName,
    bagToken,
    deliverySlot: intent.deliverySlot,
    deliveryInstructions: intent.deliveryInstructions || "",
    paymentMethod: intent.paymentMethod || "Razorpay UPI",
    razorpayOrderId,
    razorpayPaymentId,
    status: "CONFIRMED",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdAtMs: Date.now(),
  });

  let passId = null;
  if (intent.orderMode === "subscriptionPass" && intent.days > 0) {
    const passRef = db.collection("passes").doc();
    passId = passRef.id;
    const hardExpiry = new Date(startDate.getTime() + (intent.expiryDays || intent.days + 5) * 86400000);
    batch.set(passRef, {
      passId,
      orderId: orderRef.id,
      userId: context.auth.uid,
      phoneNumber: intent.phoneNumber || "",
      tier: intent.tier,
      tierKey: intent.tierKey || "routine7Day",
      totalDays: intent.days,
      remainingDays: intent.days,
      clusterId: intent.clusterId,
      clusterName: intent.clusterName,
      bagToken,
      comboSelection: intent.comboSelection || "A",
      status: "ACTIVE",
      hardExpiryDate: hardExpiry.toISOString(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAtMs: Date.now(),
    });
  }

  const ticketCount = intent.orderMode === "subscriptionPass" ? intent.days : 1;
  for (let i = 0; i < ticketCount; i++) {
    const ticketRef = db.collection("meal_tickets").doc();
    const ticketDate = new Date(startDate.getTime() + i * 86400000);
    const ticketCombo = i === 0 ? intent.comboSelection : i % 2 === 0 ? intent.comboSelection : intent.comboSelection === "A" ? "B" : "A";
    const summaryName =
      intent.orderMode === "singleDay"
        ? (intent.itemDetails || []).map((e) => `${e.qty}x ${e.name}`).join(", ")
        : intent.autoRotatePassMenu
        ? KHAMMAM_SPECIALTIES[i % KHAMMAM_SPECIALTIES.length]
        : ticketCombo === "A"
        ? "Hot Set Dosa Combo"
        : "Steamed Idli + Vada Combo";

    batch.set(ticketRef, {
      ticketId: ticketRef.id,
      orderId: orderRef.id,
      passId: passId || `single_${orderRef.id}`,
      userId: context.auth.uid,
      phoneNumber: intent.phoneNumber || "",
      clusterId: intent.clusterId,
      clusterName: intent.clusterName,
      bagToken,
      deliveryDateIso: ticketDate.toISOString(),
      comboSelection: ticketCombo,
      addOns: Object.keys(intent.itemQuantities || {}),
      specialtyName: summaryName,
      slot: String(intent.deliverySlot || "").includes("08:00") ? "MORNING_0800" : "MORNING_0730",
      status: "SCHEDULED",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  batch.update(intentRef, {
    status: "PAID",
    orderId: orderRef.id,
    bagToken,
    razorpayPaymentId,
    paidAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();
  return { success: true, orderId: orderRef.id, bagToken };
});

/**
 * 3. skipMealTicket (Callable)
 * Enforces 21:00 IST cutoff, pass expiry ceiling, and appends a replacement ticket atomically.
 */
exports.skipMealTicket = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
  }

  const { ticketId } = data || {};
  if (!ticketId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing ticketId.");
  }

  const istNow = getNowIst();
  if (istNow.getUTCHours() >= 21) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "403_CUTOFF_EXCEEDED: Cannot pause tomorrow's meal after 9:00 PM IST."
    );
  }

  const ticketRef = db.collection("meal_tickets").doc(ticketId);
  const ticketDoc = await ticketRef.get();
  if (!ticketDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Ticket does not exist.");
  }

  const ticket = ticketDoc.data();
  if (ticket.userId !== context.auth.uid) {
    throw new functions.https.HttpsError("permission-denied", "Not your ticket.");
  }
  if (ticket.status !== "SCHEDULED") {
    throw new functions.https.HttpsError("failed-precondition", `Cannot pause ticket with status: ${ticket.status}`);
  }

  const passDoc = await db.collection("passes").doc(ticket.passId).get();
  if (!passDoc.exists) {
    throw new functions.https.HttpsError("failed-precondition", "Only multi-day Pass meals can be paused and rolled over.");
  }
  const pass = passDoc.data();
  const hardExpiryDate = new Date(pass.hardExpiryDate);

  const userTicketsSnap = await db
    .collection("meal_tickets")
    .where("userId", "==", context.auth.uid)
    .where("status", "==", "SCHEDULED")
    .orderBy("deliveryDateIso", "desc")
    .limit(1)
    .get();

  let lastScheduledDate = new Date(ticket.deliveryDateIso || ticket.deliveryDate);
  if (!userTicketsSnap.empty) {
    const tail = userTicketsSnap.docs[0].data();
    lastScheduledDate = new Date(tail.deliveryDateIso || tail.deliveryDate);
  }

  const candidateAppendDate = new Date(lastScheduledDate.getTime() + 86400000);
  if (candidateAppendDate.getTime() > hardExpiryDate.getTime()) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Pass validity ceiling (${hardExpiryDate.toDateString()}) reached.`
    );
  }

  const newTicketRef = db.collection("meal_tickets").doc();
  await db.runTransaction(async (transaction) => {
    transaction.update(ticketRef, {
      status: "SKIPPED",
      skippedAt: admin.firestore.FieldValue.serverTimestamp(),
      rescheduledToTicketId: newTicketRef.id,
    });

    transaction.set(newTicketRef, {
      ticketId: newTicketRef.id,
      orderId: ticket.orderId || null,
      passId: ticket.passId,
      userId: ticket.userId,
      phoneNumber: ticket.phoneNumber || "",
      clusterId: ticket.clusterId,
      clusterName: ticket.clusterName,
      bagToken: ticket.bagToken,
      deliveryDateIso: candidateAppendDate.toISOString(),
      comboSelection: ticket.comboSelection,
      addOns: ticket.addOns || [],
      specialtyName: ticket.specialtyName || null,
      slot: ticket.slot || "MORNING_0730",
      status: "SCHEDULED",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {
    success: true,
    newScheduledDate: candidateAppendDate.toISOString(),
    newTicketId: newTicketRef.id,
  };
});

/**
 * 4. autoAggregateKitchenSplit (Scheduled daily at 21:01 IST)
 * Scales cleanly past 500+ orders using chunked 450-op Firestore batches.
 */
exports.autoAggregateKitchenSplit = functions.pubsub
  .schedule("31 15 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const istNow = getNowIst();
    const tomorrow = new Date(istNow.getTime() + 86400000);
    const tomorrowStr = tomorrow.toISOString().split("T")[0];

    const ticketsSnap = await db
      .collection("meal_tickets")
      .where("deliveryDateIso", ">=", `${tomorrowStr}T00:00:00`)
      .where("deliveryDateIso", "<=", `${tomorrowStr}T23:59:59`)
      .where("status", "==", "SCHEDULED")
      .get();

    if (ticketsSnap.empty) return null;

    const shopsSnap = await db.collection("tiffin_shops").where("status", "==", "open").get();
    const openKitchenIds = shopsSnap.empty ? ["shop_venkateshwara", "shop_amma_chethi"] : shopsSnap.docs.map((d) => d.id);

    const ops = [];
    const kitchenCounts = {};
    openKitchenIds.forEach((id) => (kitchenCounts[id] = { total: 0, optionA: 0, optionB: 0 }));

    ticketsSnap.docs.forEach((doc, idx) => {
      const assignedKitchen = openKitchenIds[idx % openKitchenIds.length];
      const combo = doc.data().comboSelection === "B" ? "B" : "A";
      kitchenCounts[assignedKitchen].total += 1;
      if (combo === "A") kitchenCounts[assignedKitchen].optionA += 1;
      else kitchenCounts[assignedKitchen].optionB += 1;

      ops.push((batch) =>
        batch.update(doc.ref, {
          status: "LOCKED",
          assignedVendorId: assignedKitchen,
          lockedAt: admin.firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    ops.push((batch) =>
      batch.set(db.collection("kitchen_batches").doc(tomorrowStr), {
        date: tomorrowStr,
        totalUnits: ticketsSnap.size,
        kitchenAllocation: kitchenCounts,
        isFailoverActive: false,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
      })
    );

    await commitInChunks(ops, 450);
    console.log(`21:01 IST Split complete for ${tomorrowStr}: ${ticketsSnap.size} units allocated.`);
    return null;
  });

/**
 * 5. markTicketDelivered (Admin Callable)
 * Marks a ticket DELIVERED, decrements Pass remainingDays, and alerts the customer.
 */
exports.markTicketDelivered = functions.https.onCall(async (data, context) => {
  await requireAdmin(context);
  const { ticketId } = data || {};
  if (!ticketId) throw new functions.https.HttpsError("invalid-argument", "Missing ticketId.");

  const ticketRef = db.collection("meal_tickets").doc(ticketId);
  const ticketDoc = await ticketRef.get();
  if (!ticketDoc.exists) throw new functions.https.HttpsError("not-found", "Ticket not found.");

  const ticket = ticketDoc.data();
  const deliveredIso = new Date().toISOString();

  await db.runTransaction(async (tx) => {
    tx.update(ticketRef, {
      status: "DELIVERED",
      deliveredAtIso: deliveredIso,
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (ticket.passId && !String(ticket.passId).startsWith("single_")) {
      const passRef = db.collection("passes").doc(ticket.passId);
      const passDoc = await tx.get(passRef);
      if (passDoc.exists) {
        const rem = Math.max(0, (passDoc.data().remainingDays || 1) - 1);
        tx.update(passRef, {
          remainingDays: rem,
          status: rem === 0 ? "COMPLETED" : "ACTIVE",
        });
      }
    }
  });

  const userDoc = await db.collection("users").doc(ticket.userId).get();
  const token = userDoc.exists ? userDoc.data().fcmToken : null;
  if (token) {
    await admin.messaging().send({
      token,
      notification: {
        title: `Breakfast Dropped at Gate! (${ticket.bagToken || "Hungr"})`,
        body: `Your morning meal is waiting at ${ticket.clusterName}. Enjoy while hot!`,
      },
      data: { route: "/tickets", actionType: "GATE_DROP_ALERT" },
    });
  }

  return { success: true, deliveredAtIso: deliveredIso };
});

/**
 * 6. broadcastBatchArrival (Admin Callable)
 */
exports.broadcastBatchArrival = functions.https.onCall(async (data, context) => {
  await requireAdmin(context);
  const { clusterId } = data || {};
  if (!clusterId) throw new functions.https.HttpsError("invalid-argument", "Missing clusterId.");

  const usersSnap = await db.collection("users").where("clusterId", "==", clusterId).get();
  const fcmTokens = usersSnap.docs.map((d) => d.data().fcmToken).filter(Boolean);

  const sentCount = await sendMulticastChunked(fcmTokens, {
    notification: {
      title: "Hungr Tiffin Arrived!",
      body: "Your fresh breakfast packet has arrived at your drop gate. Enjoy within 90 mins!",
    },
    data: { type: "CLUSTER_ARRIVED", clusterId },
  });

  return { success: true, count: sentCount };
});

/**
 * 7. reassignKitchenUnitFailover (Admin Callable)
 */
exports.reassignKitchenUnitFailover = functions.https.onCall(async (data, context) => {
  await requireAdmin(context);
  const { unitId } = data || {};
  if (!unitId) throw new functions.https.HttpsError("invalid-argument", "Missing unitId.");

  const istNow = getNowIst();
  const tomorrow = new Date(istNow.getTime() + 86400000);
  const tomorrowStr = tomorrow.toISOString().split("T")[0];

  const ticketsSnap = await db
    .collection("meal_tickets")
    .where("assignedVendorId", "==", unitId)
    .where("status", "==", "LOCKED")
    .get();

  const ops = [
    (batch) =>
      batch.set(
        db.collection("kitchen_batches").doc(tomorrowStr),
        {
          isFailoverActive: true,
          failoverUnitId: unitId,
          reroutedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      ),
    ...ticketsSnap.docs.map((doc) => (batch) =>
      batch.update(doc.ref, {
        assignedVendorId: "backup_hub",
      })
    ),
  ];

  await commitInChunks(ops, 450);
  return { success: true, reroutedCount: ticketsSnap.size };
});

/**
 * 8. onNotificationQueueCreate (Firestore Trigger)
 */
exports.onNotificationQueueCreate = functions.firestore
  .document("notifications_queue/{notificationId}")
  .onCreate(async (snap) => {
    const data = snap.data();
    if (!data || data.status === "SENT") return null;

    const { title, body, imageUrl, route = "/storefront", audience = "all_users", actionType = "GENERAL" } = data;
    const payload = {
      topic: audience || "all_users",
      notification: {
        title: title || "Hungr Breakfast Update",
        body: body || "Fresh updates on tomorrow morning's tiffins!",
        ...(imageUrl ? { imageUrl } : {}),
      },
      data: {
        route,
        actionType,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        timestamp: String(Date.now()),
      },
    };

    try {
      const response = await admin.messaging().send(payload);
      await snap.ref.update({
        status: "SENT",
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        responseMessageId: response,
      });
      await db.collection("notifications_history").add({
        title,
        body,
        route,
        audience,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err) {
      await snap.ref.update({ status: "FAILED", error: String(err) });
    }
    return null;
  });

/**
 * 9. scheduledNightlyCutoffPush (20:15 IST Daily)
 */
exports.scheduledNightlyCutoffPush = functions.pubsub
  .schedule("45 14 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    await admin.messaging().send({
      topic: "daily_cutoff_reminders",
      notification: {
        title: "45 Mins Left! Lock Tomorrow's Breakfast",
        body: "Orders close at 9:00 PM tonight for tomorrow morning's 7:30 AM gate drop.",
      },
      data: { route: "/storefront", actionType: "CUTOFF_URGENCY" },
    });
    return null;
  });

/**
 * 10. scheduledMorningGateDropAlert (07:15 AM IST Daily)
 * Targeted ONLY to users who actually have an active meal scheduled today (no spam).
 */
exports.scheduledMorningGateDropAlert = functions.pubsub
  .schedule("45 1 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async () => {
    const istNow = getNowIst();
    const todayStr = istNow.toISOString().split("T")[0];

    const ticketsSnap = await db
      .collection("meal_tickets")
      .where("deliveryDateIso", ">=", `${todayStr}T00:00:00`)
      .where("deliveryDateIso", "<=", `${todayStr}T23:59:59`)
      .where("status", "in", ["SCHEDULED", "LOCKED"])
      .get();

    if (ticketsSnap.empty) return null;

    const uids = [...new Set(ticketsSnap.docs.map((d) => d.data().userId).filter(Boolean))];
    const userRefs = uids.map((uid) => db.collection("users").doc(uid));
    const userDocs = userRefs.length > 0 ? await db.getAll(...userRefs) : [];
    const tokens = userDocs.map((d) => (d.exists ? d.data().fcmToken : null)).filter(Boolean);

    await sendMulticastChunked(tokens, {
      notification: {
        title: "Your Morning Breakfast is Out for Delivery!",
        body: "Arriving at your gate by 7:30 AM. Check Orders for your bag token.",
      },
      data: { route: "/tickets", actionType: "GATE_DROP_ALERT" },
    });

    return null;
  });

/**
 * 11. abandonedCartEngagementNudge (Every 30 Mins)
 * Batch-fetches user tokens via db.getAll() (eliminates N+1 reads) and uses valid code HUNGRFREE.
 */
exports.abandonedCartEngagementNudge = functions.pubsub
  .schedule("every 30 minutes")
  .onRun(async () => {
    const twentyMinsAgo = new Date(Date.now() - 20 * 60 * 1000);
    const snapshot = await db
      .collection("abandoned_carts")
      .where("status", "==", "in_cart")
      .where("reminded", "==", false)
      .where("updatedAt", "<=", twentyMinsAgo)
      .limit(100)
      .get();

    if (snapshot.empty) return null;

    const userIds = [...new Set(snapshot.docs.map((d) => d.data().userId).filter(Boolean))];
    const userDocs = userIds.length > 0 ? await db.getAll(...userIds.map((u) => db.collection("users").doc(u))) : [];
    const tokenByUid = {};
    userDocs.forEach((doc) => {
      if (doc.exists && doc.data().fcmToken) tokenByUid[doc.id] = doc.data().fcmToken;
    });

    const tokens = [];
    const ops = [];
    snapshot.docs.forEach((doc) => {
      const uid = doc.data().userId;
      if (uid && tokenByUid[uid]) tokens.push(tokenByUid[uid]);
      ops.push((batch) =>
        batch.update(doc.ref, {
          reminded: true,
          remindedAt: admin.firestore.FieldValue.serverTimestamp(),
        })
      );
    });

    if (tokens.length > 0) {
      await sendMulticastChunked(tokens, {
        notification: {
          title: "Hot Breakfast Waiting in Your Cart!",
          body: "Complete your morning tiffin order before 9:00 PM & save ₹25 with code HUNGRFREE!",
        },
        data: { route: "/storefront/checkout", actionType: "ABANDONED_CART_RECOVERY" },
      });
    }

    await commitInChunks(ops, 450);
    return null;
  });

/**
 * 12. deleteMyAccountData (Callable)
 * Purges user profile, abandoned carts, and FCM tokens on account deletion.
 */
exports.deleteMyAccountData = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError("unauthenticated", "Authentication required.");
  const uid = context.auth.uid;

  const ops = [(batch) => batch.delete(db.collection("users").doc(uid))];

  const cartsSnap = await db.collection("abandoned_carts").where("userId", "==", uid).get();
  cartsSnap.docs.forEach((d) => ops.push((batch) => batch.delete(d.ref)));

  const tokensSnap = await db.collection("fcm_tokens").where("userId", "==", uid).get();
  tokensSnap.docs.forEach((d) => ops.push((batch) => batch.delete(d.ref)));

  await commitInChunks(ops, 450);
  return { success: true };
});
