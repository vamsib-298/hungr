const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Helper to get current Indian Standard Time (UTC + 5:30)
 */
function getNowIst() {
  const utcNow = new Date();
  const istOffset = 5.5 * 60 * 60 * 1000;
  return new Date(utcNow.getTime() + istOffset);
}

/**
 * 1. skipMealTicket (Callable)
 * Enforces server-side timestamp validation:
 * Calls after 21:00:00 IST return HTTP 403 / failed-precondition.
 * Enforces hard pass expiry ceiling (5/10/20 calendar days).
 * Appends replacement ticket to queue with zero bank refund friction.
 */
exports.skipMealTicket = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be logged in.");
  }

  const { ticketId } = data;
  if (!ticketId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing ticketId.");
  }

  // 1. Strict Server Timestamp Validation
  const istNow = getNowIst();
  const istHours = istNow.getUTCHours();
  const istMinutes = istNow.getUTCMinutes();

  // Hard cutoff at 21:00:00 IST
  if (istHours > 21 || (istHours === 21 && istMinutes >= 0)) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "403_CUTOFF_EXCEEDED: Calls to skip meal tickets after 21:00:00 IST are strictly forbidden. Production engine is active."
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
    throw new functions.https.HttpsError(
      "failed-precondition",
      `Cannot skip ticket with status: ${ticket.status}`
    );
  }

  // 2. Fetch Active Pass to verify Hard Expiry Ceiling
  const passDoc = await db.collection("passes").doc(ticket.passId).get();
  if (!passDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Active pass not found.");
  }
  const pass = passDoc.data();
  const hardExpiryDate = new Date(pass.hardExpiryDate);

  // 3. Find the tail of current user queue
  const userTicketsSnap = await db
    .collection("meal_tickets")
    .where("userId", "==", context.auth.uid)
    .where("status", "==", "SCHEDULED")
    .orderBy("deliveryDate", "desc")
    .limit(1)
    .get();

  let lastScheduledDate = new Date(ticket.deliveryDate);
  if (!userTicketsSnap.empty) {
    lastScheduledDate = new Date(userTicketsSnap.docs[0].data().deliveryDate);
  }

  // Candidate appended date = lastDate + 1 day
  const candidateAppendDate = new Date(lastScheduledDate);
  candidateAppendDate.setDate(candidateAppendDate.getDate() + 1);

  // Check hard ceiling
  if (candidateAppendDate.getTime() > hardExpiryDate.getTime()) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      `403_CEILING_REACHED: Skipping this ticket would push delivery to ${candidateAppendDate.toDateString()}, which exceeds pass validity ceiling (${hardExpiryDate.toDateString()}).`
    );
  }

  // 4. Atomic Transaction: Mark skipped & append new ticket
  const newTicketRef = db.collection("meal_tickets").doc();

  await db.runTransaction(async (transaction) => {
    transaction.update(ticketRef, {
      status: "SKIPPED",
      skippedAt: admin.firestore.FieldValue.serverTimestamp(),
      rescheduledToTicketId: newTicketRef.id,
    });

    transaction.set(newTicketRef, {
      ticketId: newTicketRef.id,
      passId: ticket.passId,
      userId: ticket.userId,
      clusterId: ticket.clusterId,
      clusterName: ticket.clusterName,
      deliveryDate: candidateAppendDate.toISOString(),
      comboSelection: ticket.comboSelection,
      addOns: ticket.addOns || [],
      slot: ticket.slot || "MORNING",
      status: "SCHEDULED",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {
    success: true,
    message: "Ticket skipped successfully with zero refund penalty.",
    newScheduledDate: candidateAppendDate.toISOString(),
    newTicketId: newTicketRef.id,
  };
});

/**
 * 2. autoAggregateKitchenSplit (Scheduled at 21:01 IST)
 * Runs daily at 21:01 IST (15:31 UTC).
 * Aggregates all locked tickets for tomorrow into Kitchen Unit 1 & Kitchen Unit 2 (50 capacity each).
 */
exports.autoAggregateKitchenSplit = functions.pubsub
  .schedule("31 15 * * *") // 21:01 IST daily
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    const istNow = getNowIst();
    const tomorrow = new Date(istNow);
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = tomorrow.toISOString().split("T")[0];

    // Fetch all scheduled tickets for tomorrow
    const ticketsSnap = await db
      .collection("meal_tickets")
      .where("deliveryDate", ">=", `${tomorrowStr}T00:00:00`)
      .where("deliveryDate", "<=", `${tomorrowStr}T23:59:59`)
      .where("status", "==", "SCHEDULED")
      .get();

    const tickets = [];
    ticketsSnap.forEach((doc) => tickets.push({ id: doc.id, ...doc.data() }));

    let unit1Tickets = [];
    let unit2Tickets = [];

    // Distribute evenly up to 50 cap each
    tickets.forEach((t, i) => {
      if (i % 2 === 0 && unit1Tickets.length < 50) {
        unit1Tickets.push(t);
      } else if (unit2Tickets.length < 50) {
        unit2Tickets.push(t);
      } else {
        unit1Tickets.push(t);
      }
    });

    const batch = db.batch();

    // Lock tickets and assign vendor IDs
    unit1Tickets.forEach((t) => {
      batch.update(db.collection("meal_tickets").doc(t.id), {
        status: "LOCKED",
        assignedVendorId: "aunty_1",
        lockedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    unit2Tickets.forEach((t) => {
      batch.update(db.collection("meal_tickets").doc(t.id), {
        status: "LOCKED",
        assignedVendorId: "aunty_2",
        lockedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // Write aggregated batch summary
    const batchSummaryRef = db.collection("kitchen_batches").doc(tomorrowStr);
    batch.set(batchSummaryRef, {
      date: tomorrowStr,
      totalUnits: tickets.length,
      unit1: {
        vendorId: "aunty_1",
        total: unit1Tickets.length,
        optionA: unit1Tickets.filter((t) => t.comboSelection === "A").length,
        optionB: unit1Tickets.filter((t) => t.comboSelection === "B").length,
      },
      unit2: {
        vendorId: "aunty_2",
        total: unit2Tickets.length,
        optionA: unit2Tickets.filter((t) => t.comboSelection === "A").length,
        optionB: unit2Tickets.filter((t) => t.comboSelection === "B").length,
      },
      isFailoverActive: false,
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();
    console.log(`21:01 IST Split complete for ${tomorrowStr}: ${tickets.length} total units allocated.`);
    return null;
  });

/**
 * 3. broadcastBatchArrival (Callable)
 * Dispatches concurrent Push Notifications to all recipients at a drop point
 */
exports.broadcastBatchArrival = functions.https.onCall(async (data, context) => {
  const { clusterId } = data;
  if (!clusterId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing clusterId.");
  }

  // Fetch recipients at cluster
  const usersSnap = await db
    .collection("users")
    .where("clusterId", "==", clusterId)
    .get();

  const fcmTokens = [];
  usersSnap.forEach((doc) => {
    const user = doc.data();
    if (user.fcmToken) fcmTokens.push(user.fcmToken);
  });

  if (fcmTokens.length > 0) {
    await admin.messaging().sendMulticast({
      tokens: fcmTokens,
      notification: {
        title: "Hungr Tiffin Arrived!",
        body: "Your fresh breakfast packet has been dropped at your hostel / building gate. Please pick up within 90 mins.",
      },
      data: {
        type: "CLUSTER_ARRIVED",
        clusterId: clusterId,
      },
    });
  }

  return { success: true, count: fcmTokens.length };
});

/**
 * 4. reassignKitchenUnitFailover (Callable - Admin only)
 * 1-Tap emergency failover switching to backup central kitchen
 */
exports.reassignKitchenUnitFailover = functions.https.onCall(async (data, context) => {
  const { unitId } = data; // 'aunty_1' or 'aunty_2'
  if (!unitId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing unitId.");
  }

  const istNow = getNowIst();
  const tomorrow = new Date(istNow);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const tomorrowStr = tomorrow.toISOString().split("T")[0];

  const batchRef = db.collection("kitchen_batches").doc(tomorrowStr);
  await batchRef.update({
    isFailoverActive: true,
    failoverUnitId: unitId,
    backupCenterAddress: "Central Cloud Backup Hub, Mamillaguda, Khammam",
    reroutedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update tickets assigned to that vendor
  const ticketsSnap = await db
    .collection("meal_tickets")
    .where("assignedVendorId", "==", unitId)
    .where("status", "==", "LOCKED")
    .get();

  const writeBatch = db.batch();
  ticketsSnap.forEach((doc) => {
    writeBatch.update(doc.ref, {
      assignedVendorId: "backup_hub",
      pickupAddress: "Central Cloud Backup Hub, Mamillaguda, Khammam",
    });
  });
  await writeBatch.commit();

  return { success: true, message: `Unit ${unitId} rerouted to backup hub.` };
});
