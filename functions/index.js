
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewStoreNotification = onDocumentCreated(
  "stores/{storeId}",
  async (event) => {
    try {
      const data = event.data.data();

      logger.info("New store added:", event.params.storeId);

      const message = {
        notification: {
          title: data.name || "New Store",
          body: data.description || "Check this store",
        },
        data: {
          type: "new_store",
          storeName: data.name || "New Store",
        },
        topic: "stores",
      };

      const response = await admin.messaging().send(message);

      logger.info("Notification sent:", response);
    } catch (error) {
      logger.error("Error sending notification:", error);
    }
  }
);