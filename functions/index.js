
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationsForOldStores = functions.https.onRequest(async (req, res) => {
  try {
    const snapshot = await admin.firestore().collection("stores").get();

    const messaging = admin.messaging();

    let count = 0;

    for (const doc of snapshot.docs) {
      const data = doc.data();

      console.log("Processing store:", doc.id);

      
      const payload = {
        notification: {
          title: data.name || "New Store",
          body: data.description || "Check this store",
        },
        topic: "stores",
      };

      await messaging.send(payload);
      count++;
    }

    res.send(`Done! Sent notifications for ${count} stores`);
  } catch (error) {
    console.error(error);
    res.status(500).send(error.toString());
  }
});